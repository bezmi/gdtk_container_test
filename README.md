This is a test repository for a development container of gdtk.
The container debian 12 and includes the latest `gcc` distribution, the latest `ldc`, `dub` and a recent version of openmpi.

Running the container builds and installs `lmr`.

This container is set up to use the hybrid openmpi approach described in the apptainer docs. It should be very easy to convert it to use the bind based approach as long as the HPC system has a sane layout for the location of the openmpi binaries and libraries.

# Quickstart (Install script)
<details>

<summary>A note for users building on the Bunya HPC cluster</summary>

if you're on Bunya, then you need to do this from a compute node. The login node doesn't have apptainer. See the `test.sh` script for more details.

</details>

Run the install script with the command below, or clone this repo and run `install.sh`
```sh
bash <(wget -qO - https://raw.githubusercontent.com/bezmi/gdtk_container_test/refs/heads/main/install.sh)
```
This will put the container and all related files in `$HOME/.local/share/gdtk_container`


Running `source $HOME/.local/share/gdtk_container/env` will add the wrapper scripts to your `PATH`, so calling `lmr` executables (`lmr`, `lmr-run`, `lmrZ-run`, etc) will automatically prefix the commands to run them in the container.

<details>

<summary>List of executables that are currently wrapped</summary>

- `lmr` (also: `lmr-debug`)
- `lmr-verify`
- `lmr-run` (also: `lmrZ-run`, `lmr-mpi-run`, `lmrZ-mpi-run`)
- `prep-chem`, `prep-gas`, `prep-kinetics`
- `ugrid_partition`, `species-data-converter`, `chemkin2eilmer`
- `dgd-lua`, `dgd-luac`
- `python3` (also: `python`, which is just a symlink to `python3`)

</details>

<details>

<summary>My program isn't in the list of wrapped executables. How do I run an arbitrary executable within the container?</summary>

`lmr-wrapper <path-to-executable-in-container>` can be used to run an arbitrary executable in the container, as long as it is accessible from inside the container. This script is located in the `bin` directory within `~/.local/share/gdtk_container`.
By default the host user `$HOME` directory is accessible at the same location from inside the container, [but other directories might need to use the correct bind arguments when running this command](https://apptainer.org/docs/user/main/bind_paths_and_mounts.html)

You can also just use `apptainer exec <path-to-executable-in-container>`.

</details>

<details>

<summary>How do I start a shell within the container?</summary>

You can run `apptainer shell $HOME/.local/share/gdtk_container/gdtk_container.sif`.
Alternatively, `lmr-shell` is a shorthand if you installed the helper executables.

</details>

## Making changes to the `lmr` source code
This container can be used for development or `lmr`.

First, ensure that `apptainer run $GDTK_CONTAINER` has been called (NOTE: `$GDTK_CONTAINER` is only available if you sourced the `env` file following the instructions above. Use `$HOME/.local/share/gdtk_container/gdtk_container.sif` if you didn't).

You can now access and modify the source code from the host at `$HOME/.local/share/gdtk_container/data/gdtk`. Using `apptainer run $GDTK_CONTAINER` will rebuild and reinstall the updated `lmr`
The `lmr-build` command is a shorthand for this.

## If you built the container locally
Provide the path to the built `gdtk_container.sif` as a single argument to `install.sh`.
It will use this path instead of pulling the container from the container repository.

If you want to use it without cloning the repo:
```sh
bash <(wget -qO - https://raw.githubusercontent.com/bezmi/gdtk_container_test/refs/heads/main/install.sh) /path/to/gdtk_container.sif

```

# Installing manually from github container repository
<details>

<summary>NOTE: not recommended</summary>

But if you must, [then calling the install script with the built container will give you the extra goodies](#if-you-built-the-container-locally)

</details>

First, pull the container from `ghcr`:
```sh
apptainer pull gdtk_container.sif oras://ghcr.io/bezmi/gdtk_container_test:latest
```

There should be a compressed container image in the directory where you ran the command above. Now you can run the container:
```sh
apptainer run gdtk_container.sif
```

# Utility scripts and tips
- `util/build.sh` will build the container should be run on your local workstation.

# Building the dev container locally.
NOTE: this may take a while as the openmpi library must be compiled.

If you want to change openmpi versions, gdtk install path or the `gcc`, `ldc` or `dub` versions, then you should build locally.

First, clone this repo
Run this step locally. The generated container can then be used anywhere.
```sh
apptainer build <container-name>.sif gdtk_container.def
```

The container, named `<container-name>.sif` will be present in the directory.

For development purposes, use `--sandbox`:
```sh
apptainer build --sandbox <container-name> gdtk_container.def
```
This will build the container as a directory structure instead of the compressed container file.

If you previously built a container without sandbox, you can convert the `.sif` to a sandbox one with
```sh
apptainer build --sandbox <sandbox_container_name> <container-name>.sif
```
I think it also works the other way around.

appending `--writable` to commands such as `run` and `shell` will allow changes to the file structure to be persistent, however, when rebuilding the container the changes will be lost, so an apptainer `def` file to build the container is recommended instead.

Best practice is use `--writable` when developing/creating the container, then add them to the definition file when you're happy.

## Build options
See the `%arguments` section of `gdtk_container.def`.
For example, to change the openmpi version that gets downloaded and installed, you can do
```sh
apptainer build --build-arg openmpi_major_version=v5.0 --build-arg openmpi_release_name=openmpi-5.0.3 <container-name>.sif gdtk_container.def
```

## Installing a locally built container
See: [If you built the container locally](#if-you-built-the-container-locally)

# Deploying to ghcr
Checkout the workflow in the file `.github/workflows/build-deploy.yml`.

The workflow to build the image is triggered when a tagged version is pushed, or via manually triggering it in the github actions UI.
