# Copyright (c) 2016 Artur Wiebe <artur@4wiebe.de>
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
IMAGE_PACKAGES-$(PTXCONF_IMAGE_SYSTEM) += image-system

#
# Paths and names
#
IMAGE_SYSTEM			:= image-system
IMAGE_SYSTEM_DIR		:= $(BUILDDIR)/$(IMAGE_SYSTEM)
IMAGE_SYSTEM_IMAGE		:= $(IMAGEDIR)/system.img
IMAGE_SYSTEM_CONFIG		:= image-system.config

# ----------------------------------------------------------------------------
# Image
# ----------------------------------------------------------------------------

$(IMAGE_SYSTEM_IMAGE):
	@$(call targetinfo)
	
	@$(call image/genimage, IMAGE_SYSTEM)
	
	rm -f $(IMAGEDIR)/root.*
	rm -f $(IMAGEDIR)/linuximage
	rm -f $(IMAGEDIR)/data.tgz
	rm -f $(IMAGEDIR)/boot.vfat
	rm -f $(IMAGEDIR)/init.vfat
	
	xz -T0 -zf $(IMAGE_SYSTEM_IMAGE)
	
	@$(call finish)

# vim: syntax=make
