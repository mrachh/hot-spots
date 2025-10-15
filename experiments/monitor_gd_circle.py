import os
import shutil
import time
import numpy as np
import wandb
from scipy.io import loadmat
from datetime import datetime
from wandb import Api
import matplotlib.pyplot as plt

PROJECT     = "circle1015"
BASE_DIR    = "/home/zw395/palmer_scratch/shape_optimization_results/circle1015"
INTERVAL    = 5 * 60
OPTIMAL_VAL = 0.3655840228073865
WANDB_DIR   = os.path.join(os.path.dirname(__file__), "wandb")

def purge_project(project):
    api = Api()
    try:
        for run in api.runs(f"zijian-wang_yale/{project}"):
            run.delete()
        print(f"[{datetime.now()}] purged wandb project {project}")
    except ValueError:
        print(f"[{datetime.now()}] project {project} not found, skipping purge")

    if os.path.exists(WANDB_DIR):
        shutil.rmtree(WANDB_DIR, ignore_errors=True)
        print(f"[{datetime.now()}] removed local wandb dir {WANDB_DIR}")

def safe_scalar(x):
    return float(np.ravel(x)[0]) if np.size(x) > 0 else 0.0

# def make_polygon_image(rads): 
#     n = len(rads) 
#     angles = np.linspace(0, np.pi, n, endpoint=True) 
#     x = rads * np.cos(angles) 
#     y = rads * np.sin(angles) 
#     fig, ax = plt.subplots() 
#     ax.plot(x, y, "-o", markersize=3) 
#     ax.set_aspect("equal") 
#     ax.axis("off") 
#     return fig

def make_polygon_image(rads):
    n = len(rads)
    angles = np.linspace(0, np.pi, n, endpoint=True)

    x = rads * np.cos(angles)
    y = rads * np.sin(angles)

    fig, ax = plt.subplots()
    ax.plot(x, y, "-o", markersize=3)
    ax.axhline(0, color="gray", linewidth=1)  # x-axis line
    ax.set_aspect("equal")
    ax.axis("off")
    return fig





def extract_config(S):
    """Extract simulation parameters for W&B config."""
    n        = safe_scalar(S.get("n", [0]))
    ncheb    = safe_scalar(S.get("ncheb", [0]))
    ycenter  = safe_scalar(S.get("ycenter", [0.0]))
    maxiter  = safe_scalar(S.get("maxiter", [0]))
    zk0      = safe_scalar(S.get("zk0", [0.0]))
    resume   = bool(S.get("resume", [[False]])[0][0]) if "resume" in S else False
    return {
        "n": int(n),
        "ncheb": int(ncheb),
        "ycenter": ycenter,
        "maxiter": int(maxiter),
        "zk0": zk0,
        "resume": resume,
    }

def log_checkpoint(run, ckpt_path):
    try:
        S = loadmat(ckpt_path)
        val   = safe_scalar(S.get("val", [0.0]))
        zk    = safe_scalar(S.get("zk", [0.0]))
        it    = int(np.ravel(S.get("iter", [0]))[0])
        tstep = safe_scalar(S.get("tstep", [0.0]))
        time_total = safe_scalar(S.get("time", [0.0]))
        rads   = np.ravel(S.get("rads", []))
        stepsz = safe_scalar(S.get("stepsize", [0.0]))
        dvals  = np.ravel(S.get("dvals", []))
        dzks   = np.ravel(S.get("dzks", []))
        diff = val - OPTIMAL_VAL
        log10diff = np.log10(abs(diff)) if diff != 0 else -np.inf

        metrics = {
            "val": val,
            "zk": zk,
            "iter": it,
            "time_step": tstep,
            "time_total": time_total,
            "stepsize": stepsz,
            "grad_norm": np.linalg.norm(dvals) if dvals.size else 0.0,
            "diff_from_optimal": diff,
            "log10_diff": log10diff,
        }

        fig = make_polygon_image(rads)
        run.log({"metrics": metrics, "polygon": wandb.Image(fig)}, step=it)
        plt.close(fig)
        print(f"[{datetime.now()}] logged iter={it:4d}, val={val:.6f}, zk={zk:.6f}")
        return True
    except Exception as e:
        print(f"[{datetime.now()}] skip {ckpt_path}, err={e}")
        return False

def monitor_loop():
    last_counts = {}
    while True:
        ckpt_dirs = [d for d in os.listdir(BASE_DIR) if os.path.isdir(os.path.join(BASE_DIR, d))]
        print(f"[{datetime.now()}] checking {len(ckpt_dirs)} checkpoint dirs...")
        changed = False
        current_counts = {}

        for d in ckpt_dirs:
            dpath = os.path.join(BASE_DIR, d)
            files = [f for f in os.listdir(dpath) if f.endswith(".mat")]
            current_counts[d] = len(files)
            if last_counts.get(d, 0) < len(files):
                changed = True

        if not changed:
            print(f"[{datetime.now()}] no new files detected, sleeping {INTERVAL}s")
            try:
                for _ in range(INTERVAL):
                    time.sleep(1)
            except KeyboardInterrupt:
                print("\n[monitor] interrupted by user, exiting.")
                sys.exit(0)
            continue

        purge_project(PROJECT)

        for d in ckpt_dirs:
            dpath = os.path.join(BASE_DIR, d)
            print(f"[{datetime.now()}] start run {d}")
            # Extract configuration from the first .mat file
            files = sorted(
                [f for f in os.listdir(dpath) if f.endswith(".mat")],
                key=lambda x: int(os.path.splitext(x)[0])
            )
            if not files:
                continue

            first_ckpt = os.path.join(dpath, files[0])
            try:
                S0 = loadmat(first_ckpt)
                config = extract_config(S0)
            except Exception as e:
                print(f"[{datetime.now()}] cannot read config from {first_ckpt}: {e}")
                config = {}

            run = wandb.init(project=PROJECT, name=d, reinit=True, dir=WANDB_DIR, config=config)

            for f in files:
                fpath = os.path.join(dpath, f)
                log_checkpoint(run, fpath)

            run.finish()

        last_counts = current_counts
        time.sleep(INTERVAL)

if __name__ == "__main__":
    monitor_loop()
