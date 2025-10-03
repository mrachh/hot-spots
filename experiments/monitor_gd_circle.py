import os
import shutil
import time
import numpy as np
import wandb
from scipy.io import loadmat
from datetime import datetime
from wandb import Api
import matplotlib.pyplot as plt

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
        shutil.rmtree(WANDB_DIR, ignore_errors=True)
        print(f"[{datetime.now()}] removed local wandb dir {WANDB_DIR}")

def safe_scalar(x):
    return float(np.ravel(x)[0]) if np.size(x) > 0 else 0.0

def make_polygon_image(rads, angles):
    x = rads * np.cos(angles)
    y = rads * np.sin(angles)
    # close the polygon
    x = np.append(x, x[0])
    y = np.append(y, y[0])
    fig, ax = plt.subplots()
    ax.plot(x, y, "-o")
    ax.set_aspect("equal")
    return fig

def log_checkpoint(run, ckpt_path):
    try:
        S = loadmat(ckpt_path)
        val    = safe_scalar(S["val"])
        zk     = safe_scalar(S["zk"])
        it     = int(np.ravel(S["iter"])[0])
        tstep  = safe_scalar(S.get("tstep", [0.0]))
        ttotal = safe_scalar(S.get("time", [0.0]))
        rads   = np.ravel(S["rads"])
        angles = np.ravel(S["angles"])

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

        fig = make_polygon_image(rads, angles)
        run.log({"metrics": metrics, "polygon": wandb.Image(fig)}, step=it)
        plt.close(fig)

        print(f"[{datetime.now()}] logged {ckpt_path} iter={it} val={val:.6f}")
        return True
    except Exception as e:
        print(f"[{datetime.now()}] skip {ckpt_path}, err={e}")
        return False

def monitor_loop():
    last_counts = {}

    while True:
        ckpt_dirs = [d for d in os.listdir(BASE_DIR) if os.path.isdir(os.path.join(BASE_DIR, d))]
        print(f"[{datetime.now()}] checking {len(ckpt_dirs)} checkpoint dirs...")

        # check if any new files
        changed = False
        current_counts = {}
        for d in ckpt_dirs:
            dpath = os.path.join(BASE_DIR, d)
            files = [f for f in os.listdir(dpath) if f.endswith(".mat")]
            current_counts[d] = len(files)
            if last_counts.get(d, 0) < len(files):
                changed = True

        if not changed:
            print(f"[{datetime.now()}] no new files detected, skipping purge+reload")
            time.sleep(INTERVAL)
            continue

        # purge and reload everything
        purge_project(PROJECT)
        for d in ckpt_dirs:
            dpath = os.path.join(BASE_DIR, d)
            print(f"[{datetime.now()}] start run {d}")
            run = wandb.init(project=PROJECT, name=d, reinit=True, dir=WANDB_DIR)

            files = sorted([f for f in os.listdir(dpath) if f.endswith(".mat")],
                           key=lambda x: int(os.path.splitext(x)[0]))
            for f in files:
                fpath = os.path.join(dpath, f)
                log_checkpoint(run, fpath)

            run.finish()

        last_counts = current_counts
        time.sleep(INTERVAL)

if __name__ == "__main__":
    monitor_loop()
