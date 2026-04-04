# SPDX-FileCopyrightText: 2026 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

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

	@$(call install_link, board, \
		$(KERNEL_IMAGE), \
		/boot/linux)
	@$(call install_copy, board, 0, 0, 0644, \
		${PTXDIST_WORKSPACE}/../boot/platform-x86/images/root.cpio, \
		/boot/initramfs)

	@$(call install_finish, board)
	@$(call touch)

# vim: syntax=make
