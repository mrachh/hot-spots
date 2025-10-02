import os
import time
import scipy.io
import numpy as np
import wandb
import matplotlib.pyplot as plt

INTERVAL    = 30
OPTIMAL_VAL = 0.3655840228073865
base_dir    = "/home/zw395/project/shape_optimization_results/circle1002"

def make_polygon_image(rads, n):
    angles = np.linspace(0, np.pi, n)
    x = rads * np.cos(angles)
    y = rads * np.sin(angles)
    fig, ax = plt.subplots()
    ax.plot(x, y, '-o')
    ax.axis("equal")
    ax.set_title("Polygon")
    return fig

def monitor_loop():
    runs = {}
    while True:
        for fname in os.listdir(base_dir):
            if not fname.endswith(".mat"):
                continue
            fpath = os.path.join(base_dir, fname)
            try:
                S = scipy.io.loadmat(fpath)
            except Exception:
                continue

            iter_arr = S.get("iter")
            vals_arr = S.get("vals")
            n_arr    = S.get("n")
            rads_arr = S.get("rads")

            if iter_arr is None or vals_arr is None or n_arr is None or rads_arr is None:
                continue

            if iter_arr.size == 0 or vals_arr.size == 0 or n_arr.size == 0 or rads_arr.size == 0:
                continue

            iter_val = int(np.squeeze(iter_arr))
            val      = float(np.squeeze(vals_arr)[-1])
            n        = int(np.squeeze(n_arr))
            rads     = np.squeeze(rads_arr)

            if len(rads) != n:
                print(f"Warning: mismatch in rads vs n for {fname}, skipping")
                continue

            diff     = val - OPTIMAL_VAL
            diff_log = float("-inf") if diff <= 0 else np.log10(diff)

            if fname not in runs:
                runs[fname] = wandb.init(
                    project="so251002",
                    name=fname,
                    resume="allow",
                    reinit=True
                )

            fig = make_polygon_image(rads, n)

            time_arr = S.get("time_per_step")
            if time_arr is not None and time_arr.size > 0:
                step_time = float(np.squeeze(time_arr)[-1])
            else:
                step_time = 0.0

            metrics = {
                "iteration": iter_val,
                "val": val,
                "diff": diff,
                "diff_log10": diff_log,
                "time_per_step": step_time,
                "polygon": wandb.Image(fig, caption=f"iter {iter_val}")
            }

            runs[fname].log(metrics)
            plt.close(fig)

        time.sleep(INTERVAL)

if __name__ == "__main__":
    monitor_loop()
