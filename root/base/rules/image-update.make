# SPDX-FileCopyrightText: 2026 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

#
# We provide this package
#
IMAGE_PACKAGES-$(PTXCONF_IMAGE_UPDATE) += image-update

#
# Paths and names
#
IMAGE_UPDATE		:= image-update
IMAGE_UPDATE_DIR	:= $(BUILDDIR)/$(IMAGE_UPDATE)
IMAGE_UPDATE_IMAGE	:= $(IMAGEDIR)/update

# ----------------------------------------------------------------------------
# Image
# ----------------------------------------------------------------------------

IMAGE_UPDATE_GPGHOME := ${PTXDIST_WORKSPACE}/../keys
IMAGE_UPDATE_GPG := gpg --homedir=$(IMAGE_UPDATE_GPGHOME) -v --batch --yes --compress-algo=none --lock-never --no-random-seed-file --no-permission-warning --no-secmem-warning

$(IMAGE_UPDATE_IMAGE):
	@$(call targetinfo)
	
	gzip -dc $(IMAGE_ROOT_TGZ_IMAGE) | xz -T0 -4 -zc > $(IMAGE_UPDATE_IMAGE)
	
	$(IMAGE_UPDATE_GPG) --sign --local-user=update --symmetric --passphrase-file=$(IMAGE_UPDATE_GPGHOME)/common.symkey --output=$(IMAGE_UPDATE_IMAGE).gpg $(IMAGE_UPDATE_IMAGE)
	
	@$(call finish)

# vim: syntax=make
