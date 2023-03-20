# -*-makefile-*-
#
# Copyright (C) 2010 by Robert Schwebel <r.schwebel@pengutronix.de>
#               2011-2017 by Michael Olbrich <m.olbrich@pengutronix.de>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_SYSTEMD) += systemd

#
# Paths and names
#
SYSTEMD_VERSION		:= 252.5
SYSTEMD_VERSION_MAJOR	:= $(firstword $(subst -, ,$(subst ., ,$(SYSTEMD_VERSION))))
SYSTEMD_MD5		:= 31d247df965121f453f1339371cca831
SYSTEMD			:= systemd-$(SYSTEMD_VERSION)
SYSTEMD_SUFFIX		:= tar.gz
ifeq ($(SYSTEMD_VERSION),$(SYSTEMD_VERSION_MAJOR))
SYSTEMD_URL		:= https://github.com/systemd/systemd/archive/v$(SYSTEMD_VERSION).$(SYSTEMD_SUFFIX)
else
SYSTEMD_URL		:= https://github.com/systemd/systemd-stable/archive/v$(SYSTEMD_VERSION).$(SYSTEMD_SUFFIX)
endif
SYSTEMD_SOURCE		:= $(SRCDIR)/$(SYSTEMD).$(SYSTEMD_SUFFIX)
SYSTEMD_DIR		:= $(BUILDDIR)/$(SYSTEMD)
SYSTEMD_LICENSE		:= GPL-2.0-or-later AND LGPL-2.1-only
SYSTEMD_LICENSE_FILES	:= \
	file://LICENSE.GPL2;md5=751419260aa954499f7abaabaa882bbe \
	file://LICENSE.LGPL2.1;md5=4fbd65380cdd255951079008b364516c

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

# x86: systemd segfaults at startup when built with PIE
# PPC: compiling fails when building with PIE
ifneq ($(PTXCONF_ARCH_X86)$(PTXCONF_ARCH_PPC),)
SYSTEMD_WRAPPER_BLACKLIST := TARGET_HARDEN_PIE
endif

ifdef PTXCONF_KERNEL_HEADER
SYSTEMD_CPPFLAGS	:= \
	-isystem $(KERNEL_HEADERS_INCLUDE_DIR)
endif

