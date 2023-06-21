#!/bin/bash
#SBATCH --job-name gd64_230616
#SBATCH --partition day
#SBATCH --cpus-per-task 8
#SBATCH --mem 16G
#SBATCH -t 1-00:00:00
#SBATCH --output=out/gd64.log


module load MATLAB/2022b
matlab -batch "gd64"
