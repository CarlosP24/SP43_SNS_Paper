#!/bin/bash
source config/prologue.sh
if [ $? -ne 0 ]; then
  exit 1
fi
# Define the array
PARAMS=("reference_metal_1" "reference_dep_1")

# Serialize the array into a string
PARAMS_STR=$(IFS=,; echo "${PARAMS[*]}")

# Store all command-line arguments in an array
sbatch --export=ALL <<EOT
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

IFS=, read -r -a PARAMS <<< "\$PARAMS_STR"

PARAM="\${PARAMS[\$SLURM_ARRAY_TASK_ID-1]}"

echo "Running with PARAM: \$PARAM"

julia --project bin/launcher.jl "\$PARAM"

EOT