#
# We provide this package
#
PACKAGES-$(PTXCONF_RASPI4B_FIRMWARE) += raspi4b-firmware

# Firmware files taken from:
# https://archlinuxarm.org/packages/any/firmware-raspberrypi

RASPI4B_FIRMWARE_VERSION		:= 20231022

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/raspi4b-firmware.targetinstall:
	@$(call targetinfo)
	@$(call install_init, raspi4b-firmware)

	@$(call install_alternative_tree, raspi4b-firmware, 0, 0, /usr/lib/firmware)

	@$(call install_finish, raspi4b-firmware)
	@$(call touch)


# vim: syntax=make
