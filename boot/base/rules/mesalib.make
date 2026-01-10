# -*-makefile-*-
#
# Copyright (C) 2006 by Erwin Rol
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_MESALIB) += mesalib

#
# Paths and names
#
MESALIB_VERSION	:= 25.3.3
MESALIB_MD5	:= 79092bdfc67b9037ce3694b3bfa722d2
MESALIB		:= mesa-$(MESALIB_VERSION)
MESALIB_SUFFIX	:= tar.xz
MESALIB_URL	:= \
	https://mesa.freedesktop.org/archive/$(MESALIB).$(MESALIB_SUFFIX)
MESALIB_SOURCE	:= $(SRCDIR)/$(MESALIB).$(MESALIB_SUFFIX)
MESALIB_DIR	:= $(BUILDDIR)/$(MESALIB)
MESALIB_LICENSE	:= MIT AND BSL-1.0
ifdef PTXCONF_MESALIB_GLX
MESALIB_LICENSE += AND SGI-B-2.0
endif
ifdef PTXCONF_MESALIB_VULKAN_SCREENSHOT
MESALIB_LICENSE += AND Apache-2.0
endif
MESALIB_LICENSE_FILES := \
	file://docs/license.rst;md5=ffe678546d4337b732cfd12262e6af11 \
	file://licenses/Apache-2.0;md5=db66a99884d6d2bdbd5f9e71e1bffec6 \
	file://licenses/BSL-1.0;md5=4610c5f00caa47872489c3943d1bacc8 \
	file://licenses/MIT;md5=e8f57dd048e186199433be2c41bd3d6d \
	file://licenses/SGI-B-2.0;md5=efe792cf56e83c7aa8470e553faf333f
MESALIB_CVE_PRODUCT := mesa

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

MESALIB_GALLIUM_DRIVERS-$(PTXCONF_MESALIB_DRI_VIRGL)	+= virgl
ifndef PTXCONF_ARCH_ARM # broken: https://gitlab.freedesktop.org/mesa/mesa/-/issues/473
ifndef PTXCONF_ARCH_X86 # needs llvm
MESALIB_GALLIUM_DRIVERS-$(PTXCONF_MESALIB_DRI_R300)	+= r300
endif
MESALIB_GALLIUM_DRIVERS-$(PTXCONF_MESALIB_DRI_R600)	+= r600
MESALIB_GALLIUM_DRIVERS-$(PTXCONF_MESALIB_DRI_RADEONSI)	+= radeonsi
endif
MESALIB_GALLIUM_DRIVERS-$(PTXCONF_MESALIB_DRI_NOUVEAU)	+= nouveau
MESALIB_GALLIUM_DRIVERS-$(PTXCONF_MESALIB_DRI_FREEDRENO)+= freedreno
ifdef PTXCONF_ARCH_ARM64
MESALIB_GALLIUM_DRIVERS-$(PTXCONF_MESALIB_DRI_ETHOSU)	+= ethosu
endif
MESALIB_GALLIUM_DRIVERS-$(PTXCONF_MESALIB_DRI_ETNAVIV)	+= etnaviv
ifdef PTXCONF_ARCH_ARM_NEON
MESALIB_GALLIUM_DRIVERS-$(PTXCONF_MESALIB_DRI_V3D)	+= v3d
MESALIB_GALLIUM_DRIVERS-$(PTXCONF_MESALIB_DRI_VC4)	+= vc4
endif
MESALIB_GALLIUM_DRIVERS-$(PTXCONF_MESALIB_DRI_SOFTPIPE)	+= softpipe
MESALIB_GALLIUM_DRIVERS-$(PTXCONF_MESALIB_DRI_LLVMPIPE)	+= llvmpipe
MESALIB_GALLIUM_DRIVERS-$(PTXCONF_MESALIB_DRI_PANFROST)	+= panfrost
MESALIB_GALLIUM_DRIVERS-$(PTXCONF_MESALIB_DRI_LIMA)	+= lima
ifdef PTXCONF_ARCH_X86
MESALIB_GALLIUM_DRIVERS-$(PTXCONF_MESALIB_DRI_IRIS)	+= iris
endif
ifdef PTXCONF_ARCH_ARM64
MESALIB_GALLIUM_DRIVERS-$(PTXCONF_MESALIB_DRI_ROCKET)	+= rocket
endif
MESALIB_GALLIUM_DRIVERS-$(PTXCONF_MESALIB_DRI_ZINK)	+= zink
ifdef PTXCONF_ARCH_ARM64
MESALIB_GALLIUM_DRIVERS-$(PTXCONF_MESALIB_DRI_ASAHI)	+= asahi
endif
ifdef PTXCONF_ARCH_X86
MESALIB_GALLIUM_DRIVERS-$(PTXCONF_MESALIB_DRI_CROCUS)	+= crocus
MESALIB_GALLIUM_DRIVERS-$(PTXCONF_MESALIB_DRI_SVGA)	+= svga
endif

