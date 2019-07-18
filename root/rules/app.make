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

	@$(call install_alternative_tree, app, 0, 0, /etc/app)

	@$(call install_finish,app)
	@$(call touch)


# vim: syntax=make
