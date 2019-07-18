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
PACKAGES-$(PTXCONF_STX_MC) += stx-mc

STX_MC_VERSION	:= 1

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/stx-mc.targetinstall:
	@$(call targetinfo)
	@$(call install_init, stx-mc)

	@$(call install_alternative_tree, stx-mc, 0, 0, /usr/lib/mc, no)
	
	@$(call install_alternative, stx-mc, 0, 0, 0755, /usr/sbin/mc-state)
	@$(call install_alternative, stx-mc, 0, 0, 0644, /usr/lib/systemd/system/mc@.target)
	@$(call install_alternative, stx-mc, 0, 0, 0644, /usr/lib/systemd/system/mc-state.service)
	@$(call install_alternative, stx-mc, 0, 0, 0644, /usr/lib/systemd/system/mc-state.socket)
	@$(call install_link,        stx-mc, ../mc-state.socket, /usr/lib/systemd/system/sockets.target.wants/mc-state.socket)
	
	@$(call install_alternative, stx-mc, 0, 0, 0755, /usr/bin/mc-update)
	@$(call install_alternative, stx-mc, 0, 0, 0644, /usr/lib/systemd/system/mc-update.service)
	@$(call install_alternative, stx-mc, 0, 0, 0644, /usr/lib/systemd/system/mc-update.timer)
	@$(call install_link,        stx-mc, ../mc-update.timer,   /usr/lib/systemd/system/timers.target.wants/mc-update.timer)
	@$(call install_link,        stx-mc, ../mc-update.service, /usr/lib/systemd/system/mc@state.target.wants/mc-update.service)
	
	@$(call install_alternative, stx-mc, 0, 0, 0755, /usr/sbin/mc-log)
	@$(call install_alternative, stx-mc, 0, 0, 0644, /usr/lib/systemd/system/mc-log.service)
	@$(call install_link,        stx-mc, ../mc-log.service, /usr/lib/systemd/system/mc@log.target.wants/mc-log.service)
	
	@$(call install_alternative, stx-mc, 0, 0, 0644, /usr/lib/systemd/system/mc-poweroff.service)
	@$(call install_link,        stx-mc, ../mc-poweroff.service, /usr/lib/systemd/system/poweroff.target.wants/mc-poweroff.service)

	@$(call install_finish, stx-mc)
	@$(call touch)


# vim: syntax=make
