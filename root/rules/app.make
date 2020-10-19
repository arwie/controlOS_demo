#
# We provide this package
#
PACKAGES-$(PTXCONF_APP) += app

APP_VERSION		:= 1

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/app.targetinstall:
	@$(call targetinfo)
	@$(call install_init, app)

	@$(call install_alternative, app, 0, 0, 0755, /usr/sbin/shaker)
	@$(call install_alternative, app, 0, 0, 0644, /usr/lib/systemd/system/shaker.service)
	@$(call install_link,        app, ../shaker.service, /usr/lib/systemd/system/mc@shaker.target.wants/shaker.service)

	@$(call install_alternative, app, 0, 0, 0755, /usr/bin/arduino-update)

	@$(call install_finish,app)
	@$(call touch)


# vim: syntax=make
