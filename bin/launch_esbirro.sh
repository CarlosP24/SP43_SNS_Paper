#!/bin/bash
source config/prologue.sh
sbatch <<EOT
#!/bin/bash
## Slurm header
#SBATCH --partition=esbirro
#SBATCH --ntasks-per-node=32
#SBATCH --nodes=6
#SBATCH --cpus-per-task=1
##SBATCH --mem-per-cpu=2G
#SBATCH --output="logs/%j.out"
#SBATCH --job-name="${PWD##*/}_$1"
#SBATCH --mail-user=carlos.paya@csic.es
#SBATCH --mail-type=END,FAIL

julia --project bin/launcher.jl "$@"
EOT