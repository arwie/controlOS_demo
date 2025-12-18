# -*-makefile-*-
#
# Copyright (C) 2018 by Steffen Trumtrar <s.trumtrar@pengutronix.de>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_WPEWEBKIT) += wpewebkit

#
# Paths and names
#
WPEWEBKIT_VERSION	:= 2.50.1
WPEWEBKIT_MD5		:= 574a56386680d9732b40a05b1f4adef1
WPEWEBKIT		:= wpewebkit-$(WPEWEBKIT_VERSION)
WPEWEBKIT_SUFFIX	:= tar.xz
WPEWEBKIT_URL		:= https://wpewebkit.org/releases/$(WPEWEBKIT).$(WPEWEBKIT_SUFFIX)
WPEWEBKIT_SOURCE	:= $(SRCDIR)/$(WPEWEBKIT).$(WPEWEBKIT_SUFFIX)
WPEWEBKIT_DIR		:= $(BUILDDIR)/$(WPEWEBKIT)
WPEWEBKIT_LICENSE	:= BSD-2-Clause

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

#
# cmake
#
WPEWEBKIT_CONF_TOOL	:= cmake
WPEWEBKIT_CONF_OPT	:= \
	$(CROSS_CMAKE_USR) \
	-G Ninja \
	-DCMAKE_BUILD_TYPE=Release \
	-DANALYZERS=OFF \
	-DDEBUG_FISSION=OFF \
	-DDEVELOPER_MODE_FATAL_WARNINGS=OFF \
	-DENABLE_ASSERTS=OFF \
	-DENABLE_BUBBLEWRAP_SANDBOX=OFF \
	-DENABLE_DOCUMENTATION=OFF \
	-DENABLE_ENCRYPTED_MEDIA=OFF \
	-DENABLE_INTROSPECTION=OFF \
	-DENABLE_JAVASCRIPTCORE=ON \
	-DENABLE_JOURNALD_LOG=$(call ptx/onoff,PTXCONF_WPEWEBKIT_JOURNALD) \
	-DENABLE_PDFJS=ON \
	-DENABLE_SPEECH_SYNTHESIS=OFF \
	-DENABLE_VIDEO=$(call ptx/onoff,PTXCONF_WPEWEBKIT_VIDEO) \
	-DENABLE_WEBCORE=ON \
	-DENABLE_WEBDRIVER=$(call ptx/onoff,PTXCONF_WPEWEBKIT_WEBDRIVER) \
	-DENABLE_WEBKIT=ON \
	-DENABLE_WEB_AUDIO=$(call ptx/onoff,PTXCONF_WPEWEBKIT_AUDIO) \
	-DENABLE_WPE_1_1_API=OFF \
	-DENABLE_WPE_PLATFORM=OFF \
	-DENABLE_WPE_PLATFORM_DRM=OFF \
	-DENABLE_WPE_PLATFORM_HEADLESS=OFF \
	-DENABLE_WPE_PLATFORM_WAYLAND=OFF \
	-DENABLE_WPE_QT_API=$(call ptx/onoff,PTXCONF_WPEWEBKIT_QT) \
	-DENABLE_XSLT=ON \
	-DGCC_OFFLINEASM_SOURCE_MAP=OFF \
	-DPORT=WPE \
	-DPYTHON_EXECUTABLE=$(PTXDIST_SYSROOT_HOST)/usr/lib/wrapper/$(SYSTEMPYTHON3) \
	-DSHOULD_INSTALL_JS_SHELL=OFF \
	-DSHOW_BINDINGS_GENERATION_PROGRESS=OFF \
	-DUSER_AGENT_BRANDING= \
	-DUSE_64KB_PAGE_BLOCK=OFF \
	-DUSE_APPLE_ICU=OFF \
	-DUSE_ATK=OFF \
	-DUSE_AVIF=OFF \
	-DUSE_CXX_STDLIB_ASSERTIONS=OFF \
	-DUSE_FLITE=OFF \
	-DUSE_GBM=ON \
	-DUSE_GSTREAMER_TRANSCODER=OFF \
	-DUSE_GSTREAMER_WEBRTC=$(call ptx/onoff,PTXCONF_WPEWEBKIT_WEBRTC) \
	-DUSE_JPEGXL=OFF \
	-DUSE_LCMS=OFF \
	-DUSE_LIBBACKTRACE=OFF \
	-DUSE_LIBDRM=ON \
	-DUSE_QT6=OFF \
	-DUSE_SKIA_OPENTYPE_SVG=OFF \
	-DUSE_THIN_ARCHIVES=ON \
	-DUSE_WOFF2=OFF

WPEWEBKIT_SYSTEM_MALLOC := OFF
ifdef PTXCONF_WPEWEBKIT_QT
ifdef PTXCONF_ARCH_ARM64
WPEWEBKIT_SYSTEM_MALLOC := ON
endif
ifdef PTXCONF_ARCH_X86_64
WPEWEBKIT_SYSTEM_MALLOC := ON
endif
endif

# private options
WPEWEBKIT_CONF_OPT	+= \
	-DENABLE_MEDIA_RECORDER=OFF \
	-DENABLE_MEDIA_SOURCE=ON \
	-DENABLE_MEDIA_STREAM=$(call ptx/onoff,PTXCONF_WPEWEBKIT_WEBRTC) \
	-DENABLE_REMOTE_INSPECTOR=ON \
	-DENABLE_SMOOTH_SCROLLING=OFF \
	-DENABLE_WEBXR=OFF \
	-DENABLE_WEB_CODECS=OFF \
	-DENABLE_WEB_RTC=$(call ptx/onoff,PTXCONF_WPEWEBKIT_WEBRTC) \
	-DUSE_GSTREAMER_GL=OFF \
	-DUSE_SYSPROF_CAPTURE=OFF \
	-DUSE_SYSTEM_MALLOC=$(WPEWEBKIT_SYSTEM_MALLOC) \
	-DUSE_SYSTEM_SYSPROF_CAPTURE=OFF

ifdef PTXCONF_WPEWEBKIT_ENABLE_LOGGING
WPEWEBKIT_CXXFLAGS	:= -DLOG_DISABLED=0 -DENABLE_TREE_DEBUGGING=1
endif

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/wpewebkit.targetinstall:
	@$(call targetinfo)

	@$(call install_init, wpewebkit)
	@$(call install_fixup, wpewebkit,PRIORITY,optional)
	@$(call install_fixup, wpewebkit,SECTION,base)
	@$(call install_fixup, wpewebkit,AUTHOR,"Steffen Trumtrar <s.trumtrar@pengutronix.de>")
	@$(call install_fixup, wpewebkit,DESCRIPTION,missing)

	@$(call install_lib, wpewebkit, 0, 0, 0644, libWPEWebKit-2.0)

	@$(call install_tree, wpewebkit, 0, 0, -, /usr/libexec/wpe-webkit-2.0)
	@$(call install_tree, wpewebkit, 0, 0, -, /usr/lib/wpe-webkit-2.0)

ifdef PTXCONF_WPEWEBKIT_QT
	@$(call install_tree, wpewebkit, 0, 0, -, /usr/lib/qt5/qml/org/wpewebkit)
endif

ifdef PTXCONF_WPEWEBKIT_WEBDRIVER
	@$(call install_copy, wpewebkit, 0, 0, 0755, -, /usr/bin/WPEWebDriver)
endif

	@$(call install_finish, wpewebkit)

	@$(call touch)

# vim: syntax=make