SYSTEMD_CONF_TOOL	:= meson
SYSTEMD_CONF_OPT	:= \
	$(CROSS_MESON_USR) \
	-Dacl=$(call ptx/truefalse,PTXCONF_SYSTEMD_UNITS_USER) \
	-Dadm-group=true \
	-Danalyze=true \
	-Dapparmor=false \
	-Daudit=false \
	-Dbacklight=false \
	-Dbinfmt=false \
	-Dblkid=true \
	-Dbpf-framework=false \
	-Dbump-proc-sys-fs-file-max=true \
	-Dbump-proc-sys-fs-nr-open=true \
	-Dbzip2=false \
	-Dcertificate-root=/etc/ssl \
	-Dcompat-mutable-uid-boundaries=false \
	-Dcoredump=$(call ptx/truefalse,PTXCONF_SYSTEMD_COREDUMP) \
	-Dcreate-log-dirs=false \
	-Dcryptolib=auto \
	-Ddbus=false \
	-Ddbuspolicydir=/usr/share/dbus-1/system.d \
	-Ddbussessionservicedir=/usr/share/dbus-1/services \
	-Ddbussystemservicedir=/usr/share/dbus-1/system-services \
	-Ddefault-dns-over-tls=no \
	-Ddefault-dnssec=no \
	-Ddefault-hierarchy=unified \
	-Ddefault-kill-user-processes=true \
	-Ddefault-llmnr=yes \
	-Ddefault-locale=C \
	-Ddefault-mdns=yes \
	-Ddefault-net-naming-scheme=$(call remove_quotes,$(PTXCONF_SYSTEMD_DEFAULT_NET_NAMING_SCHEME)) \
	-Ddev-kvm-mode=0660 \
	-Ddns-over-tls=false \
	-Ddns-servers= \
	-Defi=false \
	-Delfutils=$(call ptx/truefalse,PTXCONF_SYSTEMD_COREDUMP) \
	-Denvironment-d=false \
	-Dfallback-hostname=$(call ptx/ifdef,PTXCONF_ROOTFS_ETC_HOSTNAME,$(PTXCONF_ROOTFS_ETC_HOSTNAME),ptxdist) \
	-Dfdisk=false \
	-Dfexecve=false \
	-Dfirstboot=false \
	-Dfuzz-tests=false \
	-Dgcrypt=false \
	-Dglib=false \
	-Dgnutls=false \
	-Dgroup-render-mode=0666 \
	-Dgshadow=false \
	-Dhibernate=false \
	-Dhomed=false \
	-Dhostnamed=$(call ptx/truefalse,PTXCONF_SYSTEMD_HOSTNAMED) \
	-Dhtml=false \
	-Dhwdb=$(call ptx/truefalse,PTXCONF_SYSTEMD_UDEV_HWDB) \
	-Didn=false \
	-Dima=false \
	-Dimportd=false \
	-Dinitrd=false \
	-Dinstall-sysconfdir=true \
	-Dinstall-tests=false \
	-Dkernel-install=false \
	-Dkexec-path=/usr/sbin/kexec \
	-Dkmod=true \
	-Dkmod-path=/usr/bin/kmod \
	-Dldconfig=false \
	-Dlibcryptsetup=false \
	-Dlibcurl=false \
	-Dlibfido2=false \
	-Dlibidn=false \
	-Dlibidn2=false \
	-Dlibiptc=$(call ptx/truefalse,PTXCONF_SYSTEMD_IPMASQUERADE) \
	-Dlink-boot-shared=true \
	-Dlink-journalctl-shared=true \
	-Dlink-networkd-shared=true \
	-Dlink-systemctl-shared=true \
	-Dlink-timesyncd-shared=true \
	-Dlink-udev-shared=true \
	-Dllvm-fuzz=false \
	-Dloadkeys-path=/usr/bin/loadkeys \
	-Dlocaled=$(call ptx/truefalse,PTXCONF_SYSTEMD_LOCALES) \
	-Dlog-message-verification=false \
	-Dlog-trace=false \
	-Dlogind=$(call ptx/truefalse,PTXCONF_SYSTEMD_LOGIND) \
	-Dlz4=$(call ptx/truefalse,PTXCONF_SYSTEMD_LZ4) \
	-Dmachined=$(call ptx/truefalse,PTXCONF_SYSTEMD_NSPAWN) \
	-Dman=false \
	-Dmemory-accounting-default=true \
	-Dmicrohttpd=$(call ptx/truefalse,PTXCONF_SYSTEMD_MICROHTTPD) \
	-Dmode=release \
	-Dmount-path=/usr/bin/mount \
	-Dnetworkd=$(call ptx/truefalse,PTXCONF_SYSTEMD_NETWORK) \
	-Dnobody-group=nogroup \
	-Dnobody-user=nobody \
	-Dnscd=false \
	-Dnss-myhostname=true \
	-Dnss-mymachines=$(call ptx/truefalse,PTXCONF_SYSTEMD_NSPAWN) \
	-Dnss-resolve=$(call ptx/truefalse,PTXCONF_SYSTEMD_NETWORK) \
	-Dnss-systemd=true \
	-Dntp-servers= \
	-Dok-color=green \
	-Doomd=false \
	-Dopenssl=$(call ptx/truefalse,PTXCONF_SYSTEMD_OPENSSL) \
	-Doss-fuzz=false \
	-Dp11kit=false \
	-Dpam=false \
	-Dpcre2=$(call ptx/truefalse,PTXCONF_SYSTEMD_PCRE2) \
	-Dpolkit=$(call ptx/truefalse,PTXCONF_SYSTEMD_POLKIT) \
	-Dportabled=false \
	-Dpstore=false \
	-Dpwquality=false \
	-Dqrencode=false \
	-Dquotacheck=$(call ptx/truefalse,PTXCONF_SYSTEMD_QUOTACHECK) \
	-Dquotacheck-path=/usr/sbin/quotacheck \
	-Dquotaon-path=/usr/sbin/quotaon \
	-Drandomseed=$(call ptx/falsetrue,PTXCONF_SYSTEMD_DISABLE_RANDOM_SEED) \
	-Dremote=$(call ptx/ifdef,PTXCONF_SYSTEMD_JOURNAL_REMOTE,auto,false) \
	-Drepart=false \
	-Dresolve=$(call ptx/truefalse,PTXCONF_SYSTEMD_NETWORK) \
	-Drfkill=false \
	-Dseccomp=$(call ptx/truefalse,PTXCONF_SYSTEMD_SECCOMP) \
	-Dselinux=$(call ptx/truefalse,PTXCONF_GLOBAL_SELINUX) \
	-Dservice-watchdog=3min \
	-Dsetfont-path=/usr/bin/setfont \
	-Dshared-lib-tag=$(SYSTEMD_VERSION_MAJOR) \
	-Dskip-deps=false \
	-Dslow-tests=false \
	-Dsmack=false \
	-Dsplit-bin=true \
	-Dsplit-usr=false \
	-Dstandalone-binaries=false \
	-Dstatic-libsystemd=false \
	-Dstatic-libudev=false \
	-Dstatus-unit-format-default=name \
	-Dsulogin-path=/sbin/sulogin \
	-Dsupport-url=https://www.ptxdist.org/ \
	-Dsysext=false \
	-Dsystem-alloc-gid-min=1 \
	-Dsystem-alloc-uid-min=1 \
	-Dsystem-gid-max=999 \
	-Dsystem-uid-max=999 \
	-Dsysusers=false \
	-Dsysvinit-path= \
	-Dsysvrcnd-path= \
	-Dtelinit-path=/usr/bin/telinit \
	-Dtests=false \
	-Dtime-epoch=$(SOURCE_DATE_EPOCH) \
	-Dtimedated=$(call ptx/truefalse,PTXCONF_SYSTEMD_TIMEDATE) \
	-Dtimesyncd=$(call ptx/truefalse,PTXCONF_SYSTEMD_TIMEDATE) \
	-Dtmpfiles=true \
	-Dtpm=false \
	-Dtpm2=false \
	-Dtranslations=false \
	-Dtty-gid=112 \
	-Dumount-path=/usr/bin/umount \
	-Durlify=false \
	-Duserdb=false \
	-Dusers-gid=-1 \
	-Dutmp=false \
	-Dvalgrind=false \
	-Dvconsole=$(call ptx/truefalse,PTXCONF_SYSTEMD_VCONSOLE) \
	-Dversion-tag=$(SYSTEMD_VERSION) \
	-Dwheel-group=false \
	-Dxdg-autostart=false \
	-Dxkbcommon=false \
	-Dxz=$(call ptx/truefalse,PTXCONF_SYSTEMD_XZ) \
	-Dzlib=false \
	-Dzstd=$(call ptx/truefalse,PTXCONF_SYSTEMD_ZSTD)

