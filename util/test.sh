#!/usr/bin/env bash

# this script can be run on bunya to run a simulation

# specify these if they're different
: "${GDTK_CONTAINER:=$HOME/.local/share/gdtk_container/gdtk_container.sif}"
: "${GDTK_DATA:=$HOME/.local/share/gdtk_container/data}"

# NOTE: before running this on Bunya, you should have an interactive session and the openmpi module loaded:
#    salloc --nodes=1 --ntasks-per-node=48 --mem=64G --time=1:00:00 --job-name=lmr-apptainer-test --partition=general --account=<account_string>
#    srun --export=PATH,TERM,HOME,LANG --pty /bin/bash -l
#    module load openmpi

# For testing purposes, remove existing installation and repo
rm ${GDTK_DATA}/* -rf

# the container's runscript clones, builds and installs lmr
apptainer run ${GDTK_CONTAINER}

# Run the 2D convec-corner mpi test case
cd ${GDTK_DATA}/gdtk/examples/lmr/2D/convex-corner/two-block-mpi

# prep
apptainer exec ${GDTK_CONTAINER} lmr prep-gas -i ideal-air.lua -o ideal-air.gas
apptainer exec ${GDTK_CONTAINER} lmr prep-grid
apptainer exec ${GDTK_CONTAINER} lmr prep-sim

# call the mpi binary inside the container with mpirun
mpirun -np 2 apptainer exec ${GDTK_CONTAINER} lmrZ-mpi-run
