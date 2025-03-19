#!/usr/bin/env bash

# this script runs on your local machine and deploys the dev container to bunya:
# BUNYA_USER=your_username ./deploy.sh
#
# It also deploys test.sh to the same location

# specify these if you want them to be different
: "${GDTK_CONTAINER_DEPLOY_PATH:=$BUNYA_USER@bunya.rcc.uq.edu.au:~/}"
: "${GDTK_CONTAINER:=$(pwd)/gdtk_container.sif}"
: "${TEST_SCRIPT:=$(pwd)/test.sh}"

echo $GDTK_CONTAINER
echo $GDTK_CONTAINER_DEPLOY_PATH
scp $GDTK_CONTAINER $TEST_SCRIPT $GDTK_CONTAINER_DEPLOY_PATH