# FIXME kernel from systemd README:
# - devtmpfs, cgroups are mandatory.
# - autofs4, ipv6  optional but strongly recommended

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

$(STATEDIR)/systemd.install:
	@$(call targetinfo)
	@$(call world/install, SYSTEMD)
#	# no interactive password prompts
	@rm -v $(SYSTEMD_PKGDIR)/usr/lib/systemd/system/systemd-ask-password-console.path
	@rm -v $(SYSTEMD_PKGDIR)/usr/lib/systemd/system/systemd-ask-password-console.service
	@rm -v $(SYSTEMD_PKGDIR)/usr/lib/systemd/system/systemd-ask-password-wall.path
	@rm -v $(SYSTEMD_PKGDIR)/usr/lib/systemd/system/systemd-ask-password-wall.service
	@rm -v $(SYSTEMD_PKGDIR)/usr/lib/systemd/system/multi-user.target.wants/systemd-ask-password-wall.path
	@rm -v $(SYSTEMD_PKGDIR)/usr/lib/systemd/system/sysinit.target.wants/systemd-ask-password-console.path

#	# no ConditionNeedsUpdate= services
	@grep -Rl '^ConditionNeedsUpdate=' $(SYSTEMD_PKGDIR)/usr/lib/systemd/system | \
		xargs rm -v

#	# don't touch /etc and /home
	@rm -v $(SYSTEMD_PKGDIR)/usr/lib/tmpfiles.d/etc.conf
	@rm -v $(SYSTEMD_PKGDIR)/usr/lib/tmpfiles.d/home.conf
	@$(call touch)

ifdef PTXCONF_SYSTEMD_HWDB
$(STATEDIR)/systemd-hwdb.extract.post: $(STATEDIR)/systemd.install.post
endif

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

