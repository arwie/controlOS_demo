# -*-makefile-*-
#
# Copyright (C) 2025 by Artur Wiebe <artur@4wiebe.de>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_KEYS) += keys

KEYS_VERSION		:= 0.1
KEYS			:= keys
KEYS_URL		:= file://$(PTXDIST_WORKSPACE)/../keys/projectroot
KEYS_DIR		:= $(BUILDDIR)/${KEYS}

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

$(STATEDIR)/keys.compile:
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

$(STATEDIR)/keys.install:
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/keys.targetinstall:
	@$(call targetinfo)
	@$(call install_init, keys)

	#gpg
	@$(call install_copy,        keys, 0, 0, 0700, /etc/gpg)
	@$(call install_alternative, keys, 0, 0, 0644, /etc/gpg/update.pubkey)
	@$(call install_alternative, keys, 0, 0, 0644, /etc/gpg/backup.pubkey)
	@$(call install_alternative, keys, 0, 0, 0600, /etc/gpg/common.symkey)

	@$(call install_alternative, keys, 0, 0, 0600, /etc/gpg/gpg.conf)
	@$(call install_alternative, keys, 0, 0, 0644, /usr/lib/systemd/system/gpg-symkeys@.service)
	@$(call install_link,        keys, ../gpg-symkeys@.service, /usr/lib/systemd/system/basic.target.wants/gpg-symkeys@backup.service)

	# ssh
	@$(call install_copy,        keys, 0, 0, 0700, /root)
	@$(call install_copy,        keys, 0, 0, 0700, /root/.ssh)
	@$(call install_alternative, keys, 0, 0, 0600, /root/.ssh/id_rsa)
	@$(call install_alternative, keys, 0, 0, 0644, /root/.ssh/id_rsa.pub)
	@$(call install_alternative, keys, 0, 0, 0644, /root/.ssh/authorized_keys)
	@$(call install_alternative, keys, 0, 0, 0600, /etc/ssh/ssh_host_rsa_key)
	@$(call install_alternative, keys, 0, 0, 0644, /etc/ssh/ssh_host_rsa_key.pub)

	@$(call install_finish,keys)
	@$(call touch)


# vim: syntax=make
