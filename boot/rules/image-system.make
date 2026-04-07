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
IMAGE_SYSTEM_IMAGE		:= $(IMAGEDIR)/system.img.xz
IMAGE_SYSTEM_CONFIG		:= system

# ----------------------------------------------------------------------------
# Image
# ----------------------------------------------------------------------------

$(IMAGE_SYSTEM_IMAGE):
	@$(call targetinfo)

	@$(call image/genimage, IMAGE_SYSTEM)
	@xz -T0 -2 -zf $(IMAGEDIR)/system.img

	@$(call finish)

# vim: syntax=make