MESALIB_DRI_GALLIUM_LIBS-y = \
	$(call ptx/ifdef, PTXCONF_MESALIB_DRI_KMSRO, \
		apple \
		armada-drm \
		exynos \
		gm12u320 \
		hdlcd \
		hx8357d \
		ili9163 \
		ili9225 \
		ili9341 \
		ili9486 \
		imx-dcss \
		imx-drm \
		imx-lcdif \
		ingenic-drm \
		kirin \
		komeda \
		mali-dp \
		mcde \
		mediatek \
		meson \
		mi0283qt \
		mxsfb-drm \
		panel-mipi-dbi \
		pl111 \
		rcar-du \
		repaper \
		rockchip \
		rzg2l-du \
		ssd130x \
		st7586 \
		st7735r \
		sti \
		stm \
		sun4i-drm \
		udl \
		vkms \
		zynqmp-dpsub) \
	$(patsubst %pipe,swrast kms_swrast \
	,$(subst softpipe llvmpipe,softpipe \
	,$(subst freedreno,kgsl msm \
	,$(subst panfrost,panfrost panthor \
	,$(subst svga,vmwgfx \
	,$(subst virgl,virtio_gpu \
	,$(subst ethosu, \
	,$(subst rocket, \
	,$(MESALIB_GALLIUM_DRIVERS-y) \
	))))))))

MESALIB_VIDEO_CODECS-$(PTXCONF_MESALIB_VIDEO_VC1DEC)	+= vc1dec
MESALIB_VIDEO_CODECS-$(PTXCONF_MESALIB_VIDEO_H264DEC)	+= h264dec
MESALIB_VIDEO_CODECS-$(PTXCONF_MESALIB_VIDEO_H264ENC)	+= h264enc
MESALIB_VIDEO_CODECS-$(PTXCONF_MESALIB_VIDEO_H265DEC)	+= h265dec
MESALIB_VIDEO_CODECS-$(PTXCONF_MESALIB_VIDEO_H265ENC)	+= h265enc
MESALIB_VIDEO_CODECS-$(PTXCONF_MESALIB_VIDEO_AV1DEC)	+= av1dec
MESALIB_VIDEO_CODECS-$(PTXCONF_MESALIB_VIDEO_AV1ENC)	+= av1enc
MESALIB_VIDEO_CODECS-$(PTXCONF_MESALIB_VIDEO_VP9DEC)	+= vp9dec

ifdef PTXCONF_ARCH_X86
MESALIB_VULKAN_DRIVERS-$(PTXCONF_MESALIB_VULKAN_AMD)		+= amd
MESALIB_VULKAN_DRIVERS-$(PTXCONF_MESALIB_VULKAN_INTEL)		+= intel
MESALIB_VULKAN_DRIVERS-$(PTXCONF_MESALIB_VULKAN_INTEL_HASVK)	+= intel_hasvk
MESALIB_VULKAN_DRIVERS-$(PTXCONF_MESALIB_VULKAN_IMAGINATION)	+= imagination
endif
ifdef PTXCONF_ARCH_ARM_NEON
MESALIB_VULKAN_DRIVERS-$(PTXCONF_MESALIB_VULKAN_BROADCOM)	+= broadcom
endif
ifdef PTXCONF_ARCH_ARM
MESALIB_VULKAN_DRIVERS-$(PTXCONF_MESALIB_VULKAN_FREEDRENO)	+= freedreno
MESALIB_VULKAN_DRIVERS-$(PTXCONF_MESALIB_VULKAN_PANFROST)	+= panfrost
endif
MESALIB_VULKAN_DRIVERS-$(PTXCONF_MESALIB_VULKAN_SWRAST)		+= swrast
MESALIB_VULKAN_DRIVERS-$(PTXCONF_MESALIB_VULKAN_VIRTIO)		+= virtio
MESALIB_VULKAN_DRIVERS-$(PTXCONF_MESALIB_VULKAN_NOUVEAU)	+= nouveau
ifdef PTXCONF_ARCH_ARM64
MESALIB_VULKAN_DRIVERS-$(PTXCONF_MESALIB_VULKAN_ASAHI)		+= asahi
endif
ifdef PTXCONF_ARCH_LP64
MESALIB_VULKAN_DRIVERS-$(PTXCONF_MESALIB_VULKAN_GFXSTREAM)	+= gfxstream
endif

