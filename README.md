This is a test repository for a development container of gdtk.
The container debian 12 and includes the latest `gcc` distribution, the latest `ldc`, `dub` and a recent version of openmpi.

Running the container builds and installs `lmr`.

This container is set up to use the hybrid openmpi approach described in the apptainer docs. It should be very easy to convert it to use the bind based approach as long as the HPC system has a sane layout for the location of the openmpi binaries and libraries.

# Quickstart
The host system should have `apptainer` installed, as well as `openmpi >= v5.0.3` (if you want to use the mpi executables)

First, pull the container from `ghcr`:
```sh
apptainer pull gdtk_container.sif oras://ghcr.io/bezmi/gdtk_container_test/gdtk_container_test:latest
```

There should be a compressed container image in the directory where you ran the command above. Now you can run the container:
```sh
apptainer run gdtk_container.sif

```
NOTE: if you're on Bunya, then you need to do this from a compute node. The login node doesn't have apptainer. See the `test.sh` script for more details.

The command above will build and install `lmr` in the container.
The repository and install location are set to `$HOME/.local/share/gdtk_container` and can be accessed from the host.

You can use standard `lmr` binaries and their associated commands. Just prefix them with `apptainer exec gdtk_container.sif`.
For example, to run the `lmr` binary, which just outputs a help message:

```sh
apptainer run gdtk_container.sif lmr
```

# Test scripts and tips

- `test.sh` can be run on bunya to actually use the container. It uses `apptainer run`, pulling a fresh copy to access a shell in the container.
- `build.sh` will build the container should be run on your local workstation.
- `BUNYA_USERNAME=your_username ./deploy.sh` will deploy it to Bunya. It needs interactive authentication so it's not the most practical thing. You can always copy `gdtk_container.sif` manually.


- To run a shell in the container, use:
```sh
apptainer shell <path-to-container>.sif
```
NOTE: Only the user specified of default bindmounts (such as your home directory) will be writable.

# Building locally.
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

### Build options
See the `%arguments` section of `gdtk_container.def`.
For example, to change the openmpi version that gets downloaded and installed, you can do
```sh
apptainer build --build-arg openmpi_major_version=v5.0 --build-arg openmpi_release_name=openmpi-5.0.3 <container-name>.sif gdtk_container.def
```

# Deploying to ghcr
see .github/workflows/build-deploy.yml
