#!/bin/bash
mkdir -p slurm.out
sbatch <<EOT
#!/bin/bash
#SBATCH -p esbirro
#SBATCH --nodes=$1
#SBATCH --exclude=es1
#SBATCH --exclusive
#SBATCH --output=slurm.out/%j.out
#SBATCH --job-name=Jdisorder

scontrol show hostnames $SLURM_JOB_NODELIST > machinefile

julia --project job_julia_Jd.jl
EOT