MESALIB_VULKAN_LIBS-y = $(subst amd,radeon \
	,$(subst swrast,lvp \
	,$(subst imagination,powervr_mesa \
	,$(MESALIB_VULKAN_DRIVERS-y) \
	)))

MESALIB_VULKAN_LAYERS-$(PTXCONF_MESALIB_VULKAN_ANTI_LAG)	+= anti-lag
MESALIB_VULKAN_LAYERS-$(PTXCONF_MESALIB_VULKAN_DEVICE_SELECT)	+= device-select
ifdef PTXCONF_ARCH_X86
MESALIB_VULKAN_LAYERS-$(PTXCONF_MESALIB_VULKAN_INTEL_NULLHW)	+= intel-nullhw
endif
MESALIB_VULKAN_LAYERS-$(PTXCONF_MESALIB_VULKAN_OVERLAY)		+= overlay
MESALIB_VULKAN_LAYERS-$(PTXCONF_MESALIB_VULKAN_SCREENSHOT)	+= screenshot
MESALIB_VULKAN_LAYERS-$(PTXCONF_MESALIB_VULKAN_VRAM_REPORT_LIMIT) += \
	vram-report-limit

MESALIB_LIBS-$(PTXCONF_MESALIB_GLX)	+= libGL
MESALIB_LIBS-$(PTXCONF_MESALIB_GLES1)	+= libGLESv1_CM
MESALIB_LIBS-$(PTXCONF_MESALIB_GLES2)	+= libGLESv2
MESALIB_LIBS-$(PTXCONF_MESALIB_EGL)	+= libEGL
MESALIB_LIBS-$(PTXCONF_MESALIB_GBM)	+= libgbm
MESALIB_LIBS-$(PTXCONF_MESALIB_TEFLON)	+= libteflon

MESALIBS_EGL_PLATFORMS-$(PTXCONF_MESALIB_EGL_WAYLAND)	+= wayland
MESALIBS_EGL_PLATFORMS-$(PTXCONF_MESALIB_EGL_X11)	+= x11

ifdef PTXCONF_MESALIB_VA
ifndef PTXCONF_ARCH_ARM # broken: https://gitlab.freedesktop.org/mesa/mesa/-/issues/473
MESALIB_DRI_VA_LIBS-$(PTXCONF_MESALIB_DRI_R600)		+= r600
MESALIB_DRI_VA_LIBS-$(PTXCONF_MESALIB_DRI_RADEONSI)	+= radeonsi
endif
MESALIB_DRI_VA_LIBS-$(PTXCONF_MESALIB_DRI_NOUVEAU)	+= nouveau
MESALIB_DRI_VA_LIBS-$(PTXCONF_MESALIB_DRI_VIRGL)	+= virtio_gpu
endif

MESALIB_MESON_CROSS_FILE := $(call ptx/get-alternative, config/meson, mesalib-cross-file.meson)

