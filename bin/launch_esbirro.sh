#!/bin/bash
source config/prologue.sh
if [ $? -ne 0 ]; then
  exit 1
fi
# Store all command-line arguments in an array
sbatch "$@" <<- 'EOT'
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

PARAMS=("$@")
# Access the parameter for this specific job based on SLURM_ARRAY_TASK_ID
PARAM="${PARAMS[$SLURM_ARRAY_TASK_ID]}"

julia --project bin/launcher.jl "$PARAM"

EOT