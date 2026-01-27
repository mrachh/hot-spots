"""
controller v3
"""
import sys, os
from scipy.io import loadmat, savemat
sys.path.append('/home/zw395/shape_optimization')
import numpy as np
import pandas as pd
import time, datetime, json
import utils
from tqdm import tqdm

# utils
with open(sys.argv[1],'r') as f:
   config =  json.load(f)

CONST = 0.3655840228073865
PROJECT_DIR = config['PROJECT_DIR']
SHAPE = config['SHAPE']
NUM_VERTS = config['NUM_VERTS']
USE_BFGS = config['USE_BFGS']
PARTITION = config['PARTITION']
MEMORY = config['MEMORY']
TIME = config['TIME']
VERBOSE = config['VERBOSE']
MAX_ITER = config['MAX_ITER']
MAXCHUNKLEN = config['MAXCHUNKLEN']
NONCONVEX_PENALTY_FACTOR = config['NONCONVEX_PENALTY_FACTOR']
SUMMARY_DIR = f'{PROJECT_DIR}/summary'


def get_curr_epoch():
    if not os.path.isdir(SUMMARY_DIR):
        return 0
    ids = [int(i[2:]) for i in os.listdir(PROJECT_DIR) if i.startswith('gd')]
    if len(ids)==0:
        return 0
    return max(ids)


def save_result(val,name,epoch):
    if isinstance(val, np.ndarray):
        arr = val
    else:
        arr = np.array([val])
    np.save(f'{SUMMARY_DIR}/{name}{epoch}',arr)
    return

def load_result(name, epoch):
    fn = f'{SUMMARY_DIR}/{name}{epoch}.npy'
    try:
        res = np.load(fn)
        if len(res.shape)==1:
            if len(res)==1:
                res = res[0]
        return res
    except:
        print(f'{fn} does not exist')
        return None


def wait_jobs(file_dir, num_files, sleep=5):
    job_name = file_dir.split('/')[-2]
    with tqdm(total=num_files, desc=job_name) as pbar:
        pbar.n = len(os.listdir(file_dir))
        pbar.refresh()
        while len(os.listdir(file_dir))<num_files:
            time.sleep(sleep)
            pbar.n = len(os.listdir(file_dir))
            pbar.refresh()
    return

def init_save_dir(job_name):
    save_dir = f'{PROJECT_DIR}/{job_name}'
    param_dir = f'{save_dir}/param'
    result_dir = f'{save_dir}/results'
    os.makedirs(save_dir, exist_ok=True)
    os.makedirs(param_dir, exist_ok=True)
    os.makedirs(result_dir, exist_ok=True)
    return param_dir, result_dir

def get_job_fn(save_idx, job_name):
    save_dir = f'{PROJECT_DIR}/{job_name}'
    param_dir = f'{save_dir}/param'
    result_dir = f'{save_dir}/results'
    save_fn = f'{result_dir}/{save_idx}.mat'
    param_fn = f'{param_dir}/{save_idx}.mat'
    return param_fn, save_fn

def gen_single_job(param_fn):
    return f'''module load MATLAB/2022b;matlab -batch \"run(\'{param_fn}\')\";'''

def submit_job_list(job_list, job_idx):
    if len(job_list)==0:
        return
    r = np.random.randint(10000)
    job_txt = '\n'.join(job_list)
    with open(f'jobs_{job_idx}_{r}.txt', 'w+') as f:
        f.write(job_txt)
    if not VERBOSE:
        output_option = '--output /dev/null '
    else:
        output_option = ''
    os.system(f"dsq --job-file jobs_{job_idx}_{r}.txt --batch-file {job_idx}_{r}.sh {output_option}--partition {PARTITION} --cpus-per-task 1 --mem-per-cpu {MEMORY} -t {TIME} --requeue --submit")
    print(f'job size: {len(job_list)}')
    return


# job runners
def get_base_param(job_name, rs, save_fn):
    return {
        'jd':job_name,
        'rs':rs,
        'save_fn':save_fn,
        'verts':utils.get_verts(rs,normalize=True),
        'maxchunklen': MAXCHUNKLEN,
        'cheb_left':2.0,
        'cheb_right':6.0,
        'nonconvex_penalty_factor':NONCONVEX_PENALTY_FACTOR,
        'nonconvex_threshold':1e-2,
    }

