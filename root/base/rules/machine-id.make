# -*-makefile-*-
#
# Copyright (C) 2012 by Michael Olbrich <m.olbrich@pengutronix.de>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_MACHINE_ID) += machine-id

MACHINE_ID_VERSION	:= 1
MACHINE_ID_LICENSE	:= ignore

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/machine-id.targetinstall:
	@$(call targetinfo)

	@$(call install_init, machine-id)
	@$(call install_fixup,machine-id,PRIORITY,optional)
	@$(call install_fixup,machine-id,SECTION,base)
	@$(call install_fixup,machine-id,AUTHOR,"Michael Olbrich <m.olbrich@pengutronix.de>")
	@$(call install_fixup,machine-id,DESCRIPTION,missing)

#	@$(call install_alternative, machine-id, 0, 0, 0755, /etc/rc.once.d/machine-id)
	@$(call install_alternative, machine-id, 0, 0, 0444, /etc/machine-id)

	@$(call install_finish,machine-id)

	@$(call touch)

# vim: syntax=make
