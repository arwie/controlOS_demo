#
# We provide this package
#
PACKAGES-$(PTXCONF_CUSTOM) += custom

CUSTOM_VERSION		:= 1

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/custom.targetinstall:
	@$(call targetinfo)
	@$(call install_init, custom)


	@$(call install_link, custom, ../rt-setup-irq@.service, /usr/lib/systemd/system/basic.target.wants/rt-setup-irq@can0.service)

	#@$(call install_alternative, custom, 0, 0, 0644, /etc/hostapd/local.conf)

	@$(call install_finish,custom)
	@$(call touch)


# vim: syntax=make
