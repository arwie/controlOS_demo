# -*-makefile-*-
#
# Copyright (C) 2006 by Erwin Rol
#               2010 by Marc Kleine-Budde <mkl@pengutronix.de>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_LIBDRM) += libdrm

#
# Paths and names
#
LIBDRM_VERSION	:= 2.4.100
LIBDRM_MD5	:= f47bc87e28198ba527e6b44ffdd62f65
LIBDRM		:= libdrm-$(LIBDRM_VERSION)
LIBDRM_SUFFIX	:= tar.bz2
LIBDRM_URL	:= http://dri.freedesktop.org/libdrm/$(LIBDRM).$(LIBDRM_SUFFIX)
LIBDRM_SOURCE	:= $(SRCDIR)/$(LIBDRM).$(LIBDRM_SUFFIX)
LIBDRM_DIR	:= $(BUILDDIR)/$(LIBDRM)
LIBDRM_LICENSE	:= MIT
LIBDRM_LICENSE_FILES	:= \
	file://xf86drm.c;startline=10;endline=31;md5=30492a61897fb94bd0efd13b4f129d7a

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

ifdef PTXCONF_ARCH_X86
LIBDRM_BACKENDS-$(PTXCONF_LIBDRM_INTEL) += intel
else
LIBDRM_BACKENDS- += intel
endif
LIBDRM_BACKENDS-$(PTXCONF_LIBDRM_RADEON) += radeon
LIBDRM_BACKENDS-$(PTXCONF_LIBDRM_AMDGPU) += amdgpu
LIBDRM_BACKENDS-$(PTXCONF_LIBDRM_NOUVEAU) += nouveau
LIBDRM_BACKENDS-$(PTXCONF_LIBDRM_FREEDRENO) += freedreno
LIBDRM_BACKENDS- += freedreno-kgsl
LIBDRM_BACKENDSC-$(PTXCONF_LIBDRM_VMWGFX) += vmwgfx
LIBDRM_BACKENDS-$(PTXCONF_LIBDRM_OMAP) += omap
LIBDRM_BACKENDS-$(PTXCONF_LIBDRM_EXYNOS) += exynos
LIBDRM_BACKENDS-$(PTXCONF_LIBDRM_TEGRA) += tegra
LIBDRM_BACKENDSC-$(PTXCONF_LIBDRM_VC4) += vc4
# vc4 is a headers only backend
LIBDRM_BACKENDS-$(PTXCONF_LIBDRM_ETNAVIV) += etnaviv

LIBDRM_BACKENDSC-y += $(LIBDRM_BACKENDS-y)
LIBDRM_BACKENDSC- += $(LIBDRM_BACKENDS-)
LIBDRM_BACKENDSL-y += $(LIBDRM_BACKENDS-y)

#
# meson
#
LIBDRM_CONF_TOOL := meson
LIBDRM_CONF_OPT := \
	$(CROSS_MESON_USR) \
	-Dlibkms=$(call ptx/truefalse, PTXCONF_LIBDRM_LIBKMS) \
	$(patsubst %,-D%=true,$(LIBDRM_BACKENDSC-y)) \
	$(patsubst %,-D%=false,$(LIBDRM_BACKENDSC-)) \
	-Dcairo-tests=false \
	-Dman-pages=false \
	-Dvalgrind=false \
	-Dinstall-test-programs=$(call ptx/truefalse, PTXCONF_LIBDRM_TESTS) \
	-Dudev=true


# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/libdrm.targetinstall:
	@$(call targetinfo)

	@$(call install_init, libdrm)
	@$(call install_fixup, libdrm,PRIORITY,optional)
	@$(call install_fixup, libdrm,SECTION,base)
	@$(call install_fixup, libdrm,AUTHOR,"Robert Schwebel <r.schwebel@pengutronix.de>")
	@$(call install_fixup, libdrm,DESCRIPTION,missing)

	@$(call install_lib, libdrm, 0, 0, 0644, libdrm)

ifdef PTXCONF_LIBDRM_LIBKMS
	@$(call install_lib, libdrm, 0, 0, 0644, libkms)
endif
	@$(foreach backend,$(LIBDRM_BACKENDSL-y), \
		$(call install_lib, libdrm, 0, 0, 0644, libdrm_$(backend));)

ifdef PTXCONF_LIBDRM_TESTS
ifdef PTXCONF_LIBDRM_LIBKMS
	@$(call install_copy, libdrm, 0, 0, 0755, -, /usr/bin/kmstest)
	@$(call install_copy, libdrm, 0, 0, 0755, -, /usr/bin/modetest)
endif
	@$(call install_copy, libdrm, 0, 0, 0755, -, /usr/bin/modeprint)
	@$(call install_copy, libdrm, 0, 0, 0755, -, /usr/bin/vbltest)
ifdef PTXCONF_LIBDRM_ETNAVIV
	@$(call install_copy, libdrm, 0, 0, 0755, -, /usr/bin/etnaviv_2d_test)
	@$(call install_copy, libdrm, 0, 0, 0755, -, /usr/bin/etnaviv_cmd_stream_test)
	@$(call install_copy, libdrm, 0, 0, 0755, -, /usr/bin/etnaviv_bo_cache_test)
endif
endif
	@$(call install_finish, libdrm)

	@$(call touch)

# vim: syntax=make
