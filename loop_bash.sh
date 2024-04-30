#!/bin/bash
# 1 is geometry, 2 is model, 3 is time limit
for L in 500 1000 1500
do
bash job.slurm $1 $2 $L $3
done