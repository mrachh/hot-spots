import os
from itertools import product

PARTITION   = "day"
MEM_PER_CPU = "128g"
TIME        = "23:00:00"
VERBOSE     = True
INTERVAL    = 30
OPTIMAL_VAL = 0.3655840228073865

base_dir = f"/home/zw395/project/shape_optimization_results/circle1002"
os.makedirs(base_dir, exist_ok=True)

n_list        = [8, 16, 32, 64, 128, 256]
ycenter_list  = [0.98]
maxiter_list  = [10_000]
stepsize_list = [0.1, 0.5, 1.0, 2.0]
zk0_list      = [2.0]
ncheb_list    = [32]

RESUME = False

def fmt_float(x):
    rounded = round(x, 2)
    if abs(x - rounded) > 1e-12:
        raise ValueError(f"Invalid float {x}: must be representable with 2 decimals")
    return f"{rounded:.2f}"

def gen_single_job(n, ncheb, ycenter, maxiter, stepsize, zk0, savefile, resume_flag):
    ycenter_str  = fmt_float(ycenter)
    stepsize_str = fmt_float(stepsize)
    zk0_str      = fmt_float(zk0)
    resume_str   = "true" if resume_flag else "false"
    return (
        f"module load MATLAB/2022b;"
        f"matlab -nodisplay -nosplash -r "
        f"\"addpath ../src; addpath ../src_shaper_ders; cluster_startup;"
        f"run_gradient_descent({n},{ncheb},{ycenter_str},{maxiter},{stepsize_str},{zk0_str},'{savefile}',{resume_str}); exit\""
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
    param_list = [n_list, ycenter_list, maxiter_list, stepsize_list, zk0_list, ncheb_list]
    job_list = []
    job_idx = 0
    for params in product(*param_list):
        n, ycenter, maxiter, stepsize, zk0, ncheb = params
        ycenter_str  = fmt_float(ycenter)
        stepsize_str = fmt_float(stepsize)
        zk0_str      = fmt_float(zk0)

        savefile = os.path.join(
            base_dir,
            f"checkpoint_n{n}_yc{ycenter_str}_it{maxiter}_zk{zk0_str}_step{stepsize_str}.mat"
        )

        if RESUME:
            resume_flag = os.path.isfile(savefile)
        else:
            if os.path.isfile(savefile):
                os.remove(savefile)
            resume_flag = False

        job_list.append(gen_single_job(n, ncheb, ycenter, maxiter, stepsize, zk0, savefile, resume_flag))

        if len(job_list) >= 100:
            submit_job_list(job_list, job_idx)
            job_list = []
            job_idx += 1

    if job_list:
        submit_job_list(job_list, job_idx)

if __name__ == "__main__":
    submit_all_jobs()
