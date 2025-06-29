# -*-makefile-*-
#
# Copyright (C) 2025 by Artur Wiebe <artur@4wiebe.de>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_RASPI_REBOOT) += raspi-reboot

#
# Paths and names
#
RASPI_REBOOT_VERSION		:= 1
RASPI_REBOOT			:= raspi-reboot-$(RASPI_REBOOT_VERSION)
RASPI_REBOOT_URL		:= lndir://local_src/raspi-reboot
RASPI_REBOOT_DIR		:= $(BUILDDIR)/$(RASPI_REBOOT)
RASPI_REBOOT_LICENSE		:= MIT

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

RASPI_REBOOT_CONF_TOOL	:= NO
RASPI_REBOOT_MAKE_ENV	:= $(CROSS_ENV)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/raspi-reboot.targetinstall:
	@$(call targetinfo)

	@$(call install_init, raspi-reboot)
	@$(call install_fixup, raspi-reboot,PRIORITY,optional)
	@$(call install_fixup, raspi-reboot,SECTION,base)
	@$(call install_fixup, raspi-reboot,AUTHOR,"Artur Wiebe <artur@4wiebe.de>")
	@$(call install_fixup, raspi-reboot,DESCRIPTION,missing)

	@$(call install_copy, raspi-reboot, 0, 0, 0755, $(RASPI_REBOOT_DIR)/raspi-reboot, /usr/bin/raspi-reboot)

	@$(call install_finish, raspi-reboot)

	@$(call touch)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

$(STATEDIR)/raspi-reboot.clean:
	@$(call targetinfo)
	@-$(call execute, RASPI_REBOOT, $(RASPI_REBOOT_MAKE_ENV) $(MAKE) clean)
	@$(call clean_pkg, RASPI_REBOOT)

# vim: syntax=make
