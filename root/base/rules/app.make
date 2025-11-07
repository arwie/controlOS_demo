# -*-makefile-*-
#
# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

#
# We provide this package
#
PACKAGES-$(PTXCONF_APP) += app

APP_VERSION	:= 1
APP_SRC		:= $(PTXDIST_WORKSPACE)/../code/app

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/app.targetinstall:
	@$(call targetinfo)
	@$(call install_init, app)

	@$(call install_tree, app, 0, 0, \
		$(APP_SRC), /usr/lib/app)

	@$(call install_alternative, app, 0, 0, 0644, /usr/lib/systemd/system/app.socket)
	@$(call install_alternative, app, 0, 0, 0644, /usr/lib/systemd/system/app.service)
	@$(call install_link,        app, ../app.service, /usr/lib/systemd/system/multi-user.target.wants/app.service)

	@$(call install_alternative, app, 0, 0, 0644, /usr/lib/systemd/system/app@.target)

ifdef PTXCONF_APP_ETCAPP
	@$(call install_alternative_tree, app, 0, 0, /etc/app)
endif

	@$(call install_finish,app)
	@$(call touch)


# vim: syntax=make
