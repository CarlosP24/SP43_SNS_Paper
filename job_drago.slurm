#!/bin/bash
mkdir -p slurm.out
sbatch <<EOT
#!/bin/bash
#SBATCH --partition=long
#SBATCH --nodes=20
#SBATCH --mem-per-cpu=60GB
#SBATCH --time=02-00:00:00
#SBATCH --output=slurm.out/$1_$2_%j.out
#SBATCH --error=slurm.out/$1_$2_%j.err
#SBATCH --job-name=$1_$2

scontrol show hostnames $SLURM_JOB_NODELIST > machinefile

julia --project job_julia_PD.jl $1 $2
EOT