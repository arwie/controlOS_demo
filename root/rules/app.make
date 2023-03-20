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

	@$(call install_alternative, app, 0, 0, 0644, /etc/hostapd/local.conf)

	@$(call install_alternative, app, 0, 0, 0755, /usr/sbin/mc-sorter)
	@$(call install_alternative, app, 0, 0, 0644, /usr/lib/systemd/system/mc-sorter.service)
	@$(call install_link,        app, ../mc-sorter.service, /usr/lib/systemd/system/mc@sorter.target.wants/mc-sorter.service)

	@$(call install_alternative, app, 0, 0, 0755, /usr/sbin/mc-shaker)
	@$(call install_alternative, app, 0, 0, 0644, /usr/lib/systemd/system/mc-shaker.service)
	@$(call install_link,        app, ../mc-shaker.service, /usr/lib/systemd/system/mc@shaker.target.wants/mc-shaker.service)

	@$(call install_finish,app)
	@$(call touch)


# vim: syntax=make
