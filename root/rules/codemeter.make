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
PACKAGES-$(PTXCONF_CODEMETER) += codemeter

CODEMETER_VERSION		:= 7.60.5615.502
ifdef PTXCONF_ARCH_X86_64
CODEMETER_SOURCE		:= $(SRCDIR)/codemeter-lite_$(CODEMETER_VERSION)_amd64.deb
CODEMETER_MD5			:= 2a5a777ce8f1caccd25acbaa9f30dd8c
CODEMETER_LIB			:= x86_64-linux-gnu
endif
ifdef PTXCONF_ARCH_ARM
CODEMETER_SOURCE		:= $(SRCDIR)/codemeter-lite_$(CODEMETER_VERSION)_armhf.deb
CODEMETER_MD5			:= 22459750fd6a02e12ccc50e5dd5ac966
CODEMETER_LIB			:= arm-linux-gnueabihf
endif
ifdef PTXCONF_ARCH_ARM64
CODEMETER_SOURCE		:= $(SRCDIR)/codemeter-lite_$(CODEMETER_VERSION)_arm64.deb
CODEMETER_MD5			:= a88b9a1b44b6af74a2b722aad6ff5cea
CODEMETER_LIB			:= aarch64-linux-gnu
endif
CODEMETER			:= codemeter-$(CODEMETER_VERSION)
CODEMETER_DIR			:= $(BUILDDIR)/$(CODEMETER)
CODEMETER_LICENSE		:= unknown

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

#$(STATEDIR)/codemeter.get:
#	@$(call targetinfo)
#	@$(call touch)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

$(STATEDIR)/codemeter.extract:
	@$(call targetinfo)
	fakeroot dpkg --force-all --root=$(CODEMETER_DIR) --unpack $(CODEMETER_SOURCE)
	@$(call touch)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

$(STATEDIR)/codemeter.compile:
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

$(STATEDIR)/codemeter.install:
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/codemeter.targetinstall:
	@$(call targetinfo)
	@$(call install_init, codemeter)
	@$(call install_fixup,codemeter,PRIORITY,optional)
	@$(call install_fixup,codemeter,SECTION,base)
	@$(call install_fixup,codemeter,AUTHOR,"Artur Wiebe <artur@4wiebe.de>")
	@$(call install_fixup,codemeter,DESCRIPTION,missing)

	@$(call install_copy, codemeter, 0, 0, 755, \
		$(CODEMETER_DIR)/usr/sbin/CodeMeterLin, \
		/usr/sbin/CodeMeterLin)

	@$(call install_tree, codemeter, 0, 0, \
		$(CODEMETER_DIR)/usr/bin, \
		/usr/bin)

	@$(call install_glob, codemeter, 0, 0, \
		$(CODEMETER_DIR)/usr/lib/$(CODEMETER_LIB), \
		/usr/lib, \
		*.so, */jni/*)

	@$(call install_copy, codemeter, 0, 0, 644, \
		$(CODEMETER_DIR)/lib/udev/rules.d/60-codemeter-lite.rules, \
		/usr/lib/udev/rules.d/60-codemeter-lite.rules)

	@$(call install_copy, codemeter, 0, 0, 644, \
		$(CODEMETER_DIR)/lib/systemd/system/codemeter.service, \
		/usr/lib/systemd/system/codemeter.service)

	@$(call install_alternative, codemeter, 0, 0, 0644, \
		/usr/lib/tmpfiles.d/codemeter.conf)

	@$(call install_alternative, codemeter, 1, 1, 0644, \
		/etc/wibu/CodeMeter/Server.ini)	#daemon:daemon

	@$(call install_finish,codemeter)
	@$(call touch)


# vim: syntax=make
