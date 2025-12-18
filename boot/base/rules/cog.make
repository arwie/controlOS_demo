# -*-makefile-*-
#
# Copyright (C) 2019 by Philippe Normand <philn@igalia.com>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_COG) += cog

#
# Paths and names
#
COG_VERSION		:= 0.18.5
COG_MD5			:= 3df784f9930353ac4cb2d95fdd56e21d
COG			:= cog-$(COG_VERSION)
COG_SUFFIX		:= tar.xz
COG_URL			:= https://wpewebkit.org/releases/$(COG).$(COG_SUFFIX)
COG_SOURCE		:= $(SRCDIR)/$(COG).$(COG_SUFFIX)
COG_DIR			:= $(BUILDDIR)/$(COG)
COG_LICENSE		:= MIT
COG_LICENSE_FILES	:= file://COPYING;md5=bf1229cd7425b302d60cdb641b0ce5fb

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

#
# cmake
#
COG_CONF_TOOL	:= meson
COG_CONF_OPT	:= \
	$(CROSS_MESON_USR) \
	-Dcog_appid=com.igalia.Cog \
	-Dcog_dbus_control=$(call ptx/ifdef, PTXCONF_COG_REMOTE_DBUS_SYSTEM_BUS,system,user) \
	-Dcog_dbus_system_owner= \
	-Dcog_home_uri=https://ptxdist.org/ \
	-Ddocumentation=false \
	-Dmanpages=false \
	-Dplatforms=wayland \
	-Dplugin_path=/usr/lib/cog/modules \
	-Dprograms=true \
	-Dwayland_weston_content_protection=false \
	-Dwayland_weston_direct_display=false \
	-Dwpe_api=2.0

# ----------------------------------------------------------------------------
# Target-Install
# -----------------------------------------------------------------------------

$(STATEDIR)/cog.targetinstall:
	@$(call targetinfo)

	@$(call install_init, cog)
	@$(call install_fixup, cog,PRIORITY,optional)
	@$(call install_fixup, cog,SECTION,base)
	@$(call install_fixup, cog,AUTHOR,"Philippe Normand <philn@igalia.com>")
	@$(call install_fixup, cog,DESCRIPTION,"WPE launcher and webapp container")

	@$(call install_copy, cog, 0, 0, 0755, -, /usr/bin/cog)
	@$(call install_lib, cog, 0, 0, 0644, cog/modules/libcogplatform-wl)
	@$(call install_lib, cog, 0, 0, 0644, libcogcore)

ifdef PTXCONF_COG_REMOTE_DBUS_SYSTEM_BUS
	@$(call install_copy, cog, 0, 0, 0644, -, \
		/usr/share/dbus-1/system.d/com.igalia.Cog.conf)
endif

ifdef PTXCONF_COG_COGCTL
	@$(call install_copy, cog, 0, 0, 0755, -, /usr/bin/cogctl)
endif

	@$(call install_finish, cog)

	@$(call touch)

# vim: syntax=make
