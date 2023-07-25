#!/bin/bash
# --------------------------- DESCRIPTION ---------------------------
# A script to facilitate the benchmarking of OCTP. It creates
# simulation directories and submits Slurm jobs for the following
# configurations:
#
# Number of particles:
#	512  1K  4K  10K  27K  50K  97K
#
# Number of time steps:
#	100K  500K  1M  5M  10M  25M  50M  100M
#
# Each simulation is run 3 times, yielding a total of 168 slurm jobs.
# Simulations are organized per number of particles, for example:
#	> createSimulationDirectories '512' 8
#	> runSimulations 512
# will create the directories and run all the the simulations for
# 512 particles.



# --------------- FUNCTION CREATESIMULATIONDIRECTORIES --------------
# Creates simulation directories
# param 1 str	number of particles (eg '512', '4K')
# param 2 int	size of box (eg 8, 16)	
#
# Generated directories have the name:
# 	<np>/<np>p_<nts>ts_16mpi_run<nrun>
# where:
#	<np>	: number of particles (param 1)
#	<nts>	: number of time steps (eg 5M)
#	<nrun>	: simulation number (0, 1, 2)
#
# The following files are copied from the parent directory
# and modified as indicated:
#	forcefield.data	no modifications
#	data.lmp		no modifications
#	runsim.sh		JOBNAME : <np>-<nts>-<nrun>
#	simulation.in	RUNTIME : <nts> (int)
#					NPART	: <param 2>
#
createSimulationDirectories () {
    mkdir ${1}p
	cd ${1}p

	ts_num=(100000 500000 1000000 5000000 10000000 25000000 50000000 100000000)
    it=0

    for i in '100K' '500K' '1M' '5M' '10M' '25M' '50M' '100M'
	do
    	for j in 0 1 2
    	do
        	# create simulation directory
        	dirname=${1}p_${i}ts_16mpi_run${j}
        	mkdir ${dirname}
        	cd $dirname

        	# copy simulation files to simulation directory
        	cp ../../data.lmp .
        	cp ../../forcefield.data .
        	cp ../../simulation.in .
        	cp ../../runsim.sh .

        	# edit number of particles and timesteps
        	jobname=${1}-${i}-${j}
        	sed -i 's/JOBNAME/'${jobname}'/' runsim.sh
        	sed -i 's/RUNTIME/'${ts_num[$it]}'/' simulation.in
        	sed -i 's/NPART\ NPART\ NPART/'$2'\ '$2'\ '$2'/' simulation.in

        	cd ..
    	done
    	it=$((it+1))
	done

	cd ..
}



# --------------------- FUNCTION RUNSIMULATIONS ---------------------
# Submits jobs to Slurm via sbatch
# param 1 str	number of particles (eg '512', '4K')
#
# Access the directories generated with createSimulationDirectories
# function and submit a job using the runsim.sh batch script
runSimulations () {
    cd ${1}p
	for i in '100K' '500K' '1M' '5M' '10M' '25M' '50M' '100M'
	do
		for j in 0 1 2
    	do
			dirname=${1}p_${i}ts_16mpi_run${j}
			cd $dirname
			sbatch runsim.sh
			cd ..
		done
	done
	cd ..
}



# 512	8
# 1K	10
# 4K	16
# 10K	22
# 27K	30
# 50K	37
# 97K	46

createSimulationDirectories '512' 8
#createSimulationDirectories '1K' 10
#createSimulationDirectories '4K' 16

runSimulations 512
