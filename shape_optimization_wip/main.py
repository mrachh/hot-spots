import numpy as np
import pandas as pd
from tqdm import tqdm
from time import time

# init matlab engine
import matlab.engine
num_workers = 4
engs = [matlab.engine.start_matlab() for i in range(num_workers)]

np.random.seed(123)
# params
max_iter = 100
num_verts = 8
h = 1e-3
min_rad_schedule = list(np.linspace(0.8, 1e-6, 10)) + list(np.ones(90) * 1e-6)
eps = 1e-3 # gradient norm
beta = 0.7 # line search shrink factor
# init
init = np.ones(num_verts) + np.abs(np.random.normal(scale = 0.05, size = num_verts))
init = init / np.mean(init)
converged = False
epochs = [i for i in range(max_iter)]
rad_optimal = np.copy(init)
num_verts = len(rad_optimal)
loss_params = {'default_chebabs': np.array([ 1., 6.]), 'udnorm_ord': 'inf', 'unorm_ord': '2'}
active_indices = [i for i in range(num_verts)]
# log
log = {
    'rad_optimal':[],
    'verts': [],
    'step_size':[],
    'loss':[],
    'grad_norm':[],
    'gradient':[]
}
def compute_loss(verts):
    return engs[0].loss(verts.T, loss_params, background = False, nargout = 3)
for epoch in tqdm(epochs):    
    if converged:
        break
    min_rad = min_rad_schedule[epoch]
    start = time()
    verts = get_verts(rad_optimal, active_indices)
    loss, chebabs, zk = compute_loss(verts)
    print(f'iter {epoch}; loss {round(loss, 8)}')
    print(f'rad {rad_optimal}')
    print(f'loss computed in {round(time() - start)}')
    # compute gradient
    start = time()
    def compute_loss_local(vertss):
        loss_futures = []
        for i, verts in enumerate(vertss):
            loss_futures.append(engs[i%num_workers].loss(verts.T, loss_params, chebabs, background = True, nargout = 3))
        return [loss_futures[i].result()[0] for i in range(len(loss_futures))]
    vertss = []
    for i in active_indices:
        rad_right = rad_optimal.copy()
        rad_left = rad_optimal.copy()
        rad_right[i] += h
        rad_left[i] -= h
        vertss += [get_verts(rad_left, active_indices), get_verts(rad_right, active_indices)]
    losses = compute_loss_local(vertss)
    losses_left = np.array(losses[::2])
    losses_right = np.array(losses[1::2])
    active_gradient = (losses_right-losses_left) / (h*2)
    gradient = np.zeros(num_verts)
    for idx, deri in zip(active_indices, list(active_gradient)):
        gradient[idx] = deri
    grad_norm = np.linalg.norm(gradient)
    print(f'gradient {[round(i, 8) for i in gradient]}')
    print(f'gradient norm {round(grad_norm, 8)} computed in {round(time() - start)}')
    # check convergence:
    if grad_norm < eps:
        converged = True
    # compute second derivative at gradient direction
    start = time()
    vertss = [get_verts(rad, active_indices) for rad in [rad_optimal-h*gradient, rad_optimal+h*gradient]]
    loss_left, loss_right = compute_loss_local(vertss)
    loss_center = loss
    second_derivative = (loss_right-2*loss_center+loss_left)/(h**2)
    print(f'second derivative computed in {round(time() - start)}')
    # line search
    start = time()
    if second_derivative > 0:
        step_size = 1.0 / second_derivative
    else:
        step_size = 1.0
    print(f'second derivative {second_derivative}')
    ## check linear constraints on active indices
    rad = rad_optimal-step_size*gradient
    linear_constraint_satisfied = np.all(rad[active_indices]/np.mean(rad[active_indices])>min_rad)
    linear_constraint_satisfied &= np.all(rad[active_indices]>0)
    linear_constraint_satisfied &= check_convex(get_verts(rad, active_indices))
    while not linear_constraint_satisfied:
        step_size *= beta
        rad = rad_optimal-step_size*gradient
        linear_constraint_satisfied = np.all(rad[active_indices]/np.mean(rad[active_indices])>min_rad)
        linear_constraint_satisfied &= np.all(rad[active_indices]>0)
        linear_constraint_satisfied &= check_convex(get_verts(rad, active_indices))
    ## start line search
    line_search_converged = False
    line_search_failed = False
    while not line_search_converged:
        rad = rad_optimal.copy()
        rad -= step_size * gradient
        verts = get_verts(rad, active_indices)
        if step_size * grad_norm < 1e-2:
            loss_next = compute_loss_local([verts])[0]
        else:
            loss_next = compute_loss(verts)[0]
        if loss_next < loss:
            line_search_converged = True
        elif step_size * grad_norm < 1e-4:
            line_search_converged = True
            line_search_failed = True
            step_size = 0
        else:
            step_size *= beta
    rad_optimal -= step_size * gradient
    # normalize on active indices
    normalizer = np.mean([rad_optimal[i] for i in active_indices])
    for i in active_indices:
        rad_optimal[i] = rad_optimal[i] / normalizer
    # update active indices
    active_indices = get_active_indices(rad_optimal)
    for i in range(num_verts):
        if i not in active_indices:
            rad_optimal[i] = 1e-6
    print('active indices', active_indices)
    if line_search_failed:
        converged = True
    print(f'line search converged in {time() - start}')
    # log
    log['rad_optimal'].append(rad_optimal.copy())
    log['grad_norm'].append(grad_norm)
    log['step_size'].append(step_size)
    log['gradient'].append(gradient.copy())
    log['loss'].append(loss)
    log['verts'].append(verts)