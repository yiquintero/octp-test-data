#!/bin/bash
# ----------------------------- DESCRIPTION -----------------------------
#
# This script runs the LAMMPS simulations included in this repository.
# It performs the following tasks:
#
#	1. Loads the necessary Delft Blue modules needed to compile and run LAMMPS.
#   2. Downloads the version of OCTP and LAMMPS with which the simulations
#       were originally ran
#	3. Compiles LAMMPS with the OCTP plugin (OpenMPI support)
#	4. Runs the simulations using the srun command
#	
# Input:
#
#   None
#
# Output:
#
#   Simulation input and output files will be placed in new directories with
#   the name "-rerun" appended.
#
# Example:
#
#   The lj directory contains the LAMMPS input and output files of a simulation
#   that uses a Leonard Jones potential. 
#   This script will rerun the simulation using the version of LAMMPS and OCTP
#   that was originally used.
#   The input and output files of the new simulation will be placed in the
#   lj-rerun directory.
#

repopath=$(pwd)

# standout fonts
font_progress='\033[1;32m'  # bold green
font_error='\033[1;31m'     # bold red
font_regular='\033[0m'      # no color


# download lammps release
if [ ! -d lammps ]; then
    printf "${font_progress} $ts Downloading LAMMPS $ts ${nocolor} \n"
    git clone https://github.com/lammps/lammps.git
else
    printf "${font_progress} $ts Using existing LAMMPS code $ts ${nocolor} \n"
fi
cd lammps
git checkout stable_23Jun2022_update4
cd src


# download OCTP plugin files
printf "${font_progress} $ts Downloading OCTP plugin files $ts ${nocolor} \n"
for octpfile in compute_position.cpp compute_position.h compute_rdf_ext.cpp compute_rdf_ext.h fix_ordern.cpp fix_ordern.h
do
    # Delete file if it already exists
    if [ -f $octpfile ]; then rm -f $octpfile; fi
    # Download file
    wget https://raw.githubusercontent.com/omoultosEthTuDelft/OCTP/0febdc2e32a3cfe1f27ec06e4ad9756ee861ba8a/$octpfile
done


# load DelftBlue modules needed to compile and run lammps
printf "${font_progress} $ts Loading 2022r2 and openmpi modules $ts ${nocolor} \n"
module load 2022r2
module load openmpi


# build lammps with the octp plugin
printf "${font_progress} $ts Building LAMMPS $ts ${nocolor} \n"
make yes-asphere
make yes-body
make yes-class2
make yes-dipole
make yes-granular
make yes-kspace
make yes-manybody
make yes-molecule
make yes-rigid
make yes-shock
make serial


# check if lammps compilation was successful; if not, exit script
lammps_path=$(pwd)/lmp_serial
if [ ! -f "$lammps_path" ]; then
    cd $repopath
    printf "${font_error} $ts Error building LAMMPS $ts ${nocolor} \n"
    printf "${font_error} $ts Aborting script $ts ${nocolor} \n" 
    exit 1
fi
printf "${font_progress} $ts LAMMPS was successfully built $ts ${nocolor} \n"


# Re-run simulations

#SBATCH --job-name="octp-test"  
#SBATCH -n 8                    # number of cpu cores
#SBATCH -t 01:00:00             # max job time hh:mm:ss
#SBATCH --mem-per-cpu=1G        # ram memory allocated per cpu

# Re-run simulations
cd $repopath
for simdir in lj
do
    # Delete preexisting directories if they exist
    if [ -d $simdir-rerun ]; then
        printf "${font_progress} $ts Deleting ${simdir}-rerun directory $ts ${nocolor} \n"
        rm -rf $simdir-rerun;
    fi
    # Create output directory and copy LAMMPS input files
    mkdir $simdir-rerun
    cp $simdir/input* $simdir-rerun
    # Run the simulation
    printf "${font_progress} $ts Running ${simdir} simulation $ts ${nocolor} \n"
    cd $simdir-rerun
    $lammps_path -in input_simulation.in
done


wait
exit 0
