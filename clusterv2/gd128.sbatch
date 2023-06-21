#!/bin/bash
#SBATCH --job-name gd128_230522
#SBATCH --partition week
#SBATCH --cpus-per-task 8
#SBATCH --mem 16G
#SBATCH -t 7-00:00:00
#SBATCH --output=out/gd128.log


module load MATLAB/2022b
matlab -batch "gd128"
