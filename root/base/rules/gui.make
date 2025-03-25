# -*-makefile-*-
#
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
PACKAGES-$(PTXCONF_GUI) += gui

GUI_VERSION	:= 1

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/gui.targetinstall:
	@$(call targetinfo)
	@$(call install_init, gui)

	@$(call install_alternative_tree, gui, 0, 0, /usr/lib/gui)

	@$(call install_alternative, gui, 0, 0, 0644, /usr/lib/systemd/system/gui.service)
	@$(call install_alternative, gui, 0, 0, 0644, /usr/lib/systemd/system/gui.socket)
	@$(call install_link,        gui, ../gui.socket, /usr/lib/systemd/system/sockets.target.wants/gui.socket)

	@$(call install_alternative, gui, 0, 0, 0644, /usr/lib/systemd/system/studio.service)
	@$(call install_alternative, gui, 0, 0, 0644, /usr/lib/systemd/system/studio.socket)

ifdef PTXCONF_GUI_WPEWEBKIT
	@$(call install_alternative, gui, 0, 0, 0644, /usr/lib/udev/rules.d/60-drm-systemd.rules)
	@$(call install_alternative, gui, 0, 0, 0644, /usr/lib/systemd/system/weston.service)
	@$(call install_alternative, gui, 0, 0, 0644, /etc/cog.conf)
	@$(call install_alternative, gui, 0, 0, 0644, /usr/lib/systemd/system/cog.service)
	@$(call install_link,        gui, ../cog.service, /usr/lib/systemd/system/multi-user.target.wants/cog.service)
endif

	@$(call install_finish,gui)
	@$(call touch)


# vim: syntax=make
