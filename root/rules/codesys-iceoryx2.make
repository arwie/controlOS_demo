# -*-makefile-*-
#
# Copyright (C) 2026 by Artur Wiebe <artur@4wiebe.de>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_CODESYS_ICEORYX2) += codesys-iceoryx2

#
# Paths and names
#
CODESYS_ICEORYX2_VERSION	:= 0.1
CODESYS_ICEORYX2		:= codesys-iceoryx2-$(CODESYS_ICEORYX2_VERSION)
CODESYS_ICEORYX2_URL		:= lndir://$(PTXDIST_WORKSPACE)/../codesys/CmpIceoryx2.cext
CODESYS_ICEORYX2_DIR		:= $(BUILDDIR)/$(CODESYS_ICEORYX2)
CODESYS_ICEORYX2_LICENSE	:= MIT

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

CODESYS_ICEORYX2_CONF_TOOL	:= NO
CODESYS_ICEORYX2_MAKE_ENV	:= $(CROSS_ENV)
CODESYS_ICEORYX2_MAKE_OPT	:= all

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

$(STATEDIR)/codesys-iceoryx2.install:
	@$(call targetinfo)
	@install -v -D -m644 $(CODESYS_ICEORYX2_DIR)/out/libCmpIceoryx2.so \
		$(CODESYS_ICEORYX2_PKGDIR)/opt/codesys/lib/libCmpIceoryx2.so
	@$(call touch)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/codesys-iceoryx2.targetinstall:
	@$(call targetinfo)
	@$(call install_init, codesys-iceoryx2)
	@$(call install_fixup,codesys-iceoryx2,PRIORITY,optional)
	@$(call install_fixup,codesys-iceoryx2,SECTION,base)
	@$(call install_fixup,codesys-iceoryx2,AUTHOR,"Artur Wiebe <artur@4wiebe.de>")
	@$(call install_fixup,codesys-iceoryx2,DESCRIPTION,missing)

	@$(call install_copy, codesys-iceoryx2, 0, 0, 0644, -, /opt/codesys/lib/libCmpIceoryx2.so)

	@$(call install_finish,codesys-iceoryx2)
	@$(call touch)


# vim: syntax=make
