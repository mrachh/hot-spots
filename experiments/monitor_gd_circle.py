import os
import shutil
import time
import numpy as np
import wandb
from scipy.io import loadmat
from datetime import datetime
from wandb import Api

PROJECT     = "so251002"
BASE_DIR    = "/home/zw395/project/shape_optimization_results/circle1002"
INTERVAL    = 30
OPTIMAL_VAL = 0.3655840228073865
WANDB_DIR   = os.path.join(os.path.dirname(__file__), "wandb")

def purge_project(project):
    api = Api()
    for run in api.runs(f"zijian-wang_yale/{project}"):
        run.delete()
    print(f"[{datetime.now()}] purged wandb project {project}")

    if os.path.exists(WANDB_DIR):
        shutil.rmtree(WANDB_DIR)
        print(f"[{datetime.now()}] removed local wandb dir {WANDB_DIR}")

def safe_scalar(x):
    return float(np.ravel(x)[0]) if np.size(x) > 0 else 0.0

def log_checkpoint(run, ckpt_path):
    try:
        S = loadmat(ckpt_path)
        val    = safe_scalar(S["val"])
        zk     = safe_scalar(S["zk"])
        it     = int(np.ravel(S["iter"])[0])
        tstep  = safe_scalar(S.get("tstep", [0.0]))
        ttotal = safe_scalar(S.get("time", [0.0]))  # <-- total runtime

        diff  = val - OPTIMAL_VAL
        log10diff = np.log10(abs(diff)) if diff != 0 else -np.inf

        metrics = {
            "val": val,
            "zk": zk,
            "iter": it,
            "tstep": tstep,
            "time_total": ttotal,
            "diff_from_optimal": diff,
            "log10_diff": log10diff,
        }
        run.log(metrics, step=it)
        print(f"[{datetime.now()}] logged {ckpt_path} iter={it} val={val:.6f}")
        return True
    except Exception as e:
        print(f"[{datetime.now()}] skip {ckpt_path}, err={e}")
        return False

def monitor_loop():
    purge_project(PROJECT)
    runs = {}
    seen = {}

    while True:
        ckpt_dirs = [d for d in os.listdir(BASE_DIR) if os.path.isdir(os.path.join(BASE_DIR, d))]
        print(f"[{datetime.now()}] checking {len(ckpt_dirs)} checkpoint dirs...")

        for d in ckpt_dirs:
            dpath = os.path.join(BASE_DIR, d)
            if d not in runs:
                print(f"[{datetime.now()}] start run {d}")
                runs[d] = wandb.init(project=PROJECT, name=d, reinit=True, dir=WANDB_DIR)
                seen[d] = set()

            run = runs[d]
            files = sorted([f for f in os.listdir(dpath) if f.endswith(".mat")],
                           key=lambda x: int(os.path.splitext(x)[0]))

            for f in files:
                fpath = os.path.join(dpath, f)
                if fpath not in seen[d]:
                    if log_checkpoint(run, fpath):
                        seen[d].add(fpath)

        time.sleep(INTERVAL)

if __name__ == "__main__":
    monitor_loop()
