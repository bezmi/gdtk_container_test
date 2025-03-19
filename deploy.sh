#!/usr/bin/env bash

# this script runs on your local machine and deploys the dev container to bunya:
# BUNYA_USER=your_username ./deploy.sh

# specify these if you want them to be different
: "${GDTK_CONTAINER_DEPLOY_PATH:=$BUNYA_USER@bunya.rcc.uq.edu.au:~/}"
: "${GDTK_CONTAINER:=$(pwd)/gdtk_container.sif}"

scp $GDTK_CONTAINER $GDTK_CONTAINER_DEPLOY_PATH
