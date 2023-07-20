#!/bin/bash

# 512 particles
# 8x8x8

ts_str=('100K' '500K' '1M' '5M' '10M' '25M' '50M' '100M')
ts_num=(100000 500000 1000000 5000000 10000000 25000000 50000000 100000000)

ts_str0=('100K' '500K')
ts_num0=(100000 500000)

it=0

for i in $ts_str0
do
    for j in 0
    do
        # create simulation directory
        dirname=512p_${i}ts_16mpi_run${j}
        mkdir ${dirname}
        cd $dirname

        # copy simulation files to simulation directory
        #cp ../../data.lmp .
        #cp ../../forcefield.data .
        cp ../../simulation.in .
        #cp ../../runsim.sh .

        # edit number of particles and timesteps
        jobname=512p-${i}-${j}
        #sed -i 's/JOBNAME/'${jobname}'/' runsim.sh
        #sed -i 's/RUNTIME/'${ts_num[$it]}'/' simulation.in
        sed -i 's/NPART\ NPART\ NPART/512\ 512\ 512/' simulation.in

        cd ..
    done
    it=${it+1}
done