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
PACKAGES-$(PTXCONF_ICEORYX2) += iceoryx2

#
# Paths and names
#
ICEORYX2_VERSION	:= 0.9.3
ICEORYX2_SHA256		:= 2b4438364614b390938354ac766c198bb2ad63a2bde84a142c53f555fe8f4bc1
ICEORYX2		:= iceoryx2-$(ICEORYX2_VERSION)
ICEORYX2_SUFFIX		:= tar.gz
ICEORYX2_URL		:= https://github.com/eclipse-iceoryx/iceoryx2/archive/refs/tags/v$(ICEORYX2_VERSION).$(ICEORYX2_SUFFIX)
ICEORYX2_SOURCE		:= $(SRCDIR)/$(ICEORYX2).$(ICEORYX2_SUFFIX)
ICEORYX2_DIR		:= $(BUILDDIR)/$(ICEORYX2)
ICEORYX2_LICENSE	:= Apache-2.0 OR MIT
ICEORYX2_LICENSE_FILES	:= \
	file://LICENSE-APACHE;md5=22a53954e4e0ec258dfce4391e905dac \
	file://LICENSE-MIT;md5=b377b220f43d747efdec40d69fcaa69d

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

ICEORYX2_CONF_TOOL	:= cargo
ICEORYX2_CONF_OPT	:= \
	$(CROSS_CARGO_OPT) \
	$(call ptx/ifdef, PTXCONF_ICEORYX2_FFI_C, --package iceoryx2-ffi-c) \
	$(call ptx/ifdef, PTXCONF_ICEORYX2_CLI, --package iceoryx2-cli) \
	$(call ptx/ifdef, PTXCONF_ICEORYX2_PYTHON, --package iceoryx2-ffi-python)

ICEORYX2_MAKE_ENV	:= \
	$(CROSS_CARGO_ENV) \
	PYO3_CROSS_LIB_DIR="$(PTXDIST_SYSROOT_TARGET)/usr/lib" \
	PYO3_PYTHON="python$(PYTHON3_MAJORMINOR)"

ICEORYX2_ARTIFACTS	:= $(ICEORYX2_DIR)/target/$(PTXCONF_RUST_TARGET)/release

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

$(STATEDIR)/iceoryx2.install:
	@$(call targetinfo)
ifdef PTXCONF_ICEORYX2_FFI_C
	@install -v -D -m644 $(ICEORYX2_ARTIFACTS)/libiceoryx2_ffi_c.so \
		$(ICEORYX2_PKGDIR)/usr/lib/libiceoryx2_ffi_c.so
	@install -v -D -m644 \
		$(ICEORYX2_ARTIFACTS)/iceoryx2-ffi-c-cbindgen/include/iox2/iceoryx2.h \
		$(ICEORYX2_PKGDIR)/usr/include/iox2/iceoryx2.h
endif
ifdef PTXCONF_ICEORYX2_CLI
	@install -v -d $(ICEORYX2_PKGDIR)/usr/bin
	@install -v -m755 -t $(ICEORYX2_PKGDIR)/usr/bin \
		$(ICEORYX2_ARTIFACTS)/iox2 \
		$(ICEORYX2_ARTIFACTS)/iox2-node \
		$(ICEORYX2_ARTIFACTS)/iox2-service \
		$(ICEORYX2_ARTIFACTS)/iox2-config \
		$(ICEORYX2_ARTIFACTS)/iox2-tunnel
endif
ifdef PTXCONF_ICEORYX2_PYTHON
	@mkdir -p $(ICEORYX2_PKGDIR)$(PYTHON3_SITEPACKAGES)
	@cp -rv $(ICEORYX2_DIR)/iceoryx2-ffi/python/python-src/iceoryx2 \
		$(ICEORYX2_PKGDIR)$(PYTHON3_SITEPACKAGES)/
	@install -v -D -m644 $(ICEORYX2_ARTIFACTS)/lib_iceoryx2.so \
		$(ICEORYX2_PKGDIR)$(PYTHON3_SITEPACKAGES)/iceoryx2/_iceoryx2.so
endif
	@$(call touch)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/iceoryx2.targetinstall:
	@$(call targetinfo)

	@$(call install_init, iceoryx2)
	@$(call install_fixup, iceoryx2,PRIORITY,optional)
	@$(call install_fixup, iceoryx2,SECTION,base)
	@$(call install_fixup, iceoryx2,AUTHOR,"Artur Wiebe <artur@4wiebe.de>")
	@$(call install_fixup, iceoryx2,DESCRIPTION,missing)

ifdef PTXCONF_ICEORYX2_FFI_C
	@$(call install_lib, iceoryx2, 0, 0, 0644, libiceoryx2_ffi_c)
endif

ifdef PTXCONF_ICEORYX2_CLI
	@$(call install_copy, iceoryx2, 0, 0, 0755, -, /usr/bin/iox2)
	@$(call install_copy, iceoryx2, 0, 0, 0755, -, /usr/bin/iox2-node)
	@$(call install_copy, iceoryx2, 0, 0, 0755, -, /usr/bin/iox2-service)
	@$(call install_copy, iceoryx2, 0, 0, 0755, -, /usr/bin/iox2-config)
	@$(call install_copy, iceoryx2, 0, 0, 0755, -, /usr/bin/iox2-tunnel)
endif

ifdef PTXCONF_ICEORYX2_PYTHON
	@$(call install_glob, iceoryx2, 0, 0, -, \
		$(PYTHON3_SITEPACKAGES)/iceoryx2,,)
endif

	@$(call install_finish, iceoryx2)

	@$(call touch)

# vim: syntax=make