MESALIB_CONF_TOOL	:= meson
MESALIB_CONF_OPT	:= \
	$(CROSS_MESON_USR) \
	-Dallow-fallback-for=[] \
	-Dallow-kcmp=enabled \
	-Damd-use-llvm=true \
	-Damdgpu-virtio=false \
	-Dandroid-libbacktrace=disabled \
	-Dandroid-libperfetto=disabled \
	-Dandroid-strict=true \
	-Dandroid-stub=false \
	-Dbuild-aco-tests=false \
	-Dbuild-radv-tests=false \
	-Dbuild-tests=false \
	-Dcustom-shader-replacement= \
	-Dd3d-drivers-path=/usr/lib/d3d \
	-Ddatasources=auto \
	-Ddisplay-info=enabled \
	-Ddraw-use-llvm=true \
	-Ddri-drivers-path=/usr/lib/dri \
	-Degl=$(call ptx/endis, PTXCONF_MESALIB_EGL)d \
	-Degl-lib-suffix= \
	-Degl-native-platform=auto \
	-Denable-glcpp-tests=false \
	-Dexpat=enabled \
	-Dfreedreno-kmds=msm \
	-Dgallium-d3d10-dll-name=libgallium_d3d10 \
	-Dgallium-d3d10umd=false \
	-Dgallium-d3d12-graphics=disabled \
	-Dgallium-d3d12-video=disabled \
	-Dgallium-drivers=$(subst $(space),$(comma),$(MESALIB_GALLIUM_DRIVERS-y)) \
	-Dgallium-extra-hud=$(call ptx/truefalse, PTXCONF_MESALIB_EXTENDED_HUD) \
	-Dgallium-mediafoundation=disabled \
	-Dgallium-mediafoundation-test=false \
	-Dgallium-rusticl=false \
	-Dgallium-rusticl-enable-drivers= \
	-Dgallium-va=$(call ptx/endis, PTXCONF_MESALIB_VA)d \
	-Dgallium-wgl-dll-name=libgallium_wgl \
	-Dgbm=$(call ptx/endis, PTXCONF_MESALIB_GBM)d \
	-Dgbm-backends-path= \
	-Dgles-lib-suffix= \
	-Dgles1=$(call ptx/endis, PTXCONF_MESALIB_GLES1)d \
	-Dgles2=$(call ptx/endis, PTXCONF_MESALIB_GLES2)d \
	-Dglvnd=disabled \
	-Dglvnd-vendor-name= \
	-Dglx=$(call ptx/ifdef, PTXCONF_MESALIB_GLX, dri, disabled) \
	-Dglx-direct=true \
	-Dglx-read-only-text=false \
	-Dgpuvis=false \
	-Dhtml-docs=disabled \
	-Dhtml-docs-path= \
	-Dimagination-srv=false \
	-Dimagination-uscgen-devices=axe-1-16m \
	-Dinstall-intel-gpu-tests=false \
	-Dinstall-mesa-clc=false \
	-Dinstall-precomp-compiler=false \
	-Dintel-elk=true \
	-Dintel-rt=disabled \
	-Dlegacy-wayland=bind-wayland-display \
	-Dlibgbm-external=false \
	-Dlibunwind=disabled \
	-Dllvm=$(call ptx/endis, PTXCONF_MESALIB_LLVM)d \
	-Dllvm-orcjit=false \
	-Dlmsensors=$(call ptx/endis, PTXCONF_MESALIB_LMSENSORS)d \
	-Dmediafoundation-codecs=[] \
	-Dmediafoundation-store-dll=false \
	-Dmesa-clc=$(call ptx/ifdef, PTXCONF_MESALIB_CLC,system,auto) \
	-Dmesa-clc-bundle-headers=enabled \
	-Dmicrosoft-clc=disabled \
	-Dmin-windows-version=8 \
	-Dmoltenvk-dir= \
	-Dopengl=$(call ptx/truefalse, PTXCONF_MESALIB_OPENGL) \
	-Dperfetto=false \
	-Dplatform-sdk-version=25 \
	-Dplatforms=$(subst $(space),$(comma),$(MESALIBS_EGL_PLATFORMS-y)) \
	-Dprecomp-compiler=$(call ptx/ifdef, PTXCONF_MESALIB_CLC,system,auto) \
	-Dradeonsi-build-id='' \
	-Dradv-build-id='' \
	-Dshader-cache=$(call ptx/endis, PTXCONF_MESALIB_SHADER_CACHE)d \
	-Dshader-cache-default=true \
	-Dshader-cache-max-size=1G \
	-Dshared-llvm=enabled \
	-Dspirv-to-dxil=false \
	-Dspirv-tools=$(call ptx/endis, PTXCONF_MESALIB_CLC)d \
	-Dsplit-debug=disabled \
	-Dsse2=true \
	-Dstatic-libclc=[] \
	-Dsysprof=false \
	-Dteflon=$(call ptx/truefalse, PTXCONF_MESALIB_TEFLON) \
	-Dtools=[] \
	-Dunversion-libgallium=false \
	-Dva-libs-path=/usr/lib/dri \
	-Dvalgrind=disabled \
	-Dvideo-codecs=$(subst $(space),$(comma),$(MESALIB_VIDEO_CODECS-y)) \
	-Dvirtgpu_kumquat=false \
	-Dvmware-mks-stats=false \
	-Dvulkan-beta=false \
	-Dvulkan-drivers=$(subst $(space),$(comma),$(MESALIB_VULKAN_DRIVERS-y)) \
	-Dvulkan-icd-dir=/etc/vulkan/icd.d \
	-Dvulkan-layers=$(subst $(space),$(comma),$(MESALIB_VULKAN_LAYERS-y)) \
	-Dxlib-lease=$(call ptx/endis, PTXCONF_MESALIB_EGL_X11)d \
	-Dxmlconfig=$(call ptx/endis, PTXCONF_MESALIB_XMLCONFIG)d \
	-Dzlib=enabled \
	-Dzstd=$(call ptx/endis, PTXCONF_MESALIB_SHADER_CACHE)d \
	\
	--cross-file $(MESALIB_MESON_CROSS_FILE)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

