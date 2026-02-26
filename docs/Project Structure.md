# Project Structure

```
/
├── boot/                bootloader, system and installer images
│   └── base/            common platform and kernel settings
├── root/                runtime root partition (application layer)
│   └── base/            controlOS runtime rootfs
│       └── initramfs/   initramfs for the runtime kernel
├── code/
│   ├── shared/          common python module
│   ├── gui/             web-based user interface
│   └── app/             main application
├── images/              symlinks to built images
├── office/              offline log viewer
├── online/              target connection scripts
├── virtualbox/          VM simulation scripts
├── tools/               developer utilities
├── keys/                generated cryptographic keys
└── ptxdist/             build environment and helper scripts
```

Application-specific files are added directly into this directory structure alongside the controlOS files.


PTXdist projects
===

The system is composed of multiple PTXdist projects that are built individually and combined into the final images. Each PTXdist project follows the same directory layout:

* **configs/** contains the ptxconfig, platformconfig and kernelconfig. There is one platformconfig per supported hardware platform, stored in `configs/platform-<name>/`. The kernel configuration is assembled from fragments in `kernelconfig.d/`.
* **rules/** contains custom package definitions. Each package has a `.make` file with build and install instructions and an `.in` file with Kconfig menu entries.
* **projectroot/** contains files that are copied verbatim into the target root filesystem. The directory structure inside projectroot mirrors the target filesystem (e.g. `projectroot/etc/fstab` becomes `/etc/fstab` on the target).
* **patches/** contains patches applied to upstream packages before building.


/boot/base
---

The lowest layer in the PTXdist project hierarchy. It provides the common platform definition and kernel configuration that all other PTXdist projects inherit. This is where the hardware platform is defined, including the architecture, the cross-compilation toolchain and the base kernel configuration.

All other PTXdist projects (/boot, /root/base, /root/base/initramfs) reference this layer via a `base` symlink that points here.


/boot
---

This PTXdist project builds the boot system. It produces two images:

**System image** (`system.img`): A complete disk image containing a boot partition and an init partition. The init partition holds a compressed root filesystem as an update file. This image is written to the target's internal storage.

**Installer image** (`install.img`): A bootable USB image. When a target boots from this USB key, it writes the system image onto the internal SSD. This is used for initial provisioning of new hardware.

The boot system itself is a minimal single-file Linux (kernel with appended initramfs). Its init script (`/etc/init.d/rcS`) handles two tasks:
* On first boot it creates the partition layout on the internal storage.
* On subsequent boots it checks for pending updates in the init partition and applies them before handing off to the main system.


/root/base/initramfs
---

Builds the initramfs that is appended to the runtime kernel. The initramfs runs before the main root filesystem is mounted. Its init script mounts the partitions and then switches root to the actual root filesystem where systemd takes over.

The output is `root.cpio`, which gets appended to the kernel built by the /root project.


/root/base
---

The controlOS layer for the runtime root filesystem. This is the largest PTXdist project and contains the bulk of the system configuration.

**rules/** defines how application code and system components are packaged and installed into the rootfs:

* `app.make` installs `/code/app` to `/usr/lib/app` and sets up `app.service`. The service runs with FIFO realtime scheduling and is auto-started on boot.
* `gui.make` installs `/code/gui` to `/usr/lib/gui` and sets up three GUI services (hmi, admin, studio), each with its own systemd socket. The HMI socket is auto-enabled.
* `python-shared.make` installs `/code/shared` as the `shared` Python module into the system's site-packages directory.
* `system.make` is the largest rule and installs the core system configuration: mount units for `/var` and `/etc`, network configuration (systemd-networkd files, hostapd, wpa_supplicant, iptables), the update and backup utilities, SSH configuration, the remote access tunnel service, realtime CPU and IRQ setup, user privilege levels and debug mode support.
* `keys.make` installs GPG keys (for update verification and backup encryption), SSH host keys, and SSH authorized keys from the `/keys` directory into the rootfs.
* `image-update.make` takes the root filesystem tarball, recompresses it with XZ, and signs it with GPG using a symmetric key. The output is the `update.gpg` file that can be sent to devices.
* Additional rules handle third-party components: EtherCAT master (`etherlab-ethercat.make`), CANopen stack (`lely-canopen.make`), motion library (`ruckig.make`), and GUI frontend dependencies (Vue.js, Bootstrap, FontAwesome, Ace editor, Three.js).

**projectroot/** provides the system configuration files and services:

* Systemd services for the application (`app.service`), GUI instances (`gui-hmi.service`, `gui-studio.service`, `gui-admin.service`), display server (Weston/Cog), networking, updates, backups, remote access, and realtime setup.
* Network configuration with systemd-networkd files for LAN, WLAN, system WLAN, and EtherCAT interfaces.
* System utilities: `update` (receives and verifies encrypted update files), `update-apply` (backs up current system and stages the update for next boot), `backup` (creates encrypted backups of `/var/etc` and `/var/local`) and `rt-setup-cpu`/`rt-setup-irq` for CPU isolation and IRQ affinity.
* User privilege levels via `user@.target`, `user@admin.target` and `user@oem.target`.

**patches/** contains patches for upstream packages like EtherCAT and CANopen.


/root
---

The application-specific layer that extends `/root/base`. This is where a project built on controlOS adds its own PTXdist rules, platformconfig overrides, kernel configuration fragments and projectroot files. It contains additional network configuration and platform-specific kernel settings.


code
===

The application source code. It is not compiled during development but installed as-is into the rootfs by the PTXdist rules in `/root/base/rules`.


/code/shared
---

Installed as the `shared` Python package into the system's site-packages. It provides common functionality used by the app, GUI and system scripts:

* `app/` - application framework with base classes for the app lifecycle, simulated I/O, watchdog, and web API registration
* `logging.py` - centralized logging setup
* `tornado.py` - Tornado web server helpers
* `sqlite.py` - SQLite database utilities
* `network.py` - network configuration helpers
* `system.py` - systemd integration (service control, target management)
* `issue/` - issue report generation


/code/gui
---

The web-based graphical user interface with a Python backend (Tornado) and a Vue.js frontend. The GUI runs as multiple separate systemd services, each serving a different interface on its own port:

* **HMI** - the operator interface for day-to-day use
* **Studio** - developer interface with debugging tools, available on port 8000

All modes share the same codebase. The mode is passed as a command-line argument and determines which modules are loaded.

Sub-modules:

* **web/** is the base web framework. It provides a Tornado HTTP server with socket activation, an HTML template, automatic JavaScript ES module import map generation, WebSocket support, and static file serving.
* **system/** contains system management pages: network configuration (LAN, WLAN, system WLAN, SMTP), backup and restore, software update, power management, time/date settings, and remote access configuration.
* **diag/** provides diagnostics: a live log viewer, issue report generation, and a real-time variable watch display.
* **studio/** is the developer interface with simulated I/O controls for testing without hardware.
* **sim/** provides a 3D robot simulation using Three.js.
* **hmi/** is the application-specific operator interface. This is where the project built on controlOS places its custom UI.
* **locale/** contains translations. Common translations are in `locale/base/`, application-specific translations are added alongside.


/code/app
---

The main application. It runs as a systemd service with realtime scheduling priority. The application code is project-specific - controlOS provides the framework (`shared.app`) and the service setup, while the actual application logic lives here.


Supporting directories
===


/images
---

Contains symlinks to the built images. After a successful build, this directory provides the ready-to-use files:

* `system-<platform>.img.xz` - complete system image for writing to internal storage
* `install-<platform>.img.xz` - USB installer image
* `update-<platform>.gpg` - signed update file for over-the-network updates
* `flash` - helper script for flashing images


/office
---

A standalone web application based on the GUI framework. Unlike the GUI itself, it is not installed into the rootfs. It runs on the developer's workstation and is used to view offline logs and diagnostics collected by an issue report from a target system.


/online
---

Shell scripts for working with a target system over SSH.

* `connect` - open an interactive SSH shell on the target
* `send-code` - deploy application code to the target
* `send-update` - send an update file to the target
* `mount-rw` - remount the target rootfs as read-write (normally read-only)
* `sshfs` - mount the target filesystem locally via SSHFS
* `debug` - start a debug session on the target


/virtualbox
---

Scripts to create and manage a VirtualBox VM that simulates a target system. Useful for development and testing without hardware. Provides `create`, `delete` and `start` scripts.


/keys
---

Generated cryptographic keys used for system security. Created by the `keygen` Makefile target. Contains:

* GPG key pairs for update signing and backup encryption
* A shared symmetric key (`common.symkey`) used for encrypting updates and backups
* SSH host keys for the target system
* SSH key pair for remote access (the public key is installed as authorized key on the target)

These keys are installed into the rootfs by the `keys.make` PTXdist rule.


/ptxdist
---

Build environment configuration and helper scripts.

* `config` pins the PTXdist and OSELAS toolchain versions used by this project
* `Containerfile` defines the container image for a reproducible build environment
* `create` sets up the PTXdist build environment
* `make` and `run` are helper scripts for building inside the container
