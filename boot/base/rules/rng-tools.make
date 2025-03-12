# -*-makefile-*-
#
# Copyright (C) 2014 by Andreas Pretzsch <apr@cn-eng.de>
#               2018 by Juergen Borleis <jbe@pengutronix.de>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

PACKAGES-$(PTXCONF_RNG_TOOLS) += rng-tools

RNG_TOOLS_VERSION	:= 6.17
RNG_TOOLS_MD5		:= 07d548e8b75ffb4eedc0058b3802af0b
RNG_TOOLS		:= rng-tools-$(RNG_TOOLS_VERSION)
RNG_TOOLS_SUFFIX	:= tar.gz
RNG_TOOLS_URL		:= https://github.com/nhorman/rng-tools/archive/v$(RNG_TOOLS_VERSION).$(RNG_TOOLS_SUFFIX)
RNG_TOOLS_SOURCE	:= $(SRCDIR)/$(RNG_TOOLS).$(RNG_TOOLS_SUFFIX)
RNG_TOOLS_DIR		:= $(BUILDDIR)/$(RNG_TOOLS)
RNG_TOOLS_LICENSE	:= GPL-2.0-or-later
RNG_TOOLS_LICENSE_FILES	:= \
	file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263 \
	file://rngd.c;startline=12;endline=26;md5=8737e0a69b00f9cb52b9411c81aaa1d5 \
	file://rngtest.c;startline=7;endline=21;md5=0bf96e235e77c1ff6cab766073094c7f

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

RNG_TOOLS_CONF_TOOL	:= autoconf
RNG_TOOLS_CONF_OPT	:= \
	$(CROSS_AUTOCONF_USR) \
	--disable-jitterentropy \
	--without-nistbeacon \
	--without-pkcs11 \
	--without-qrypt \
	--without-rtlsdr \
	--without-libargp

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/rng-tools.targetinstall:
	@$(call targetinfo)

	@$(call install_init, rng-tools)
	@$(call install_fixup, rng-tools,PRIORITY,optional)
	@$(call install_fixup, rng-tools,SECTION,base)
	@$(call install_fixup, rng-tools,AUTHOR,"Andreas Pretzsch <apr@cn-eng.de>")
	@$(call install_fixup, rng-tools,DESCRIPTION,"random number generator daemon - seed kernel random from hwrng")

ifdef PTXCONF_RNG_TOOLS_RNGD
	@$(call install_copy, rng-tools, 0, 0, 0755, -, /usr/sbin/rngd)
endif
ifdef PTXCONF_RNG_TOOLS_STARTSCRIPT
	@$(call install_alternative, rng-tools, 0, 0, 0755, /etc/init.d/rngd)
ifneq ($(call remove_quotes,$(PTXCONF_RNG_TOOLS_BBINIT_LINK)),)
	@$(call install_link, rng-tools, \
		../init.d/rngd, \
		/etc/rc.d/$(PTXCONF_RNG_TOOLS_BBINIT_LINK))
endif
endif
ifdef PTXCONF_RNG_TOOLS_SYSTEMD_UNIT
	@$(call install_alternative, rng-tools, 0, 0, 0644, \
		/usr/lib/systemd/system/rngd.service)
	@$(call install_link, rng-tools, ../rngd.service, \
		/usr/lib/systemd/system/basic.target.wants/rngd.service)
endif
ifdef PTXCONF_RNG_TOOLS_RNGTEST
	@$(call install_copy, rng-tools, 0, 0, 0755, -, /usr/bin/rngtest)
endif
	@$(call install_finish, rng-tools)

	@$(call touch)

# vim: syntax=make
