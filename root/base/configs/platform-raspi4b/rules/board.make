# SPDX-FileCopyrightText: 2026 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

# Firmware files taken from (version 20231022):
# https://github.com/RPi-Distro/firmware-nonfree/tree/trixie/debian/config/brcm80211

#
# We provide this package
#
PACKAGES-$(PTXCONF_BOARD) += board

BOARD_VERSION	:= 1
BOARD_LICENSE	:= ignore

IMAGE_SYSTEM_DIR		:= $(BUILDDIR)/image-system
IMAGE_SYSTEM_IMAGE		:= $(IMAGEDIR)/system.img
IMAGE_SYSTEM_CONFIG		:= system
IMAGE_SYSTEM_INITRAMFS	:= ${PTXDIST_WORKSPACE}/../boot/platform-$(PTXCONF_PLATFORM)/images/root.cpio

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

IMAGE_SYSTEM_ENV = \
	KERNEL="$(KERNEL_IMAGE_PATH_y)" \
	OVERLAYS="$(foreach f,$(KERNEL_DTBO_FILES),file overlays/$(f) { image = overlays/$(f) })"

$(STATEDIR)/board.targetinstall:
	@$(call targetinfo)
	@$(call install_init, board)

	@ln -sf $(IMAGE_SYSTEM_INITRAMFS) $(IMAGEDIR)/initramfs
	@ln -sf $(KERNEL_PKGDIR)/$(KERNEL_DTBO_DIR) $(IMAGEDIR)
	@$(call image/genimage, IMAGE_SYSTEM)

	@$(call install_copy, board, 0, 0, 0644, ${IMAGEDIR}/system.img, /boot/system.img)

	@$(call install_alternative_tree, board, 0, 0, /usr/lib/firmware)

	@$(call install_finish, board)
	@$(call touch)

# vim: syntax=make
