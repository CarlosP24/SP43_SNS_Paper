#!/bin/bash
sbatch <<EOT
#!/bin/bash
#SBATCH -p esbirro
#SBATCH --nodes=6
#SBATCH --exclude=es1
#SBATCH --exclusive
#SBATCH --time=$4
#SBATCH --output=slurm.out/$2_$3_%j.out
#SBATCH --error=slurm.out/$2_$3_%j.err
#SBATCH --job-name=$2_$3

scontrol show hostnames $SLURM_JOB_NODELIST > machinefile

julia --project job_julia.jl $1 $2 $3
EOT
