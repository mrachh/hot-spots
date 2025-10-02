import os
import time
import scipy.io as sio
import numpy as np
import wandb

OPTIMAL_VAL = 0.3655840228073865
CHECKPOINT_DIR = "/home/zw395/project/shape_optimization_results/circle1002"
INTERVAL = 30

wandb.login()
runs = {}
finished = set()

def load_params(S):
    return {
        "n": int(S["n"].ravel()[0]),
        "ncheb": int(S["ncheb"].ravel()[0]),
        "ycenter": round(float(S["ycenter"].ravel()[0]), 4),
        "maxiter": int(S["maxiter"].ravel()[0]),
        "stepsize": round(float(S["stepsize"].ravel()[0]), 4),
        "zk0": round(float(S["zk0"].ravel()[0]), 4),
        "resume": bool(S["resume"].ravel()[0]),
    }

def monitor_loop():
    while True:
        checkpoints = [f for f in os.listdir(CHECKPOINT_DIR) if f.endswith(".mat")]
        for fname in checkpoints:
            if fname in finished:
                continue

            fpath = os.path.join(CHECKPOINT_DIR, fname)
            try:
                S = sio.loadmat(fpath)
                it   = int(S["iter"].ravel()[0])
                val  = float(S["vals"].ravel()[-1])
                diff = val - OPTIMAL_VAL
                logdiff = np.log10(abs(diff)) if diff != 0 else -np.inf
                times = S["times"].ravel().tolist() if "times" in S else []
                step_time = times[-1] if times else None
                maxiter = int(S["maxiter"].ravel()[0])
            except Exception:
                continue

            if fname not in runs:
                params = load_params(S)
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

            if it >= maxiter:
                runs[fname].finish()
                finished.add(fname)
                print(f"Finished run {fname}")

        time.sleep(INTERVAL)

if __name__ == "__main__":
    monitor_loop()
