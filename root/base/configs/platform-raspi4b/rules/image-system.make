# SPDX-FileCopyrightText: 2026 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

#
# We provide this package
#
IMAGE_PACKAGES-$(PTXCONF_IMAGE_SYSTEM) += image-system

#
# Paths and names
#
IMAGE_SYSTEM_DIR		:= $(BUILDDIR)/image-system
IMAGE_SYSTEM_IMAGE		:= $(IMAGEDIR)/system.img
IMAGE_SYSTEM_CONFIG		:= system
IMAGE_SYSTEM_INITRAMFS	:= ${PTXDIST_WORKSPACE}/../boot/platform-$(PTXCONF_PLATFORM)/images/root.cpio

# ----------------------------------------------------------------------------
# Image
# ----------------------------------------------------------------------------

IMAGE_SYSTEM_ENV = \
	OVERLAYS="$(foreach f,$(KERNEL_DTBO_FILES),file overlays/$(f) { image = overlays/$(f) })"

$(IMAGE_SYSTEM_IMAGE): $(IMAGE_SYSTEM_INITRAMFS)
	@$(call targetinfo)

	@ln -sf $(IMAGE_SYSTEM_INITRAMFS) $(IMAGEDIR)/initramfs
	@ln -sf $(KERNEL_PKGDIR)/$(KERNEL_DTBO_DIR) $(IMAGEDIR)
	@$(call image/genimage, IMAGE_SYSTEM)

	@$(call finish)

# vim: syntax=make
