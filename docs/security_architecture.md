# Security Architecture

controlOS uses a layered security architecture that protects the system from boot through runtime. Every stage in the boot chain is authenticated, all persistent storage is encrypted, and software updates and backups are cryptographically signed and encrypted.


## Secure Boot

The system uses UEFI Secure Boot. The first-stage bootloader is a signed Linux kernel with an appended initramfs, stored as an EFI binary on an unencrypted boot partition. The UEFI firmware verifies this binary against enrolled platform keys before executing it.

During initial installation, the installer enrolls the project's Secure Boot keys (PK, KEK, db) into the UEFI firmware. From that point on, only kernels signed with the project's key will boot.


## Disk Encryption

All persistent storage is encrypted with dm-crypt (AES-XTS). Two encrypted volumes exist: one for the read-only root filesystem and one for the writable data partition.

The encryption key is generated randomly during installation and sealed into a TPM 2.0 chip, bound to a specific PCR state. On each boot, the initramfs unseals the key from the TPM, sets up the encrypted volumes and then shreds the key from memory.

This means the disk contents are only accessible when booted on the original hardware with an unmodified boot chain. Removing the storage device or tampering with the boot process prevents decryption.


## Boot Chain

The boot process has two stages:

1. **First-stage boot**: The UEFI firmware loads the signed EFI binary from the unencrypted boot partition. This minimal Linux system unseals the disk encryption key from the TPM, opens the encrypted volumes, checks for pending updates and applies them if present.

2. **Main system boot**: The first stage loads the main kernel and initramfs from the now-decrypted root partition and boots into it via kexec. The main initramfs mounts the root filesystem read-only and the data partition read-write, sets up the /etc overlay and hands off to systemd.

The main kernel is not independently signed — it is protected by residing on the encrypted root partition, which is only accessible after the Secure Boot and TPM-based decryption in the first stage.


## Read-Only Root with Overlay

The root filesystem is mounted read-only. Configuration changes are stored on the data partition and applied via an overlayfs mount over /etc. The overlay's upper directory (/var/etc) contains the device-specific configuration and is also the content that is captured in backups.

This separation protects the base system from accidental or malicious modification during normal operation.


## Software Updates

Update files are compressed, GPG-signed and symmetrically encrypted during the build. Devices decrypt and verify the signature before accepting an update. Both a valid signature from the project's update key and successful decryption with the shared symmetric key are required.

Before applying an update, the device creates a snapshot of the current root filesystem and configuration, allowing the previous version to be restored if needed.

At the next reboot, the first-stage boot system detects the pending update, verifies the archive integrity and extracts it onto the root partition.


## Backups

Backups capture the device's configuration (/var/etc). They are symmetrically encrypted and also encrypted to a public key.

The symmetric key is unique per device and generated on first boot, so a backup can only be restored on the device that created it. The public key encryption allows developers holding the corresponding private key to decrypt any device's backup for diagnostics or recovery.

Restoring a backup triggers a reboot. The first-stage boot system detects the backup file, verifies it and extracts it onto the data partition before booting the main system.


## Key Management

Cryptographic keys are generated once per project and stored in a /keys directory that is not included in the repository. The build system generates them automatically on first build:

- **Secure Boot**: An X.509 certificate and key for signing EFI binaries and enrolling UEFI Secure Boot variables.
- **Update signing**: A GPG key pair. The private key signs updates at build time; the public key is installed on devices for verification.
- **Backup encryption**: A GPG key pair. The public key is installed on devices for encrypting backups; the private key is retained by the developer for offline decryption.
- **Shared symmetric key**: Used for symmetric encryption of updates. Shared across all devices built from the same project so that any device can decrypt an update intended for the fleet.
- **SSH keys**: A host key for the device and an authorized key pair for developer access.
- **Disk encryption key**: Generated per device at install time and sealed into the TPM. Not part of the build-time key set.
