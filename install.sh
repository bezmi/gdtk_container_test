#!/usr/bin/env bash

# GDTK_CONTAINER_DIR is a location that will contain all relevant files, including the container and lmr installation
: "${GDTK_CONTAINER_DIR:=$HOME/.local/share/gdtk_container}"

if [[ -z $GDTK_CONTAINER_DIR ]]; then
    echo "GDTK_CONTAINER_DIR is not set"
    exit 1
fi

# Check directory existence
if [ -d "$GDTK_CONTAINER_DIR" ]; then
    while true; do
        read -p "Directory '$GDTK_CONTAINER_DIR' exists. Overwrite contents? (y/N) " yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* | '' ) echo "Installation aborted"; exit 1;;
        esac
    done
fi

rm -rf $GDTK_CONTAINER_DIR

echo "Creating directory $GDTK_CONTAINER_DIR"
mkdir -p $GDTK_CONTAINER_DIR

GDTK_CONTAINER=$GDTK_CONTAINER_DIR/gdtk_container.sif

echo
if [ ! -z "$1" ]; then
    echo "Copying local gdtk_container sif to $GDTK_CONTAINER"
    cp $1 $GDTK_CONTAINER
else
    echo "Pulling container into $GDTK_CONTAINER"
    apptainer pull $GDTK_CONTAINER oras://ghcr.io/bezmi/gdtk_container_test:latest
fi

do_install_bin() {
    echo "Creating directory $GDTK_CONTAINER_DIR/bin"
    mkdir -p $GDTK_CONTAINER_DIR/bin


    TARGET_REPO_HTTPS=https://github.com/bezmi/gdtk_container_test
    TARGET_REPO_SSH=git@github.com:bezmi/gdtk_container_test

    clone_tmp_repo() {
        echo "Not in repository. Cloning temporarily to copy bin files..."
        TEMP_CLONE_DIR=$(mktemp -d -t gdtk_container_test-XXXXX)
        # Function to clean up temporary directory
        cleanup() {
            rm -rf "$TEMP_CLONE_DIR"
            echo "Cleaned up temporary files"
        }

        # Clone repository if not in correct repo
        git clone --depth 1 "$TARGET_REPO_HTTPS" "$TEMP_CLONE_DIR" || {
            echo "Failed to clone repository"
            cleanup
            exit 1
        }

        # Copy files from cloned repo
        if [ -d "$TEMP_CLONE_DIR/bin" ]; then
            cp -r "$TEMP_CLONE_DIR/bin" "$GDTK_CONTAINER_DIR" || {
                echo "Failed to copy files from cloned repository"
                cleanup
                exit 1
            }
            echo "Files successfully copied from temporary clone"
        else
            echo "Bin directory not found in repository"
            cleanup
            exit 1
        fi

        cleanup
    }

    # Check if we're in the correct repository
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        CURRENT_REPO=$(git config --get remote.origin.url)
        if [ $CURRENT_REPO=$TARGET_REPO_HTTPS ] || [ $CURRENT_REPO=$TARGET_REPO_SSH]; then
            echo "Copying bin files from this repository"
            cp -r ./bin $GDTK_CONTAINER_DIR || {
                echo "Failed to copy files from local bin directory"
                exit 1
            }
        else
            clone_tmp_repo
        fi
    else
        clone_tmp_repo
    fi
}

echo
while true; do
    read -p "Would you like to install the wrapper scripts to '$GDTK_CONTAINER_DIR/bin'? (Y/n) " yn
    case $yn in
        [Yy]* | '' ) do_install_bin; break;;
        [Nn]* ) break;;
    esac
done

echo
while true; do
    read -p "Build and install lmr now? (Y/n) " yn
    case $yn in
        [Yy]* | '' ) echo "Building and installing lmr: apptainer run $GDTK_CONTAINER"; apptainer run $GDTK_CONTAINER; break;;
        [Nn]* ) echo "Make sure you run: 'apptainer run $GDTK_CONTAINER' at some point"; break;;
    esac
done

echo 'export GDTK_CONTAINER='"$GDTK_CONTAINER" >> $GDTK_CONTAINER_DIR/env
echo 'export PATH='"${GDTK_CONTAINER_DIR}"'/bin:$PATH' >> $GDTK_CONTAINER_DIR/env

echo
echo "Installation complete. Run 'source $GDTK_CONTAINER_DIR/env' to update your PATH"


