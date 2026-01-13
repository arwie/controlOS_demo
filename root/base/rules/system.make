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
PACKAGES-$(PTXCONF_SYSTEM) += system

SYSTEM_VERSION	:= 0.1

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/system.targetinstall:
	@$(call targetinfo)
	@$(call install_init, system)
	
	# basics
	@$(call install_alternative, system, 0, 0, 0644, /boot/boot.conf)
	@$(call install_alternative, system, 0, 0, 0644, /usr/lib/systemd/system/var.mount.d/var.conf)
	@$(call install_alternative, system, 0, 0, 0644, /usr/lib/systemd/system/etc.mount.d/etc.conf)
	@$(call install_alternative, system, 0, 0, 0644, /etc/tmpfiles.d/system.conf)
	@$(call install_alternative, system, 0, 0, 0755, /usr/sbin/reboot-kexec)

	# networking
	@$(call install_copy,        system, 0, 0, 0755, /etc/iptables/rules.v4.d)
	@$(call install_alternative_tree, system, 0, 0,  /etc/systemd/network)
	@$(call install_alternative, system, 0, 0, 0644, /usr/lib/systemd/system/sys-subsystem-net-devices-lan.device)
	@$(call install_alternative, system, 0, 0, 0644, /usr/lib/systemd/system/network@.target)
	@$(call install_alternative, system, 0, 0, 0644, /usr/lib/systemd/system/hostapd.service)
	@$(call install_alternative, system, 0, 0, 0644, /usr/lib/systemd/system/hostapd-psk.service)
	@$(call install_alternative, system, 0, 0, 0644, /usr/lib/systemd/system/sys-subsystem-net-devices-syswlan.device)
	@$(call install_copy,        system, 0, 0, 0755, /etc/wpa_supplicant.conf.d)
	@$(call install_alternative, system, 0, 0, 0644, /usr/lib/systemd/system/sys-subsystem-net-devices-wlan.device)

	# update
	@$(call install_copy,        system, 0, 0, 0755, /mnt/init)
	@$(call install_copy,        system, 0, 0, 0755, /mnt/root)
	@$(call install_alternative, system, 0, 0, 0755, /usr/bin/update)
	@$(call install_alternative, system, 0, 0, 0755, /usr/sbin/update-apply)
	@$(call install_alternative, system, 0, 0, 0644, /usr/lib/systemd/system/update-apply.service)
	
	# backup
	@$(call install_alternative, system, 0, 0, 0755, /usr/bin/backup)
	@$(call install_alternative, system, 0, 0, 0644, /usr/lib/systemd/system/backup@.service)
	@$(call install_alternative, system, 0, 0, 0644, /usr/lib/systemd/system/backup.socket)
	@$(call install_link,        system, ../backup.socket, /usr/lib/systemd/system/sockets.target.wants/backup.socket)

	# development tools
	@$(call install_alternative, system, 0, 0, 0644, /usr/lib/systemd/system/debug.target)
	@$(call install_alternative, system, 0, 0, 0644, /usr/lib/systemd/system/remote@.service)
	
	# user levels
	@$(call install_alternative, system, 0, 0, 0644, /usr/lib/systemd/system/user@.target)
	@$(call install_alternative, system, 0, 0, 0644, /usr/lib/systemd/system/user@oem.target)
	@$(call install_alternative, system, 0, 0, 0644, /usr/lib/systemd/system/user@admin.target)
	@$(call install_link,        system, ../user@oem.target, /usr/lib/systemd/system/dev-disk-by\\x2dlabel-INSTALL.device.wants/user@oem.target)
	
	# journal helpers
	@$(call install_alternative, system, 0, 0, 0644, /usr/lib/systemd/system/journal-cleanup.service)
	@$(call install_alternative, system, 0, 0, 0644, /usr/lib/systemd/system/journal-cleanup.timer)
	@$(call install_link,        system, ../journal-cleanup.timer, /usr/lib/systemd/system/timers.target.wants/journal-cleanup.timer)

	@$(call install_alternative, system, 0, 0, 0644, /etc/issue.conf)
	@$(call install_copy,        system, 0, 0, 0755, /etc/app)

ifdef PTXCONF_SYSTEM_RT
	@$(call install_alternative, system, 0, 0, 0755, /usr/sbin/rt-setup-cpu)
	@$(call install_alternative, system, 0, 0, 0644, /usr/lib/systemd/system/rt-setup-cpu.service)
	@$(call install_link,        system, ../rt-setup-cpu.service, /usr/lib/systemd/system/basic.target.wants/rt-setup-cpu.service)
	
	@$(call install_alternative, system, 0, 0, 0755, /usr/sbin/rt-setup-irq)
	@$(call install_alternative, system, 0, 0, 0644, /usr/lib/systemd/system/rt-setup-irq@.service)
	
	@$(call install_alternative, system, 0, 0, 0644, /usr/lib/systemd/system/sys-subsystem-net-devices-ethc.device)
	@$(call install_alternative, system, 0, 0, 0644, /etc/systemd/network/ethercat.network)
endif

	@$(call install_finish,system)
	@$(call touch)


# vim: syntax=make
