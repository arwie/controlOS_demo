# SPDX-FileCopyrightText: 2026 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

#
# We provide this package
#
IMAGE_PACKAGES-$(PTXCONF_IMAGE_INSTALL) += image-install

#
# Paths and names
#
IMAGE_INSTALL_DIR		:= $(BUILDDIR)/image-install
IMAGE_INSTALL_IMAGE		:= $(IMAGEDIR)/install.img.xz
IMAGE_INSTALL_CONFIG	:= install
IMAGE_INSTALL_UPDATE	:= $(PTXDIST_WORKSPACE)/../root/platform-$(PTXCONF_PLATFORM)/images/update

IMAGE_INSTALL_CPIO_DIR		:= $(BUILDDIR)/image-install-cpio
IMAGE_INSTALL_CPIO_IMAGE	:= $(IMAGEDIR)/install.cpio
IMAGE_INSTALL_CPIO_FILES	:= $(IMAGEDIR)/root.tgz $(IMAGEDIR)/install.hash.tar

IMAGE_SYSTEM_DIR		:= $(BUILDDIR)/image-system
IMAGE_SYSTEM_IMAGE		:= $(IMAGEDIR)/system.img
IMAGE_SYSTEM_CONFIG		:= system

# ----------------------------------------------------------------------------
# Image
# ----------------------------------------------------------------------------

IMAGE_INSTALL_CPIO_CONFIG	= $(IMAGE_ROOT_CPIO_CONFIG)
IMAGE_INSTALL_CPIO_ENV		= $(IMAGE_ROOT_CPIO_ENV)

IMAGE_INSTALL_ENV = \
	SIZE="$(shell echo $$(( $$(stat -L -c%s $(IMAGE_INSTALL_UPDATE)) + 32*1024*1024 )) )"

$(IMAGE_INSTALL_IMAGE): $(IMAGE_INSTALL_UPDATE)
	@$(call targetinfo)

	@ln -sf $(IMAGE_INSTALL_UPDATE) $(IMAGEDIR)/update
	@$(call image/genimage, IMAGE_SYSTEM)

	@cd $(IMAGEDIR) && tar -cf install.hash.tar install.hash
	@$(call image/genimage, IMAGE_INSTALL_CPIO)

ifdef PTXCONF_IMAGE_KERNEL_INITRAMFS
	@sed -i -e 's,^CONFIG_INITRAMFS_SOURCE.*$$,CONFIG_INITRAMFS_SOURCE=\"$(IMAGE_INSTALL_CPIO_IMAGE)\",g' $(KERNEL_BUILD_DIR)/.config
	@$(call compile, KERNEL, $(KERNEL_MAKE_OPT) $(KERNEL_IMAGE))
	@install -m 644 "$(KERNEL_IMAGE_PATH_y)" $(IMAGEDIR)/install_linuximage
endif

	@$(call image/genimage, IMAGE_INSTALL)
	@xz -T0 -1 -zf $(IMAGEDIR)/install.img

	@$(call finish)

# vim: syntax=make