SYSTEMD_HELPER := \
	systemd \
	systemd-ac-power \
	systemd-cgroups-agent \
	$(call ptx/ifdef, PTXCONF_SYSTEMD_COREDUMP,systemd-coredump) \
	systemd-fsck \
	systemd-growfs \
	$(call ptx/ifdef, PTXCONF_SYSTEMD_HOSTNAMED,systemd-hostnamed) \
	systemd-journald \
	$(call ptx/ifdef, PTXCONF_SYSTEMD_JOURNAL_REMOTE,systemd-journal-remote) \
	$(call ptx/ifdef, PTXCONF_SYSTEMD_LOCALES,systemd-localed) \
	$(call ptx/ifdef, PTXCONF_SYSTEMD_LOGIND,systemd-logind) \
	$(call ptx/ifdef, PTXCONF_SYSTEMD_NSPAWN,systemd-machined) \
	systemd-makefs \
	systemd-modules-load \
	$(call ptx/ifdef, PTXCONF_SYSTEMD_NETWORK,systemd-networkd) \
	$(call ptx/ifdef, PTXCONF_SYSTEMD_NETWORK,systemd-networkd-wait-online) \
	$(call ptx/ifdef, PTXCONF_SYSTEMD_QUOTACHECK,systemd-quotacheck) \
	$(call ptx/ifdef, PTXCONF_SYSTEMD_DISABLE_RANDOM_SEED,,systemd-random-seed) \
	systemd-remount-fs \
	systemd-reply-password \
	$(call ptx/ifdef, PTXCONF_SYSTEMD_NETWORK,systemd-resolved) \
	systemd-shutdown \
	systemd-sleep \
	systemd-socket-proxyd \
	systemd-sulogin-shell \
	systemd-sysctl \
	$(call ptx/ifdef, PTXCONF_SYSTEMD_TIMEDATE,systemd-time-wait-sync) \
	$(call ptx/ifdef, PTXCONF_SYSTEMD_TIMEDATE,systemd-timedated) \
	$(call ptx/ifdef, PTXCONF_SYSTEMD_TIMEDATE,systemd-timesyncd) \
	systemd-update-done \
	$(call ptx/ifdef, PTXCONF_SYSTEMD_UNITS_USER,systemd-user-runtime-dir) \
	$(call ptx/ifdef, PTXCONF_SYSTEMD_VCONSOLE,systemd-vconsole-setup)

SYSTEMD_UDEV_HELPER-y :=

SYSTEMD_UDEV_HELPER-$(PTXCONF_SYSTEMD_UDEV_PERSISTENT_ATA)	+= ata_id
SYSTEMD_UDEV_HELPER-$(PTXCONF_SYSTEMD_UDEV_PERSISTENT_CDROM)	+= cdrom_id
SYSTEMD_UDEV_HELPER-$(PTXCONF_ARCH_X86)				+= dmi_memory_id
SYSTEMD_UDEV_HELPER-$(PTXCONF_SYSTEMD_UDEV_PERSISTENT_FIDO)	+= fido_id
SYSTEMD_UDEV_HELPER-$(PTXCONF_SYSTEMD_UDEV_PERSISTENT_SCSI)	+= scsi_id
SYSTEMD_UDEV_HELPER-$(PTXCONF_SYSTEMD_UDEV_PERSISTENT_V4L)	+= v4l_id
SYSTEMD_UDEV_HELPER-$(PTXCONF_SYSTEMD_UDEV_MTD_PROBE)		+= mtd_probe

SYSTEMD_UDEV_RULES-y := \
	50-udev-default.rules \
	60-persistent-alsa.rules \
	60-persistent-input.rules \
	60-persistent-storage-tape.rules \
	60-persistent-storage.rules \
	60-block.rules \
	60-drm.rules \
	60-input-id.rules \
	60-serial.rules \
	64-btrfs.rules \
	75-net-description.rules \
	78-sound-card.rules \
	80-drivers.rules \
	80-net-setup-link.rules \
	99-systemd.rules

SYSTEMD_UDEV_RULES-$(PTXCONF_SYSTEMD_UDEV_HWDB) += \
	60-autosuspend.rules \
	60-evdev.rules \
	60-sensor.rules \
	70-joystick.rules \
	70-mouse.rules \
	70-touchpad.rules

