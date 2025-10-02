import wandb

ENTITY  = "zijian-wang_yale"
PROJECT = "so251002"

api = wandb.Api()
runs = api.runs(f"{ENTITY}/{PROJECT}")

for run in runs:
    print(f"Deleting {run.id} ...")
    run.delete()

print(f"All runs in {ENTITY}/{PROJECT} deleted.")