def init(shape, num_verts):
    """
    creates the initialization shape
    """
    rs = utils.init_rads(num_verts,shape)
    save_dir = f'{PROJECT_DIR}/summary'
    os.makedirs(save_dir, exist_ok=True)
    np.save(f'{save_dir}/rs0.npy',rs)
    return 


def run_f0(epoch):
    """
    computes f0
    requires: rs
    """
    job_name = f'f0{epoch}'
    param_dir, result_dir = init_save_dir(job_name)
    save_idx = 0
    job_list = []
    rs = load_result('rs',epoch)
    param_fn, save_fn = get_job_fn(save_idx, job_name)
    param = get_base_param(job_name, rs, save_fn)
    job_list = []
    savemat(param_fn, param)
    if not os.path.isfile(save_fn):
        job_list.append(gen_single_job(param_fn))
    save_idx += 1
    submit_job_list(job_list,save_idx)
    return result_dir, save_idx

def run_gd(epoch):
    """
    computes gradient
    requres: zk-1, rs-1
    """
    job_name = f'gd{epoch}'
    param_dir, result_dir = init_save_dir(job_name)
    rs = load_result('rs',epoch-1)
    rs_old = rs.copy()
    zk = load_result('zk',epoch-1)
    h = 1e-3
    n = len(rs)

    save_idx = 0
    job_list = []
    for i in range(n):
        for direction in [1,-1]:
            rs = rs_old.copy()
            rs[i] += direction*h
            param_fn, save_fn = get_job_fn(save_idx, job_name)
            param = get_base_param(job_name,rs,save_fn)
            param['h'] = h
            param['direction'] = direction
            param['idx'] = i
            param['cheb_left'] = zk*0.9
            param['cheb_right'] = zk*1.1
            savemat(param_fn, param)
            if not os.path.isfile(save_fn):
                job_list.append(gen_single_job(param_fn))
            save_idx += 1
    submit_job_list(job_list,save_idx)
    return result_dir, save_idx

def run_hes(epoch):
    """
    computes gradient
    requres: zk-1, rs-1
    """
    print('deprecated')
    return
    job_name = f'hes{epoch}'
    param_dir, result_dir = init_save_dir(job_name)
    rs = load_result('rs',epoch-1)
    rs_old = rs.copy()
    zk = load_result('zk',epoch-1)
    h = 1e-2
    n = len(rs)

    save_idx = 0
    job_list = []
    for i in range(n):
        for j in range(i+1):
            for i_direction in [1,-1]:
                for j_direction in [1,-1]:
                    rs = rs_old.copy()
                    rs[i] += i_direction*h
                    rs[j] += j_direction*h
                    param_fn, save_fn = get_job_fn(save_idx, job_name)
                    param = get_base_param(job_name,rs,save_fn)
                    param['h'] = h
                    param['i_idx'] = i
                    param['j_idx'] = j
                    param['i_direction'] = i_direction
                    param['j_direction'] = j_direction
                    param['idx'] = i
                    param['cheb_left'] = zk*0.9
                    param['cheb_right'] = zk*1.1
                    savemat(param_fn, param)
                    if not os.path.isfile(save_fn):
                        job_list.append(gen_single_job(param_fn))
                    save_idx += 1
                    if len(job_list)==9999:
                        submit_job_list(job_list,save_idx)
                        job_list = []
    if len(job_list)>0:
        submit_job_list(job_list,save_idx)
    return result_dir, save_idx

def run_fdd(epoch, search_size = 32):
    """
    local line search
    requires: rs-1, zk-1, search_direction
    """
    job_name = f'fdd{epoch}'
    param_dir, result_dir = init_save_dir(job_name)
    rs = load_result('rs',epoch-1)
    rs_old = rs.copy()
    zk = load_result('zk',epoch-1)
    search_direction = load_result('search_direction',epoch)

    save_idx = 0
    job_list = []
    h_list = np.linspace(-1e-2, 1e-2, search_size)
    for h in h_list:
        rs = rs_old.copy()
        rs += search_direction*h
        param_fn, save_fn = get_job_fn(save_idx, job_name)
        param = get_base_param(job_name,rs,save_fn)
        param['h'] = h
        param['cheb_left'] = zk*0.8
        param['cheb_right'] = zk*1.2
        savemat(param_fn, param)
        if not os.path.isfile(save_fn):
            job_list.append(gen_single_job(param_fn))
        save_idx += 1
    submit_job_list(job_list,save_idx)
    return result_dir, save_idx

