#!/bin/bash
mkdir -p slurm.out
sbatch <<EOT
#!/bin/bash
#SBATCH -p esbirro
#SBATCH --nodes=$3
#SBATCH --exclude=es1
#SBATCH --exclusive
#SBATCH --output=slurm.out/$1_$2_%j.out
#SBATCH --error=slurm.out/$1_$2_%j.err
#SBATCH --job-name=$1_$2

scontrol show hostnames $SLURM_JOB_NODELIST > machinefile

julia --project job_julia.jl $1 $2
EOT
