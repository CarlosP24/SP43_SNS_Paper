#!/bin/bash
mkdir -p slurm.out
sbatch <<EOT
#!/bin/bash
#SBATCH -p all
#SBATCH --nodes=$3
#SBATCH --exclude=es1,f1
#SBATCH --exclusive
#SBATCH --output=slurm.out/%j.out
#SBATCH --job-name=Rmismatch

scontrol show hostnames $SLURM_JOB_NODELIST > machinefile

julia --project job_julia_J.jl $1 $2
EOT