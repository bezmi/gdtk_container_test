Put `gdtk_container.def` in a clean directory.

## Build and develpoment
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

## Building and Running `lmr`
After building a container, run:
```sh
apptainer run <path-to-container>
```

This will clone gdtk and build + install lmr into your home directory at `$HOME/.local/share/gdtk_container` (unless you change `data_dir` when building the container).

You can use standard `lmr` binaries and their associated commands. Just prefix them with `apptainer exec <path-to-gdtk-container>.sif`.

### Test scripts and tips
The script `build.sh` will build the container should be run on your local workstation.
`BUNYA_USERNAME=your_username ./deploy.sh` will deploy it to Bunya.
It needs interactive authentication so it's not the most practical thing. You can always copy `gdtk_container.sif` manually.

`test.sh` can be run on bunya to actually use the container. It uses `apptainer run`, pulling a fresh copy to access a shell in the container.
```sh
apptainer shell <path-to-container>.sif
```
NOTE: Only the user specified of default bindmounts (such as your home directory) will be writable.