SYSTEMD_UDEV_RULES-$(PTXCONF_SYSTEMD_LOGIND) += \
	70-power-switch.rules \
	71-seat.rules \
	73-seat-late.rules

SYSTEMD_UDEV_RULES-$(PTXCONF_SYSTEMD_VCONSOLE) += \
	90-vconsole.rules

SYSTEMD_UDEV_RULES-$(PTXCONF_SYSTEMD_UDEV_PERSISTENT_CDROM)	+= 60-cdrom_id.rules
SYSTEMD_UDEV_RULES-$(PTXCONF_SYSTEMD_UDEV_PERSISTENT_FIDO)	+= 60-fido-id.rules
SYSTEMD_UDEV_RULES-$(PTXCONF_SYSTEMD_UDEV_PERSISTENT_V4L)	+= 60-persistent-v4l.rules
SYSTEMD_UDEV_RULES-$(PTXCONF_ARCH_X86)				+= 70-memory.rules
SYSTEMD_UDEV_RULES-$(PTXCONF_SYSTEMD_UDEV_MTD_PROBE)		+= 75-probe_mtd.rules

$(STATEDIR)/systemd.targetinstall:
	@$(call targetinfo)

	@$(call install_init,  systemd)
	@$(call install_fixup, systemd,PRIORITY,optional)
	@$(call install_fixup, systemd,SECTION,base)
	@$(call install_fixup, systemd,AUTHOR,"Robert Schwebel <r.schwebel@pengutronix.de>")
	@$(call install_fixup, systemd,DESCRIPTION,missing)

	@$(call install_lib, systemd, 0, 0, 0644, libsystemd)
	@$(call install_lib, systemd, 0, 0, 0644, systemd/libsystemd-core-$(SYSTEMD_VERSION_MAJOR))
	@$(call install_lib, systemd, 0, 0, 0644, systemd/libsystemd-shared-$(SYSTEMD_VERSION_MAJOR))

	@$(call install_lib, systemd, 0, 0, 0644, libnss_myhostname)
	@$(call install_lib, systemd, 0, 0, 0644, libnss_systemd)

#	# daemon + tools
	@$(call install_copy, systemd, 0, 0, 0755, -, /usr/bin/systemctl)
	@$(call install_copy, systemd, 0, 0, 0755, -, /usr/bin/journalctl)
	@$(call install_copy, systemd, 0, 0, 0755, -, /usr/bin/systemd-escape)
	@$(call install_copy, systemd, 0, 0, 0755, -, /usr/bin/systemd-machine-id-setup)
	@$(call install_copy, systemd, 0, 0, 0755, -, /usr/bin/systemd-notify)
	@$(call install_copy, systemd, 0, 0, 0755, -, /usr/bin/systemd-tmpfiles)
	@$(call install_copy, systemd, 0, 0, 0755, -, /usr/bin/busctl)
ifdef PTXCONF_SYSTEMD_HOSTNAMED
	@$(call install_copy, systemd, 0, 0, 0755, -, /usr/bin/hostnamectl)
endif
	@$(call install_copy, systemd, 0, 0, 0755, -, /usr/bin/systemd-analyze)
	@$(call install_copy, systemd, 0, 0, 0755, -, /usr/bin/systemd-cat)
	@$(call install_copy, systemd, 0, 0, 0755, -, /usr/bin/systemd-cgls)
	@$(call install_copy, systemd, 0, 0, 0755, -, /usr/bin/systemd-cgtop)
	@$(call install_copy, systemd, 0, 0, 0755, -, /usr/bin/systemd-delta)
	@$(call install_copy, systemd, 0, 0, 0755, -, /usr/bin/systemd-detect-virt)
	@$(call install_copy, systemd, 0, 0, 0755, -, /usr/bin/systemd-mount)
	@$(call install_copy, systemd, 0, 0, 0755, -, /usr/bin/systemd-path)
	@$(call install_copy, systemd, 0, 0, 0755, -, /usr/bin/systemd-run)
	@$(call install_copy, systemd, 0, 0, 0755, -, /usr/bin/systemd-socket-activate)
	@$(call install_copy, systemd, 0, 0, 0755, -, /usr/bin/systemd-stdio-bridge)
	@$(call install_link, systemd, systemd-mount, /usr/bin/systemd-umount)

