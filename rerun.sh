# ----------------------------- DESCRIPTION -----------------------------
#
# This script runs the LAMMPS simulations included in this repository.
# It performs the following tasks:
#
#	1. Downloads the version of OCTP and LAMMPS with which the simulations
#		were originally ran
#	3. Compiles LAMMPS with the OCTP plugin (no OpenMPI support)
#	4. Runs the simulations
#	
# Dependencies:
#	
#	LAMMPS dependencies: git, make, GNU c, c++ and fortran compilers
#	
#	For the most part, LAMMPS will download all required 3rd party
#	dependencies as part of the build process.
#
# Input: 
#	
#	None
#
# Output:
#
# 	Simulation input and output files will be placed in new directories with
#	the name "-rerun" appended.
#
# Example:
#
#	The lj directory contains the LAMMPS input and output files of a simulation
#	that uses a Leonard Jones potential. 
#	This script will rerun the simulation using the version of LAMMPS and OCTP
#	that was originally used.
# 	The input and output files of the new simulation will be placed in the
# 	lj-rerun directory.
#

repopath=$(pwd)

# standout fonts
font_progress='\033[1;32m'	# bold green
font_error='\033[1;31m'		# bold red
font_regular='\033[0m' 		# no color

# download lammps release
printf "${font_progress}Downloading LAMMPS\n"
git clone https://github.com/lammps/lammps.git
cd lammps
git checkout stable_23Jun2022_update4
cd src

# download OCTP plugin files
printf "${font_progress}Downloading OCTP plugin files\n"
wget https://raw.githubusercontent.com/omoultosEthTuDelft/OCTP/0febdc2e32a3cfe1f27ec06e4ad9756ee861ba8a/compute_position.cpp
wget https://raw.githubusercontent.com/omoultosEthTuDelft/OCTP/0febdc2e32a3cfe1f27ec06e4ad9756ee861ba8a/compute_position.h
wget https://raw.githubusercontent.com/omoultosEthTuDelft/OCTP/0febdc2e32a3cfe1f27ec06e4ad9756ee861ba8a/compute_rdf_ext.cpp
wget https://raw.githubusercontent.com/omoultosEthTuDelft/OCTP/0febdc2e32a3cfe1f27ec06e4ad9756ee861ba8a/compute_rdf_ext.h
wget https://raw.githubusercontent.com/omoultosEthTuDelft/OCTP/0febdc2e32a3cfe1f27ec06e4ad9756ee861ba8a/fix_ordern.cpp
wget https://raw.githubusercontent.com/omoultosEthTuDelft/OCTP/0febdc2e32a3cfe1f27ec06e4ad9756ee861ba8a/fix_ordern.h

# build lammps with the octp plugin
printf "${font_progress}Building LAMMPS\n"
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
	printf "${font_error}Error building LAMMPS\nDeleting tmp files\n"
    cd $repopath
    rm -rf lammps/
   printf "${font_error}Aborting script\n" 
    exit 1
fi
printf "${font_progress}LAMMPS was successfully built\n"

# Re-run simulations
cd $repopath
for simdir in lj
do
	# Delete preexisting directories if they exist
	if [ -d $simdir-rerun ]; then
		printf "${font_progress}Deleting ${simdir}-rerun directory\n"
		rm -rf $simdir-rerun;
	fi
	# Create output directory and copy LAMMPS input files
	mkdir $simdir-rerun
	cp $simdir/input* $simdir-rerun
	# Run the simulation
	printf "${font_progress}Running ${simdir}\n"
	lammps_path -in input_simulation.in
done
