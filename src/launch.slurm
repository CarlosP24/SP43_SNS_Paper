#!/bin/bash
mkdir -p slurm.out
sbatch <<EOT
#!/bin/bash
#SBATCH -p esbirro
#SBATCH --nodes=$2
#SBATCH --exclude=es1
#SBATCH --exclusive
#SBATCH --output=slurm.out/%j.out
#SBATCH --job-name=$1

scontrol show hostnames $SLURM_JOB_NODELIST > machinefile

julia --project main.jl slurm $1

EOT