ifdef PTXCONF_SYSTEMD_NSPAWN
	@$(call install_lib, systemd, 0, 0, 0644, libnss_mymachines)
	@$(call install_copy, systemd, 0, 0, 0755, -, /usr/bin/machinectl)
	@$(call install_copy, systemd, 0, 0, 0755, -, /usr/bin/systemd-nspawn)
endif

	@$(call install_tree, systemd, 0, 0, -, /usr/lib/systemd/system-generators/)
	@$(foreach helper, $(SYSTEMD_HELPER), \
		$(call install_copy, systemd, 0, 0, 0755, -, \
			/usr/lib/systemd/$(helper))$(ptx/nl))

#	# configuration
	@$(call install_alternative, systemd, 0, 0, 0644, \
		/etc/systemd/system.conf)
	@$(call install_alternative, systemd, 0, 0, 0644, \
		/etc/systemd/journald.conf)

	@$(call install_tree, systemd, 0, 0, -, /usr/share/dbus-1/system.d/)

	@$(call install_tree, systemd, 0, 0, -, /usr/lib/tmpfiles.d/)
	@$(call install_copy, systemd, 0, 0, 0644, -, /usr/lib/sysctl.d/50-default.conf)

ifdef PTXCONF_SYSTEMD_DBUS_SERVICES
	@$(call install_copy, systemd, 0, 0, 0644, -, \
		/usr/share/dbus-1/services/org.freedesktop.systemd1.service)
	@$(call install_tree, systemd, 0, 0, -, /usr/share/dbus-1/system-services/)
endif

#	# systemd expects this directory to exist.
	@$(call install_copy, systemd, 0, 0, 0755, /var/lib/systemd)
	@$(call install_copy, systemd, 0, 0, 0755, /var/lib/systemd/coredump)
	@$(call install_copy, systemd, 0, 0, 0700, /var/lib/machines)
	@$(call install_copy, systemd, 0, 0, 0700, /var/lib/private)
	@$(call install_copy, systemd, 0, 0, 0700, /var/cache/private)

#	# units
	@$(call install_tree, systemd, 0, 0, -, /usr/lib/systemd/system/)
	@$(call install_link, systemd, ../remote-fs.target,  \
		/usr/lib/systemd/system/multi-user.target.wants/remote-fs.target)
	@$(call install_link, systemd, multi-user.target,  \
		/usr/lib/systemd/system/default.target)
ifdef PTXCONF_SYSTEMD_UNITS_USER
	@$(call install_tree, systemd, 0, 0, -, /usr/lib/systemd/user/)
endif

	@$(call install_alternative, systemd, 0, 0, 0644, /etc/profile.d/systemd.sh)

ifdef PTXCONF_INITMETHOD_SYSTEMD
	@$(call install_link, systemd, ../lib/systemd/systemd, /usr/sbin/init)
	@$(call install_link, systemd, ../bin/systemctl, /usr/sbin/halt)
	@$(call install_link, systemd, ../bin/systemctl, /usr/sbin/poweroff)
	@$(call install_link, systemd, ../bin/systemctl, /usr/sbin/reboot)
	@$(call install_link, systemd, ../bin/systemctl, /usr/sbin/runlevel)
	@$(call install_link, systemd, ../bin/systemctl, /usr/sbin/shutdown)
	@$(call install_link, systemd, ../bin/systemctl, /usr/sbin/telinit)
endif

ifdef PTXCONF_SYSTEMD_COREDUMP
	@$(call install_copy, systemd, 0, 0, 0644, -, /usr/lib/sysctl.d/50-coredump.conf)
	@$(call install_copy, systemd, 0, 0, 0755, -, /usr/bin/coredumpctl)
	@$(call install_alternative, systemd, 0, 0, 0644, /etc/systemd/coredump.conf)
endif

ifdef PTXCONF_SYSTEMD_JOURNAL_REMOTE
	@$(call install_alternative, systemd, 0, 0, 0644, \
		/etc/systemd/journal-remote.conf)
endif

ifdef PTXCONF_SYSTEMD_LOCALES
	@$(call install_copy, systemd, 0, 0, 0755, -, /usr/bin/localectl)
	@$(call install_copy, systemd, 0, 0, 0644, -, /usr/share/systemd/kbd-model-map)
endif

