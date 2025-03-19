#!/usr/bin/env bash

# this script runs on your local machine and builds the container:
# ./build.sh

# specify these if you want them to be different
: "${GDTK_CONTAINER:=$(pwd)/gdtk_container.sif}"
: "${GDTK_DATA:=~/.local/share/gdtk_container}"
: "${GDTK_OPENMPI_MAJOR_VERSION:=v5.0}"
: "${GDTK_OPENMPI_RELEASE_NAME:=openmpi-5.0.3}"

apptainer build \
--build-arg openmpi_major_version=$GDTK_OPENMPI_MAJOR_VERSION \
--build-arg openmpi_release_name=$GDTK_OPENMPI_RELEASE_NAME \
--build-arg data_dir=$GDTK_DATA \
$GDTK_CONTAINER gdtk_container.def
