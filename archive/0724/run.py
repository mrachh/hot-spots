import sys, os
from itertools import product

fn = 'tmp.sbatch'

def generate_batch_file(ry_ratio, cy_ratio, idx):
    return f'''#!/bin/bash
#SBATCH --job-name so0724-ellipse_gd-{idx}
#SBATCH --partition week
#SBATCH --cpus-per-task 16
#SBATCH --mem 8G
#SBATCH -t 7-00:00:00
#SBATCH --output=out/{idx}.log
module load MATLAB/2022b
matlab -batch \"gd_ellipse({ry_ratio},{cy_ratio},{idx})\"
'''

ellipse_configs = [[0.5, 0.9], [3, 0.9], [0.25, 0.9], [1.5, 0.5], [2, 0]]

idx = 0
for ry_ratio, cy_ratio in ellipse_configs:
    idx += 1
    os.system(f"rm -f {fn}")
    with open(fn,'w+') as f:
        f.write(generate_batch_file(ry_ratio, cy_ratio, idx))
    os.system(f'sbatch {fn}')
    os.system(f"rm -f {fn}")