def run_ls(epoch, start=0.25, search_size=128):
    """
    global line search
    requires: rs-1, search_direction, step
    """
    job_name = f'ls{epoch}'
    param_dir, result_dir = init_save_dir(job_name)
    rs = load_result('rs',epoch-1)
    rs_old = rs.copy()
    zk = load_result('zk',epoch-1)
    search_direction = load_result('search_direction',epoch)
    step = load_result('step',epoch)

    step_list = np.linspace(step*start, step, search_size)
    save_idx = 0
    job_list = []
    for step in step_list:
        rs = rs_old.copy()
        rs -= search_direction*step
        param_fn, save_fn = get_job_fn(save_idx, job_name)
        param = get_base_param(job_name,rs,save_fn)
        param['step'] = step
        param['rs'] = rs
        savemat(param_fn, param)
        if not os.path.isfile(save_fn):
            job_list.append(gen_single_job(param_fn))
        save_idx += 1
    submit_job_list(job_list,save_idx)
    return result_dir, save_idx

epoch = get_curr_epoch()
if epoch==0:
    shape = SHAPE
    num_verts = NUM_VERTS
    init(shape, num_verts)
    fd, nf = run_f0(epoch)
    wait_jobs(fd, nf)
    df_results = utils.extract_results(fd, ['zk','loss'])
    save_result(df_results.iloc[0].zk,'zk',0)
    save_result(df_results.iloc[0].loss,'loss',0)
    epoch += 1

for epoch in range(epoch, MAX_ITER):
    start = time.time()
    # compute gradient
    fd, nf = run_gd(epoch)
    wait_jobs(fd, nf)
    df_results = utils.extract_results(fd, ['h','direction','idx','loss'])
    h = df_results.h.iloc[0]
    grad = np.zeros(NUM_VERTS)
    for i in range(NUM_VERTS):
        fm, fp = df_results[df_results.idx==i].sort_values('direction',ascending=True).loss.to_list()
        grad[i] = (fp-fm)/(2*h)
    save_result(grad,'grad',epoch)
    grad_norm = np.linalg.norm(grad)
    # use hessian if small grad
    search_direction = grad
    if USE_BFGS and epoch>3:
        hinv_prev = load_result('hinv',epoch-1)
        if hinv_prev is None:
            sv = load_result('rs',epoch-2)-load_result('rs',epoch-3)
            yv = load_result('grad',epoch-1)-load_result('grad',epoch-2)
            hinv_prev = np.dot(yv,sv)/np.dot(yv,yv)*np.eye(len(sv))
            save_result(hinv_prev,'hinv',epoch-1)
        sv = load_result('rs',epoch-1)-load_result('rs',epoch-2)
        yv = load_result('grad',epoch)-load_result('grad',epoch-1)
        rho = 1/np.dot(yv,sv)
        idm = np.eye(len(sv))
        hinv = (idm-rho*np.outer(sv,yv))@hinv_prev@(idm-rho*np.outer(yv,sv))+rho*np.outer(sv,sv)
        save_result(hinv,'hinv',epoch)
        search_direction = hinv@grad
    search_direction_norm = np.linalg.norm(search_direction)
    search_direction = search_direction/np.linalg.norm(search_direction)
    save_result(search_direction,'search_direction',epoch)
    # compute max search len
    fd, nf = run_fdd(epoch)
    wait_jobs(fd, nf)
    df_results = utils.extract_results(fd, ['h','loss'])
    xs = np.array(df_results.h.to_list())
    ys = np.array(df_results.loss.to_list())
    a,b,c = np.polyfit(xs,ys,2)
    guess_step = b/(2*a)
    # overshoot a bit
    guess_step *= 2
    rs = load_result('rs',epoch-1)
    if guess_step<0 or np.sum(rs-guess_step*search_direction<1e-2)>0:
        # fall back
        guess_step = search_direction_norm
    save_result(guess_step,'step',epoch)
    # line search
    fd, nf = run_ls(epoch)
    wait_jobs(fd, nf)
    df_results = utils.extract_results(fd, ['step','rs','loss','zk'])
    best_row = df_results.sort_values('loss',ascending=True).iloc[0]
    save_result(best_row.rs,'rs',epoch)
    save_result(best_row.zk,'zk',epoch)
    save_result(best_row.loss,'loss',epoch)
    duration = time.time()-start
    # report
    print(f'Epoch {epoch}: diff {round(best_row.loss+CONST, 6)}, duration {str(datetime.timedelta(seconds=duration))}')