# controlOS

An industrial automation platform built on real-time Linux. controlOS provides everything needed to develop, deploy and operate machine control applications — from hard real-time PLC execution to web-based operator interfaces, all running on standard hardware.

## Key Features

### Real-Time Control

A PREEMPT-RT patched Linux kernel with dedicated CPU isolation and IRQ affinity tuning delivers deterministic, low-latency execution.

### CODESYS PLC Runtime

Full integration of the CODESYS IEC 61131-3 PLC runtime. Applications are compiled, packaged and selected at startup — a single image can ship multiple CODESYS applications for different hardware variants and simulation environments.

### Hybrid CODESYS / Python Architecture

CODESYS handles hard real-time control while a Python asyncio application runs alongside it, connected through POSIX shared memory. Commands and feedback are exchanged every PLC cycle, giving Python code synchronous access to the real-time process without compromising determinism.


### I/O Abstraction & Simulation

A hardware-agnostic I/O layer lets application code run identically on real hardware and in simulation. Individual I/O points can be overridden at runtime from the Studio UI — useful during commissioning and debugging. Full system simulation runs in VirtualBox with no hardware required.

### Web-Based User Interface

A Vue.js frontend with a Python/Tornado backend serves multiple interfaces:

- **HMI** — operator interface for day-to-day use
- **Studio** — developer tools with live I/O monitoring, log viewer, and 3D simulation
- **Admin** — system management: network, updates, backups, remote access

### Remote Access

Secure connectivity to devices behind firewalls via reverse SSH tunnels through a relay server. A Layer 2 ethernet tunnel gives full network access to all device services. Activated and managed through the Admin web UI.

### Secure Over-the-Air Updates

Update files are compressed, GPG-signed and encrypted. They can be installed on running devices through the web UI or pushed via command line.

### Reproducible Builds

A containerized build environment pins exact versions of Debian, PTXdist and the OSELAS cross-compilation toolchain. A single command builds the entire system from source to flashable images. Ccache integration speeds up incremental rebuilds.

### Multi-Platform Support

The same codebase and build system support multiple hardware platforms — x86, Raspberry Pi, and VirtualBox — with per-platform kernel and board configurations.

### Read-Only Root Filesystem

The root filesystem is mounted read-only in normal operation, protecting against corruption from unexpected power loss. Persistent data is stored on a separate writable partition.

## Further Reading

- [Project Structure](project_structure.md) — repository layout, PTXdist projects and application code organization
- [Building Images](building_images.md) — build environment setup, image creation and deployment
