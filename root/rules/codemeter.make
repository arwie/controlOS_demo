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

CODEMETER_VERSION		:= 8.20.6539.500
ifdef PTXCONF_ARCH_X86_64
CODEMETER			:= codemeter-lite_$(CODEMETER_VERSION)_amd64
CODEMETER_MD5			:= 0719e7c9f31d81c75b7b8f791813b9d2
CODEMETER_LIB			:= x86_64-linux-gnu
endif
ifdef PTXCONF_ARCH_ARM64
CODEMETER			:= codemeter-lite_$(CODEMETER_VERSION)_arm64
CODEMETER_MD5			:= 05aa58cf28f0f7607bceb6bf21533bfe
CODEMETER_LIB			:= aarch64-linux-gnu
endif
CODEMETER_URL			:= https://undefined
CODEMETER_SOURCE		:= $(SRCDIR)/$(CODEMETER).deb
CODEMETER_LICENSE		:= unknown

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

$(CODEMETER_SOURCE):
	@$(call targetinfo)
	@cp -v --update $(PTXDIST_WORKSPACE)/../codesys/$(CODEMETER).deb $(CODEMETER_SOURCE)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

$(STATEDIR)/codemeter.install:
	@$(call targetinfo)

	rm -rf $(CODEMETER_PKGDIR)/*
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