ifdef PTXCONF_SYSTEMD_LOGIND
	@$(call install_copy, systemd, 0, 0, 0755, -, /usr/bin/loginctl)
	@$(call install_copy, systemd, 0, 0, 0755, -, /usr/bin/systemd-inhibit)
	@$(call install_alternative, systemd, 0, 0, 0644, \
		/etc/systemd/logind.conf)
endif

ifdef PTXCONF_SYSTEMD_NETWORK
	@$(call install_copy, systemd, 0, 0, 0755, -, /usr/bin/networkctl)
	@$(call install_copy, systemd, 0, 0, 0755, -, /usr/bin/resolvectl)
	@$(call install_copy, systemd, 0, 0, 0755, -, /usr/bin/systemd-resolve)
	@$(call install_copy, systemd, 0, 0, 0755, -, /usr/lib/systemd/systemd-network-generator)
	@$(call install_lib, systemd, 0, 0, 0644, libnss_resolve)
	@$(call install_copy, systemd, 0, 0, 0644, -, /usr/lib/systemd/resolv.conf)
	@$(call install_alternative, systemd, 0, 0, 0644, \
		/etc/systemd/resolved.conf)
	@$(call install_link, systemd, ../systemd-resolved.service,  \
		/usr/lib/systemd/system/multi-user.target.wants/systemd-resolved.service)
	@$(call install_link, systemd, ../systemd-networkd.service,  \
		/usr/lib/systemd/system/multi-user.target.wants/systemd-networkd.service)
	@$(call install_link, systemd, ../systemd-networkd.socket,  \
		/usr/lib/systemd/system/sockets.target.wants/systemd-networkd.socket)
	@$(call install_link, systemd, ../systemd-networkd-wait-online.service,  \
		/usr/lib/systemd/system/network-online.target.wants/systemd-networkd-wait-online.service)

	@$(call install_tree, systemd, 0, 0, -, /usr/lib/systemd/network)
	@$(call install_alternative_tree, systemd, 0, 0, /usr/lib/systemd/network)
else
	@$(call install_alternative, systemd, 0, 0, 0644, \
		/usr/lib/systemd/network/99-default.link)
endif

ifdef PTXCONF_SYSTEMD_POLKIT
	@$(call install_alternative_tree, systemd, 0, 0, /usr/share/polkit-1)
endif

ifdef PTXCONF_SYSTEMD_TIMEDATE
	@$(call install_copy, systemd, 0, 0, 0755, -, /usr/bin/timedatectl)
	@$(call install_alternative, systemd, 0, 0, 0644, \
		/etc/systemd/timesyncd.conf)
	@$(call install_copy, systemd, systemd-timesync, nogroup, 0755, \
		/var/lib/systemd/timesync)
	@$(call install_link, systemd, ../systemd-timesyncd.service,  \
		/usr/lib/systemd/system/sysinit.target.wants/systemd-timesyncd.service)
	@$(call install_alternative, systemd, 0, 0, 0664, \
		/usr/lib/systemd/ntp-units.d/80-systemd-timesync.list)
endif

ifdef PTXCONF_SYSTEMD_VCONSOLE
	@$(call install_link, systemd, ../getty@.service,  \
		/usr/lib/systemd/system/getty.target.wants/getty@tty1.service)
	@$(call install_alternative, systemd, 0, 0, 0644, /etc/vconsole.conf)
endif

#	# udev
	@$(call install_copy, systemd, 0, 0, 0755, -, /usr/bin/udevadm)
	@$(call install_link, systemd, ../../bin/udevadm, \
		/usr/lib/systemd/systemd-udevd)
	@$(call install_lib, systemd, 0, 0, 0644, libudev)

	@$(foreach helper, $(SYSTEMD_UDEV_HELPER-y), \
		$(call install_copy, systemd, 0, 0, 0755, -, \
			/usr/lib/udev/$(helper))$(ptx/nl))

	@$(foreach rule, $(SYSTEMD_UDEV_RULES-y), \
		$(call install_copy, systemd, 0, 0, 0644, -, \
			/usr/lib/udev/rules.d/$(rule))$(ptx/nl))

ifdef PTXCONF_SYSTEMD_UDEV_CUST_RULES
	@$(call install_alternative_tree, systemd, 0, 0, /usr/lib/udev/rules.d)
endif

	@$(call install_finish, systemd)

	@$(call touch)

# vim: syntax=make
