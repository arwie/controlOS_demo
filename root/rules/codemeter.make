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

CODEMETER_VERSION		:= 7.60.5625.503
ifdef PTXCONF_ARCH_X86_64
CODEMETER_SOURCE		:= $(SRCDIR)/codemeter-lite_$(CODEMETER_VERSION)_amd64.deb
CODEMETER_MD5			:= 30c8d44a5f0e4fa938a6f2a6d90ad54b
CODEMETER_LIB			:= x86_64-linux-gnu
endif
ifdef PTXCONF_ARCH_ARM
CODEMETER_SOURCE		:= $(SRCDIR)/codemeter-lite_$(CODEMETER_VERSION)_armhf.deb
CODEMETER_MD5			:= eee6da0f1451c9378e7747c4daa83342
CODEMETER_LIB			:= arm-linux-gnueabihf
endif
ifdef PTXCONF_ARCH_ARM64
CODEMETER_SOURCE		:= $(SRCDIR)/codemeter-lite_$(CODEMETER_VERSION)_arm64.deb
CODEMETER_MD5			:= d3f7b22412416d740875c09b6d1c5e90
CODEMETER_LIB			:= aarch64-linux-gnu
endif
CODEMETER			:= codemeter-$(CODEMETER_VERSION)
CODEMETER_LICENSE		:= unknown

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

#$(STATEDIR)/codemeter.get:
#	@$(call targetinfo)
#	@$(call touch)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

$(STATEDIR)/codemeter.install:
	@$(call targetinfo)

	-fakeroot dpkg --force-all --root=$(CODEMETER_PKGDIR) --install $(CODEMETER_SOURCE)
	mv $(CODEMETER_PKGDIR)/lib/* $(CODEMETER_PKGDIR)/usr/lib

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

	@$(call install_copy, codemeter, 0, 0, 0755, -, /usr/sbin/CodeMeterLin)

	@$(call install_tree, codemeter, 0, 0, -, /usr/bin)

	@$(call install_glob, codemeter, 0, 0, \
		$(CODEMETER_PKGDIR)/usr/lib/$(CODEMETER_LIB), \
		/usr/lib, \
		*.so, */jni/*)

	@$(call install_copy, codemeter, 0, 0, 0644, -, /usr/lib/udev/rules.d/60-codemeter-lite.rules)

	@$(call install_alternative, codemeter, 0, 0, 0644, /usr/lib/systemd/system/codemeter.service)

	# CodeMeter overwrites Server.ini on startup (not very polite!)
	# -> link it to /run/codemeter and copy Sever.ini.src on startup
	@$(call install_alternative, codemeter, 1, 1, 0644, /etc/wibu/CodeMeter/Server.ini.src)	#daemon:daemon
	@$(call install_link, codemeter, /run/codemeter/Server.ini, /etc/wibu/CodeMeter/Server.ini)

	@$(call install_finish,codemeter)
	@$(call touch)


# vim: syntax=make
