# Copyright (c) 2021 Artur Wiebe <artur@4wiebe.de>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
# associated documentation files (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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

IMAGE_UPDATE_GPGHOME := ${PTXDIST_WORKSPACE}/../keys/gpg
IMAGE_UPDATE_GPG := gpg --homedir=$(IMAGE_UPDATE_GPGHOME) -v --batch --yes --compress-algo=none --lock-never --no-random-seed-file --no-permission-warning --no-secmem-warning

$(IMAGE_UPDATE_IMAGE):
	@$(call targetinfo)
	
	gzip -dc $(IMAGE_ROOT_TGZ_IMAGE) | xz -T0 -zc > $(IMAGE_UPDATE_IMAGE)
	
	$(IMAGE_UPDATE_GPG) --sign --local-user=update --symmetric --passphrase-file=$(IMAGE_UPDATE_GPGHOME)/common.symkey --output=$(IMAGE_UPDATE_IMAGE).gpg $(IMAGE_UPDATE_IMAGE)
	
	@$(call finish)

# vim: syntax=make
