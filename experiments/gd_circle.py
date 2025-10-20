import shutil, os
from itertools import product

PARTITION   = "week"
MEM_PER_CPU = "16g"
NUM_CPUS = "12"
TIME        = "6-23:00:00"
PURGE       = True
VERBOSE     = True
START_IDX = 0

base_dir = "/home/zw395/palmer_scratch/shape_optimization_results/circle1015"
if PURGE:
    if os.path.exists(base_dir):
        shutil.rmtree(base_dir)
os.makedirs(base_dir, exist_ok=True)


n_list        = [128]
ycenter_list  = [0.97, 0.93]
maxiter_list  = [100]
stepsize_list = [1.0]
zk0_list      = [2.5]
ncheb_list    = [64,96]
resume_list   = [True]
version_list = ['v4', 'v5']

def gen_single_job(n, ncheb, ycenter, maxiter, stepsize, zk0, savedir, resume, version):
    resume_str = "true" if resume else "false"
    return (
        f"module load MATLAB/2022b;"
        f"matlab -nodisplay -nosplash -r "
        f"\"addpath ../src; addpath ../src_shaper_ders; cluster_startup;"
        f"gd_circle{version}({n},{ncheb},{ycenter},{maxiter},{stepsize},{zk0},'{savedir}',{resume_str}); exit\""
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
    param_list = [n_list, ycenter_list, maxiter_list, stepsize_list, zk0_list, ncheb_list, resume_list, version_list]
    job_list = []
    job_idx = START_IDX
    run_idx = 0

    for params in product(*param_list):
        n, ycenter, maxiter, stepsize, zk0, ncheb, resume, version = params
        save_dir = os.path.join(base_dir, f"run_{run_idx}")
        os.makedirs(save_dir, exist_ok=True)

        if not (resume and any(f.endswith(".mat") for f in os.listdir(save_dir))):
            job_list.append(gen_single_job(n, ncheb, ycenter, maxiter, stepsize, zk0, save_dir, resume, version))

        if len(job_list) >= 100:
            submit_job_list(job_list, job_idx)
            job_list = []
            job_idx += 1

        run_idx += 1

    if job_list:
        submit_job_list(job_list, job_idx)

if __name__ == "__main__":
    submit_all_jobs()
    import monitor_gd_circle
    monitor_gd_circle.monitor_loop()
