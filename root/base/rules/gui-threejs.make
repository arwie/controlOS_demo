# -*-makefile-*-
#
# Copyright (C) 2023 by Artur Wiebe <artur@4wiebe.de>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_GUI_THREEJS) += gui-threejs

#
# Paths and names
#
GUI_THREEJS_VERSION		:= r158
GUI_THREEJS_MD5			:= 8377ec26caa05069907c42af865000d5
GUI_THREEJS			:= threejs-$(GUI_THREEJS_VERSION)
GUI_THREEJS_SUFFIX		:= tar.gz
GUI_THREEJS_URL			:= https://github.com/mrdoob/three.js/archive/refs/tags/$(GUI_THREEJS_VERSION).$(GUI_THREEJS_SUFFIX)
GUI_THREEJS_SOURCE		:= $(SRCDIR)/$(GUI_THREEJS).$(GUI_THREEJS_SUFFIX)
GUI_THREEJS_DIR			:= $(BUILDDIR)/$(GUI_THREEJS)
GUI_THREEJS_LICENSE		:= MIT
GUI_THREEJS_LICENSE_FILES	:= file://LICENSE;md5=f655d7763863cf6503d6158421a95175

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

$(STATEDIR)/gui-threejs.compile:
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

$(STATEDIR)/gui-threejs.install:
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/gui-threejs.targetinstall:
	@$(call targetinfo)
	@$(call install_init, gui-threejs)
	@$(call install_fixup, gui-threejs,PRIORITY,optional)
	@$(call install_fixup, gui-threejs,SECTION,base)
	@$(call install_fixup, gui-threejs,AUTHOR,"Artur Wiebe <artur@4wiebe.de>")
	@$(call install_fixup, gui-threejs,DESCRIPTION,missing)

	@$(call install_copy, gui-threejs, 0, 0, 0644, \
		$(GUI_THREEJS_DIR)/build/three.module.min.js, /usr/lib/gui/static/three/three.module.js)

	@$(call install_copy, gui-threejs, 0, 0, 0644, \
		$(GUI_THREEJS_DIR)/examples/jsm/controls/OrbitControls.js, /usr/lib/gui/static/three/OrbitControls.js)
	@$(call install_copy, gui-threejs, 0, 0, 0644, \
		$(GUI_THREEJS_DIR)/examples/jsm/loaders/STLLoader.js, /usr/lib/gui/static/three/STLLoader.js)

	@$(call install_finish, gui-threejs)
	@$(call touch)

# vim: syntax=make
