#!/bin/bash
source config/prologue.sh
sbatch <<EOT
#!/bin/bash
## Slurm header
#SBATCH --partition=long
#SBATCH --ntasks=400
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=2G
#SBATCH --output="logs/%j.out"
#SBATCH --job-name="${PWD##*/}_$1"
#SBATCH --mail-user=carlos.paya@csic.es
#SBATCH --mail-type=BEGIN,END,FAIL,TIME_LIMIT_80

julia --project bin/launcher.jl "$@"
EOT