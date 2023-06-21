# OCTP Test Data Repository
This repository contains a collection of LAMMPS input and output files that can be used to test the [OCTP plugin](https://github.com/omoultosEthTuDelft/OCTP).

Each folder contains the input and output files of a single LAMMPS simulation. All data was generated with:
- [LAMMPS - June 2022 stable release](https://github.com/lammps/lammps/releases/tag/stable_23Jun2022_update4)
- [OCTP - commit 2be3bee](https://github.com/omoultosEthTuDelft/OCTP/tree/2be3beea803827fd31015420200795f1c00f2d08)

See the run.sh script for more details on how the output files of each simulation were generated.

## Usage
This repository is read-only. Its sole purpose is to store the gold-standard data against which the OCTP plugin is tested. All of the tests are configured and administered in the OCTP repository.

## Running the Simulations
For documentation purposes, two shell scripts that run the simulations are included. Both scripts build LAMMPS with the OCTP plugin from scratch and run all the simulations in this repo.
- **run.sh** - run the simulations in a local Linux machine; LAMMPS is built in serial mode without OpenMPI support
- **run_delftblue.sh** - run the simulations in the DelftBlue supercomputer; LAMMPS is built in parallel mode with OpenMPI support

The output data generated by the OCTP plugin should be the same regardles of OpenMPI support.

To run the simulations:

**On your local Linux machine - LAMMPS built without MPI support**
```sh
git clone https://github.com/yiquintero/octp-test-data.git
cd octp-test-data
chmod +x rerun.sh
./rerun.sh
```

**On DelftBlue supercomputer - LAMMPS built with MPI support**
```sh
git clone https://github.com/yiquintero/octp-test-data.git
cd octp-test-data
sbatch rerun_delftblue.sh
```
