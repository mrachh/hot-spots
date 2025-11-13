import shutil, os
import numpy as np
from itertools import product

PARTITION   = "scavenge"
MEM_PER_CPU = "16g"
NUM_CPUS = "12"
TIME        = "6:00:00"
PURGE       = False
VERBOSE     = True
START_IDX = 0

BASE_DIR = "/home/zw395/palmer_scratch/shape_optimization_results/profile1113"
if PURGE:
    if os.path.exists(BASE_DIR):
        shutil.rmtree(BASE_DIR)
os.makedirs(BASE_DIR, exist_ok=True)


n_list        = [128]
ncheb_list    = [32]
flam_occ_list = [1000]
runid_list    = [0,1,2]
ncpu_list = np.arange(16)



def gen_single_job(n, ncheb, flam_occ, runid, savefn):
    return (
        f"module load MATLAB/2022b;"
        f"matlab -nodisplay -nosplash -r "
        f"\"addpath ../src; addpath ../src_shaper_ders; cluster_startup;"
        f"profile_grad({n},{ncheb},{flam_occ},{runid},'{savefn}'); exit\""
    )

def submit_job_list(job_list, job_idx, num_cpus = NUM_CPUS, mem_per_cpu = MEM_PER_CPU):
    job_txt = "\n".join(job_list)
    with open(f"jobs_{job_idx}.txt", "w+") as f:
        f.write(job_txt)
    output_option = "" if VERBOSE else "--output /dev/null "
    os.system(
        f"dsq --job-file jobs_{job_idx}.txt --batch-file {job_idx}.sh "
        f"{output_option}--partition {PARTITION} --cpus-per-task {num_cpus} "
        f"--mem-per-cpu {mem_per_cpu} -t {TIME} --requeue --submit"
    )
    print(f"submitted {len(job_list)} jobs")

def submit_all_jobs():
    param_list = [n_list, ncheb_list, flam_occ_list, runid_list, ncpu_list]
    job_list = []
    job_idx = START_IDX
    # run_idx = 0
    for params in product(*param_list):
        n, ncheb, flam_occ, runid, num_cpus = params
        mem_per_cpu = 12*16//num_cpus
        savefn = os.path.join(BASE_DIR, f"{num_cpus}_{mem_per_cpu}.mat")
        job_list.append(gen_single_job(n, ncheb, flam_occ, runid, savefn))
        submit_job_list(job_list, job_idx, num_cpus, mem_per_cpu)
        job_idx += 1
        # if len(job_list) >= 100:
        #     submit_job_list(job_list, job_idx)
        #     job_list = []
        #     job_idx += 1
        # run_idx += 1

    # if job_list:
    #     submit_job_list(job_list, job_idx)

if __name__ == "__main__":
    submit_all_jobs()