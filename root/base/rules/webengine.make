# -*-makefile-*-
#
# Copyright (c) 2020 Artur Wiebe <artur@4wiebe.de>
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
PACKAGES-$(PTXCONF_WEBENGINE) += webengine

#
# Paths and names
#
WEBENGINE_VERSION	:= 1.0
WEBENGINE			:= webengine-$(WEBENGINE_VERSION)
WEBENGINE_URL		:= file://local_src/webengine
WEBENGINE_DIR		:= $(BUILDDIR)/$(WEBENGINE)
WEBENGINE_BUILD_OOT	:= YES
WEBENGINE_LICENSE	:= MIT

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------
#
# qmake
#
WEBENGINE_PATH		:= PATH=$(PTXDIST_SYSROOT_CROSS)/bin/qt5:$(CROSS_PATH)
WEBENGINE_CONF_TOOL	:= qmake
WEBENGINE_CONF_OPT	:= $(CROSS_QMAKE_OPT) PREFIX=/usr

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/webengine.targetinstall:
	@$(call targetinfo)
	@$(call install_init, webengine)

	@$(call install_copy, webengine, 0, 0, 0755, $(WEBENGINE_DIR)-build/webengine, /usr/sbin/webengine)

	@$(call install_alternative, webengine, 0, 0, 0644, /etc/webengine.qml)

	@$(call install_alternative, webengine, 0, 0, 0644, /usr/lib/systemd/system/webengine.service)
	@$(call install_link,        webengine, ../webengine.service, /usr/lib/systemd/system/multi-user.target.wants/webengine.service)

	@$(call install_finish, webengine)
	@$(call touch)

# vim: syntax=make
