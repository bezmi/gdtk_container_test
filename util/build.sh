#!/usr/bin/env bash

# this script runs on your local machine and builds the container:
# ./build.sh

# specify these if you want them to be different
: "${GDTK_CONTAINER:=$(pwd)/gdtk_container.sif}"

apptainer build $GDTK_CONTAINER gdtk_container.def
