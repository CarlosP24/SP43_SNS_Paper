#!/bin/bash
source config/prologue.sh
if [ $? -ne 0 ]; then
  exit 1
fi
sbatch <<EOT
#!/bin/bash
## Slurm header
#SBATCH --partition=esbirro
#SBATCH --ntasks-per-node=32
#SBATCH --nodes=2
#SBATCH --cpus-per-task=1
##SBATCH --mem-per-cpu=2G
#SBATCH --output="logs/%j.out"
#SBATCH --job-name="${PWD##*/}_$1"
#SBATCH --mail-user=carlos.paya@csic.es
#SBATCH --mail-type=END,FAIL
#SBATCH --array=1-2

if [[ $SLURM_ARRAY_TASK_ID -eq 1 ]]; then
    ARG=$1
elif [[ $SLURM_ARRAY_TASK_ID -eq 2 ]]; then
    ARG=$2
fi

echo $ARG

julia --project bin/launcher.jl $ARG

EOT