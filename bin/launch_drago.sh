#!/bin/bash
source config/prologue.sh
sbatch <<EOT
#!/bin/bash
## Slurm header
#SBATCH --partition=long
#SBATCH --ntasks=500
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=3G
#SBATCH --output="logs/%j.out"
#SBATCH --job-name="${PWD##*/}"
#SBATCH --mail-user=carlos.paya@csic.es
#SBATCH --mail-type=BEGIN,END,FAIL,TIME_LIMIT_80

julia --project bin/launcher.jl "$@"
EOT