ifdef PTXCONF_ARCH_ARM
ifndef PTXCONF_ARCH_ARM_NEON
# don't try to build NEON code on platforms that don't have NEON
MESALIB_CFLAGS := -DNO_FORMAT_ASM
endif
endif

$(STATEDIR)/mesalib.compile:
	@$(call targetinfo)
	cp $(PTXDIST_SYSROOT_HOST)/usr/bin/mesa/glsl_compiler $(MESALIB_DIR)/src/compiler/
	@$(call world/compile, MESALIB)
	@$(call touch)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

# read libgallium version from file, fall back to package version
MESALIB_LIBGALLIUM_VERSION = \
	$(if $(wildcard $(MESALIB_DIR)/VERSION),$(file <$(MESALIB_DIR)/VERSION),$(MESALIB_VERSION))

$(STATEDIR)/mesalib.targetinstall:
	@$(call targetinfo)

	@$(call install_init, mesalib)
	@$(call install_fixup, mesalib,PRIORITY,optional)
	@$(call install_fixup, mesalib,SECTION,base)
	@$(call install_fixup, mesalib,AUTHOR,"Robert Schwebel <r.schwebel@pengutronix.de>")
	@$(call install_fixup, mesalib,DESCRIPTION,missing)

ifneq ($(strip $(MESALIB_DRI_GALLIUM_LIBS-y)),)
	@$(call install_copy, mesalib, 0, 0, 0644, -, \
		/usr/lib/libgallium-$(MESALIB_LIBGALLIUM_VERSION).so)
ifdef PTXCONF_MESALIB_EGL_X11
	@$(call install_copy, mesalib, 0, 0, 0644, -, /usr/lib/dri/libdril_dri.so)

	@$(foreach lib, $(MESALIB_DRI_GALLIUM_LIBS-y), \
		test -f $(MESALIB_PKGDIR)/usr/lib/dri/$(lib)_dri.so || \
			ptxd_bailout "missing gallium driver $(lib)_dri.so"$(ptx/nl) \
		$(call install_link, mesalib, libdril_dri.so, \
		/usr/lib/dri/$(lib)_dri.so)$(ptx/nl))
endif
endif
ifneq ($(strip $(MESALIB_DRI_VA_LIBS-y)),)
	@$(foreach lib, $(MESALIB_DRI_VA_LIBS-y), \
		test -f $(MESALIB_PKGDIR)/usr/lib/dri/$(lib)_drv_video.so || \
			ptxd_bailout "missing va driver $(lib)_drv_video.so"$(ptx/nl) \
		$(call install_link, mesalib, ../libgallium-$(MESALIB_LIBGALLIUM_VERSION).so, \
		/usr/lib/dri/$(lib)_drv_video.so)$(ptx/nl))
endif

ifneq ($(strip $(MESALIB_VULKAN_LIBS-y)),)
	@$(foreach lib, $(MESALIB_VULKAN_LIBS-y), \
		$(call install_copy, mesalib, 0, 0, 0644, -, \
		/usr/lib/libvulkan_$(lib).so)$(ptx/nl) \
		$(call install_glob, mesalib, 0, 0, -, \
		/etc/vulkan/icd.d, */$(lib)_icd.*.json)$(ptx/nl))
endif
ifneq ($(strip $(MESALIB_VULKAN_LAYERS-y)),)
	@$(foreach lib, $(filter-out intel-nullhw,$(MESALIB_VULKAN_LAYERS-y)), \
		$(call install_copy, mesalib, 0, 0, 0644, -, \
		/usr/lib/libVkLayer_MESA_$(subst -,_,$(lib)).so)$(ptx/nl))
endif
ifdef PTXCONF_ARCH_X86
ifdef PTXCONF_MESALIB_VULKAN_INTEL_NULLHW
	@$(call install_lib, mesalib, 0, 0, 0644, libVkLayer_INTEL_nullhw)
endif
endif

	@$(foreach lib, $(MESALIB_LIBS-y), \
		$(call install_lib, mesalib, 0, 0, 0644, $(lib))$(ptx/nl))
ifdef PTXCONF_MESALIB_GBM
	@$(call install_copy, mesalib, 0, 0, 0644, -, /usr/lib/gbm/dri_gbm.so)
endif

	@$(call install_finish, mesalib)

	@$(call touch)


# vim: syntax=make
