#!/bin/bash
mkdir -p slurm.out
sbatch <<EOT
#!/bin/bash
#SBATCH -p esbirro
#SBATCH --nodes=$2
#SBATCH --exclude=es1
#SBATCH --exclusive
#SBATCH --output=slurm.out/%j.out
#SBATCH --job-name=$2

scontrol show hostnames $SLURM_JOB_NODELIST > machinefile

julia --project job_julia.jl slurm $2 

EOT
