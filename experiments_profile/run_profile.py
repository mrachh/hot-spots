import shutil, os
from itertools import product

PARTITION   = "scavenge"
MEM_PER_CPU = "16g"
NUM_CPUS = "12"
TIME        = "8:00:00"
PURGE       = False
VERBOSE     = True
START_IDX = 0

BASE_DIR = "/home/zw395/palmer_scratch/shape_optimization_results/profile1108"
if PURGE:
    if os.path.exists(BASE_DIR):
        shutil.rmtree(BASE_DIR)
os.makedirs(BASE_DIR, exist_ok=True)


n_list        = [i*16 for i in range(1,9)]
ncheb_list    = [i*4 for i in range(4,11)]
runid_list    = [i for i in range(5)]



def gen_single_job(n, ncheb, runid, savefn):
    return (
        f"module load MATLAB/2022b;"
        f"matlab -nodisplay -nosplash -r "
        f"\"addpath ../src; addpath ../src_shaper_ders; cluster_startup;"
        f"profile_grad({n},{ncheb},{savefn},{runid}); exit\""
    )

def submit_job_list(job_list, job_idx):
    job_txt = "\n".join(job_list)
    with open(f"jobs_{job_idx}.txt", "w+") as f:
        f.write(job_txt)
    output_option = "" if VERBOSE else "--output /dev/null "
    os.system(
        f"dsq --job-file jobs_{job_idx}.txt --batch-file {job_idx}.sh "
        f"{output_option}--partition {PARTITION} --cpus-per-task {NUM_CPUS} "
        f"--mem-per-cpu {MEM_PER_CPU} -t {TIME} --requeue --submit"
    )
    print(f"submitted {len(job_list)} jobs")

def submit_all_jobs():
    param_list = [n_list, ncheb_list, runid_list]
    job_list = []
    job_idx = START_IDX
    run_idx = 0
    for params in product(*param_list):
        n, ncheb, runid = params
        savefn = os.path.join(BASE_DIR, f"{run_idx}.mat")
        job_list.append(gen_single_job(n, ncheb, runid, savefn))
        if len(job_list) >= 100:
            submit_job_list(job_list, job_idx)
            job_list = []
            job_idx += 1
        run_idx += 1

    if job_list:
        submit_job_list(job_list, job_idx)

if __name__ == "__main__":
    submit_all_jobs()