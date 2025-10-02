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

            iter_val = int(S.get("iter", [[0]])[0][0])
            val      = float(S.get("vals", [[0]])[0][-1])
            n        = int(S.get("n", [[0]])[0][0])
            rads     = np.array(S.get("rads", [[0]])[0])

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

            metrics = {
                "iteration": iter_val,
                "val": val,
                "diff": diff,
                "diff_log10": diff_log,
                "time_per_step": float(S.get("time_per_step", [[0]])[0][-1]),
                "polygon": wandb.Image(fig, caption=f"iter {iter_val}")
            }

            runs[fname].log(metrics)
            plt.close(fig)

        time.sleep(INTERVAL)

if __name__ == "__main__":
    monitor_loop()
