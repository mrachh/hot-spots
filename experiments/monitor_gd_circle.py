import os
import time
import scipy.io as sio
import numpy as np
import wandb
import re

OPTIMAL_VAL = 0.3655840228073865
CHECKPOINT_DIR = "/home/zw395/project/shape_optimization_results/circle1002"
INTERVAL = 30

wandb.login()
runs = {}

def parse_params(fname):
    m = re.search(r"n(\d+)_yc([\d\.]+)_it(\d+)_zk([\d\.]+)", fname)
    if not m:
        return {}
    return {
        "n": int(m.group(1)),
        "ycenter": float(m.group(2)),
        "maxiter": int(m.group(3)),
        "zk0": float(m.group(4)),
    }

def monitor_loop():
    while True:
        checkpoints = [f for f in os.listdir(CHECKPOINT_DIR) if f.endswith(".mat")]
        for fname in checkpoints:
            fpath = os.path.join(CHECKPOINT_DIR, fname)
            try:
                S = sio.loadmat(fpath)
                it   = int(S["iter"].ravel()[0])
                val  = float(S["vals"].ravel()[-1])
                diff = val - OPTIMAL_VAL
                logdiff = np.log10(abs(diff)) if diff != 0 else -np.inf
                times = S["times"].ravel().tolist() if "times" in S else []
                step_time = times[-1] if times else None
            except Exception:
                continue

            if fname not in runs:
                params = parse_params(fname)
                runs[fname] = wandb.init(
                    project="so251002",
                    config=params,
                    name=fname,
                    reinit=True,
                )

            metrics = {"iter": it, "val": val, "diff": diff, "logdiff": logdiff}
            if step_time is not None:
                metrics["time/step"] = step_time
            runs[fname].log(metrics)

        time.sleep(INTERVAL)

if __name__ == "__main__":
    monitor_loop()
