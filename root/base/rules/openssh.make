# -*-makefile-*-
#
# Copyright (C) 2002, 2003 by Pengutronix e.K., Hildesheim, Germany
#               2009 by Marc Kleine-Budde <mkl@pengutronix.de>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_OPENSSH) += openssh

#
# Paths and names
#
OPENSSH_VERSION	:= 8.0p1
OPENSSH_MD5	:= bf050f002fe510e1daecd39044e1122d
OPENSSH		:= openssh-$(OPENSSH_VERSION)
OPENSSH_SUFFIX	:= tar.gz
OPENSSH_URL	:= \
	https://ftp.halifax.rwth-aachen.de/openbsd/OpenSSH/portable/$(OPENSSH).$(OPENSSH_SUFFIX) \
	https://mirror.hs-esslingen.de/pub/OpenBSD/OpenSSH/portable/$(OPENSSH).$(OPENSSH_SUFFIX)

OPENSSH_SOURCE	:= $(SRCDIR)/$(OPENSSH).$(OPENSSH_SUFFIX)
OPENSSH_DIR	:= $(BUILDDIR)/$(OPENSSH)
OPENSSH_LICENSE	:= BSD AND BSD-2-Clause AND BSD-3-Clause AND MIT AND Beerware AND ISC
OPENSSH_LICENSE_FILES := file://LICENCE;encoding=ISO-8859-1;md5=429658c6612f3a9b1293782366ab29d8

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

OPENSSH_CONF_ENV	:= \
	$(CROSS_ENV) \
	select_works_with_rlimit=yes \
	LD=$(COMPILER_PREFIX)gcc

OPENSSH_SANDBOX-y			:= seccomp_filter
# seccomp_filter sandbox is not supported for ppc
OPENSSH_SANDBOX-$(PTXCONF_ARCH_PPC)	:= rlimit

#
# autoconf
#
OPENSSH_CONF_TOOL	:= autoconf
OPENSSH_CONF_OPT	:= \
	$(CROSS_AUTOCONF_USR) \
	--libexecdir=/usr/sbin \
	--sysconfdir=/etc/ssh \
	$(GLOBAL_LARGE_FILE_OPTION) \
	--disable-pkcs11 \
	--disable-strip \
	--disable-etc-default-login \
	--disable-lastlog \
	--disable-utmp \
	--disable-utmpx \
	--disable-wtmp \
	--disable-wtmpx \
	--enable-libutil \
	--disable-pututline \
	--disable-pututxline \
	--with-openssl \
	--with-stackprotect \
	--with-hardening \
	--without-rpath \
	--without-Werror \
	--with-zlib=$(SYSROOT) \
	--without-ldns \
	--without-libedit \
	--without-audit \
	--with-pie \
	--without-ssl-engine \
	--without-pam \
	--with-privsep-user=sshd \
	--with-sandbox=$(OPENSSH_SANDBOX-y) \
	--$(call ptx/wwo, PTXCONF_GLOBAL_SELINUX)-selinux \
	--with-privsep-path=/var/run/sshd \
	--without-md5-passwords

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/openssh.targetinstall:
	@$(call targetinfo)

	@$(call install_init,  openssh)
	@$(call install_fixup, openssh,PRIORITY,optional)
	@$(call install_fixup, openssh,SECTION,base)
	@$(call install_fixup, openssh,AUTHOR,"Marc Kleine-Budde <mkl@pengutronix.de>")
	@$(call install_fixup, openssh,DESCRIPTION,missing)

ifdef PTXCONF_OPENSSH_SSH
	@$(call install_alternative, openssh, 0, 0, 0644, /etc/ssh/ssh_config)
	@$(call install_copy, openssh, 0, 0, 0755, -, \
		/usr/bin/ssh)
endif

ifdef PTXCONF_OPENSSH_SSHD
	@$(call install_alternative, openssh, 0, 0, 0644, /etc/ssh/sshd_config)
	@$(call install_copy, openssh, 0, 0, 0644, -, \
		/etc/ssh/moduli)
	@$(call install_copy, openssh, 0, 0, 0755, -, \
		/usr/sbin/sshd)
#	@$(call install_alternative, openssh, 0, 0, 0755, /etc/rc.once.d/openssh)
endif

ifdef PTXCONF_INITMETHOD_BBINIT
ifdef PTXCONF_OPENSSH_SSHD_STARTSCRIPT
	@$(call install_alternative, openssh, 0, 0, 0755, /etc/init.d/openssh)

ifneq ($(call remove_quotes,$(PTXCONF_OPENSSH_BBINIT_LINK)),)
	@$(call install_link, openssh, \
		../init.d/openssh, \
		/etc/rc.d/$(PTXCONF_OPENSSH_BBINIT_LINK))
endif
endif
endif
ifdef PTXCONF_INITMETHOD_SYSTEMD
ifdef PTXCONF_OPENSSH_SSHD_SYSTEMD_UNIT
	@$(call install_alternative, openssh, 0, 0, 0644, \
		/usr/lib/systemd/system/sshd.socket)
	@$(call install_alternative, openssh, 0, 0, 0644, \
		/usr/lib/systemd/system/sshd@.service)
	@$(call install_link, openssh, ../sshd.socket, \
		/usr/lib/systemd/system/sockets.target.wants/sshd.socket)
	@$(call install_alternative, openssh, 0, 0, 0644, \
		/usr/lib/tmpfiles.d/ssh.conf)
endif
endif

ifdef PTXCONF_OPENSSH_SCP
	@$(call install_copy, openssh, 0, 0, 0755, -, \
		/usr/bin/scp)
endif

ifdef PTXCONF_OPENSSH_SFTP
	@$(call install_copy, openssh, 0, 0, 0755, -, \
		/usr/bin/sftp)
endif

ifdef PTXCONF_OPENSSH_SFTP_SERVER
	@$(call install_copy, openssh, 0, 0, 0755, -, \
		/usr/sbin/sftp-server)
endif

ifdef PTXCONF_OPENSSH_KEYGEN
	@$(call install_copy, openssh, 0, 0, 0755, -, \
		/usr/bin/ssh-keygen)
endif

	@$(call install_finish, openssh)

	@$(call touch)

# vim: syntax=make
