# -*-makefile-*-
#
# Copyright (C) 2010 by Michael Olbrich <m.olbrich@pengutronix.de>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
HOST_PACKAGES-$(PTXCONF_HOST_MESALIB) += host-mesalib

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

HOST_MESALIB_TOOLS-y := glsl
HOST_MESALIB_TOOLS-$(PTXCONF_HOST_MESALIB_PANFROST) += panfrost
HOST_MESALIB_TOOLS-$(PTXCONF_HOST_MESALIB_ASAHI) += asahi

HOST_MESALIB_MESON_CROSS_FILE := $(call ptx/get-alternative, config/meson, mesalib-native-file.meson)

HOST_MESALIB_CONF_TOOL	:= meson
HOST_MESALIB_CONF_OPT	:= \
	$(HOST_MESON_OPT) \
	-Dallow-kcmp=enabled \
	-Damd-use-llvm=false \
	-Damdgpu-virtio=false \
	-Dandroid-libbacktrace=disabled \
	-Dandroid-strict=true \
	-Dandroid-stub=false \
	-Dbuild-aco-tests=false \
	-Dbuild-radv-tests=false \
	-Dbuild-tests=false \
	-Dcustom-shader-replacement= \
	-Dd3d-drivers-path=/usr/lib/d3d \
	-Ddatasources=auto \
	-Ddraw-use-llvm=false \
	-Ddri-drivers-path=/usr/lib/dri \
	-Degl=disabled \
	-Degl-lib-suffix= \
	-Degl-native-platform=auto \
	-Denable-glcpp-tests=false \
	-Dexpat=disabled \
	-Dfreedreno-kmds= \
	-Dgallium-d3d10-dll-name=libgallium_d3d10 \
	-Dgallium-d3d10umd=false \
	-Dgallium-d3d12-graphics=disabled \
	-Dgallium-d3d12-video=disabled \
	-Dgallium-drivers=softpipe \
	-Dgallium-extra-hud=false \
	-Dgallium-rusticl=false \
	-Dgallium-rusticl-enable-drivers= \
	-Dgallium-va=disabled \
	-Dgallium-vdpau=disabled \
	-Dgallium-wgl-dll-name=libgallium_wgl \
	-Dgbm=disabled \
	-Dgbm-backends-path= \
	-Dgles-lib-suffix= \
	-Dgles1=disabled \
	-Dgles2=disabled \
	-Dglvnd=disabled \
	-Dglvnd-vendor-name= \
	-Dglx=disabled \
	-Dglx-direct=false \
	-Dglx-read-only-text=false \
	-Dgpuvis=false \
	-Dhtml-docs=disabled \
	-Dhtml-docs-path= \
	-Dimagination-srv=false \
	-Dinstall-intel-clc=false \
	-Dinstall-intel-gpu-tests=false \
	-Dinstall-mesa-clc=$(call ptx/truefalse, PTXCONF_HOST_MESALIB_CLC) \
	-Dinstall-precomp-compiler=true \
	-Dintel-bvh-grl=false \
	-Dintel-clc=system \
	-Dintel-elk=true \
	-Dintel-rt=disabled \
	-Dlegacy-x11=none \
	-Dlibgbm-external=false \
	-Dlibunwind=disabled \
	-Dllvm=$(call ptx/endis, PTXCONF_HOST_MESALIB_CLC)d \
	-Dllvm-orcjit=false \
	-Dlmsensors=disabled \
	-Dmesa-clc=$(call ptx/ifdef, PTXCONF_HOST_MESALIB_CLC,enabled,auto) \
	-Dmesa-clc-bundle-headers=enabled \
	-Dmicrosoft-clc=disabled \
	-Dmin-windows-version=8 \
	-Dmoltenvk-dir= \
	-Dopengl=true \
	-Dperfetto=false \
	-Dplatform-sdk-version=25 \
	-Dplatforms= \
	-Dpower8=disabled \
	-Dprecomp-compiler=$(call ptx/ifdef, PTXCONF_HOST_MESALIB_CLC,enabled,auto) \
	-Dradv-build-id='' \
	-Dshader-cache=disabled \
	-Dshader-cache-default=true \
	-Dshader-cache-max-size=1G \
	-Dshared-llvm=disabled \
	-Dspirv-to-dxil=false \
	-Dsplit-debug=disabled \
	-Dsse2=true \
	-Dstatic-libclc=[] \
	-Dteflon=false \
	-Dtools=$(subst $(space),$(comma),$(HOST_MESALIB_TOOLS-y)) \
	-Dunversion-libgallium=false \
	-Dva-libs-path=/usr/lib/dri \
	-Dvalgrind=disabled \
	-Dvdpau-libs-path=/usr/lib/vdpau \
	-Dvideo-codecs=[] \
	-Dvmware-mks-stats=false \
	-Dvulkan-beta=false \
	-Dvulkan-drivers=[] \
	-Dvulkan-icd-dir=/etc/vulkan/icd.d \
	-Dvulkan-layers=[] \
	-Dxlib-lease=disabled \
	-Dxmlconfig=disabled \
	-Dzlib=enabled \
	-Dzstd=disabled \
	\
	--native-file $(HOST_MESALIB_MESON_CROSS_FILE)

HOST_MESALIB_MAKE_OPT	:= \
	src/compiler/glsl/glsl_compiler
ifdef PTXCONF_HOST_MESALIB_CLC
HOST_MESALIB_MAKE_OPT	+= \
	src/compiler/clc/mesa_clc \
	src/compiler/spirv/vtn_bindgen2
endif
ifdef PTXCONF_HOST_MESALIB_PANFROST
HOST_MESALIB_MAKE_OPT	+= \
	src/panfrost/clc/panfrost_compile
endif
ifdef PTXCONF_HOST_MESALIB_ASAHI
HOST_MESALIB_MAKE_OPT	+= \
	src/asahi/clc/asahi_clc
endif

$(STATEDIR)/host-mesalib.install:
	@$(call targetinfo)
	install -D -m755 $(HOST_MESALIB_DIR)-build/src/compiler/glsl/glsl_compiler $(HOST_MESALIB_PKGDIR)/usr/bin/mesa/glsl_compiler
ifdef PTXCONF_HOST_MESALIB_CLC
	install -D -m755 $(HOST_MESALIB_DIR)-build/src/compiler/clc/mesa_clc $(HOST_MESALIB_PKGDIR)/usr/bin/mesa_clc
	install -D -m755 $(HOST_MESALIB_DIR)-build/src/compiler/spirv/vtn_bindgen2 $(HOST_MESALIB_PKGDIR)/usr/bin/vtn_bindgen2
endif
ifdef PTXCONF_HOST_MESALIB_PANFROST
	install -D -m755 $(HOST_MESALIB_DIR)-build/src/panfrost/clc/panfrost_compile $(HOST_MESALIB_PKGDIR)/usr/bin/panfrost_compile
endif
ifdef PTXCONF_HOST_MESALIB_ASAHI
	install -D -m755 $(HOST_MESALIB_DIR)-build/src/asahi/clc/asahi_clc $(HOST_MESALIB_PKGDIR)/usr/bin/asahi_clc
endif
	@$(call touch)

# vim: syntax=make
