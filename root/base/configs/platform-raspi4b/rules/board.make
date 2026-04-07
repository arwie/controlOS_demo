# SPDX-FileCopyrightText: 2026 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

# Firmware files taken from (version 20231022):
# https://github.com/RPi-Distro/firmware-nonfree/tree/trixie/debian/config/brcm80211

#
# We provide this package
#
PACKAGES-$(PTXCONF_BOARD) += board

BOARD_VERSION	:= 1

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/board.targetinstall:
	@$(call targetinfo)
	@$(call install_init, board)

	@$(call install_copy, board, 0, 0, 0644, ${IMAGEDIR}/system.img, /boot/system.img)

	@$(call install_alternative_tree, board, 0, 0, /usr/lib/firmware)

	@$(call install_finish, board)
	@$(call touch)

# vim: syntax=make
