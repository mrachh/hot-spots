#!/bin/bash
#SBATCH --job-name gd64_230616
#SBATCH --partition day
#SBATCH --cpus-per-task 4
#SBATCH --mem 16G
#SBATCH -t 10:00:00
#SBATCH --output=out/gd8.log


module load MATLAB/2022b
matlab -batch "gd64"
