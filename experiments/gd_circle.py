import os
from itertools import product

PARTITION   = "day"
MEM_PER_CPU = "128g"
TIME        = "23:00:00"
VERBOSE     = True

base_dir = "/home/zw395/project/shape_optimization_results/circle1010"
os.makedirs(base_dir, exist_ok=True)

n_list        = [8,32,128,512]
ycenter_list  = [0.98]
maxiter_list  = [10000]
stepsize_list = [1.0]
# stepsize_list = [1.0]
zk0_list      = [2.5]
ncheb_list    = [8,16,32]
resume_list   = [False]

def gen_single_job(n, ncheb, ycenter, maxiter, stepsize, zk0, savedir, resume):
    resume_str = "true" if resume else "false"
    return (
        f"module load MATLAB/2022b;"
        f"matlab -nodisplay -nosplash -r "
        f"\"addpath ../src; addpath ../src_shaper_ders; cluster_startup;"
        f"run_gradient_descent({n},{ncheb},{ycenter},{maxiter},{stepsize},{zk0},'{savedir}',{resume_str}); exit\""
    )

def submit_job_list(job_list, job_idx):
    job_txt = "\n".join(job_list)
    with open(f"jobs_{job_idx}.txt", "w+") as f:
        f.write(job_txt)
    output_option = "" if VERBOSE else "--output /dev/null "
    os.system(
        f"dsq --job-file jobs_{job_idx}.txt --batch-file {job_idx}.sh "
        f"{output_option}--partition {PARTITION} --cpus-per-task 1 "
        f"--mem-per-cpu {MEM_PER_CPU} -t {TIME} --requeue --submit"
    )
    print(f"submitted {len(job_list)} jobs")

def submit_all_jobs():
    param_list = [n_list, ycenter_list, maxiter_list, stepsize_list, zk0_list, ncheb_list, resume_list]
    job_list = []
    job_idx = 0
    for params in product(*param_list):
        n, ycenter, maxiter, stepsize, zk0, ncheb, resume = params
        save_dir = os.path.join(base_dir, f"n{n}_yc{ycenter:.2f}_it{maxiter}_zk{zk0:.2f}_step{stepsize:.2f}")
        os.makedirs(save_dir, exist_ok=True)
        if not (resume and any(f.endswith(".mat") for f in os.listdir(save_dir))):
            job_list.append(gen_single_job(n, ncheb, ycenter, maxiter, stepsize, zk0, save_dir, resume))
        if len(job_list) >= 100:
            submit_job_list(job_list, job_idx)
            job_list = []
            job_idx += 1
    if job_list:
        submit_job_list(job_list, job_idx)

if __name__ == "__main__":
    submit_all_jobs()
