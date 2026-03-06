# Building Images

* **Reproducible builds** - the containerized build environment pins exact versions of Debian, PTXdist and the OSELAS toolchain, ensuring identical builds on any host
* **Single command builds** - `ptxdist/make` builds the entire system from source to flashable images in one step
* **Offline backup** - the container uses named Podman volumes for downloaded sources (`src`) and the build cache (`cache`); both the container image and these volumes can be exported for archival or offline use
* **Shared source cache** - all PTXdist projects share a common source directory inside the container, so packages are downloaded only once
* **Ccache integration** - compilation results are cached across builds via ccache, significantly speeding up incremental rebuilds
* **Multi-platform support** - the same build system and Makefile support multiple hardware platforms with per-platform configs


Build Container
===

A containerized build environment ensures reproducible builds regardless of the host system. The container includes PTXdist, the OSELAS cross-compilation toolchain and all required build dependencies. The versions are pinned in `ptxdist/config`.

Create the build container (once):

```sh
ptxdist/create
```

This concatenates the Containerfile fragments from `ptxdist/Containerfile.d/` and builds a Podman container image tagged with the PTXdist version. The fragments are processed in order:

* `1-debian` - Debian base image with essential build tools
* `2-esp32` - Optional ESP-IDF toolchain for ESP32 targets
* `9-ptxdist` - OSELAS cross-toolchains, PTXdist build from source, and user setup


Building
===

To build all images for the default x86 platform:

```sh
ptxdist/make
```

This single command enters the build container and runs the full build pipeline. The `Makefile` chains the build steps in dependency order:


1. **update** - builds the root filesystem, compresses it with XZ and signs it with GPG, producing the `update.gpg` file
2. **system.img** - builds the complete system disk image containing a boot partition and an init partition with the update file
3. **install.img** - builds the bootable USB installer image that writes `system.img` onto the target's internal SSD

If only the update file is needed (e.g. for deploying a software change to existing systems):

```sh
ptxdist/make update
```

The update file can be installed on a running target via the web UI (System > Software Update) or sent directly using `online/send-update`.


Images
===

After a successful build, the `images/` directory contains symlinks to the built artifacts:

* **`update-<platform>.gpg`** - signed and encrypted full system update file, ready to be installed on a running target via the GUI software update page
* **`system-<platform>.img.xz`** - compressed system image to be flashed onto the target's internal drive
* **`install-<platform>.img.xz`** - bootable USB image that, when booted on the target, automatically flashes `system.img` onto the internal SSD
* **`flash`** - helper script for writing images to a USB drive or block device


Other Platforms
===

The default platform is `x86`. Other platforms are built using their dedicated make scripts:

```sh
ptxdist/make-raspi4b
```

These scripts invoke `make PLATFORM=<name>`, which selects the corresponding platformconfig and kernelconfig from `configs/platform-<name>/`. The resulting images appear in `images/` with the platform name in the filename.


Clean Build
===

If major controlOS changes require a fresh build (e.g. toolchain or base platform changes):

```sh
ptxdist/make clean
```

This removes all platform build directories across all PTXdist projects.


