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
PACKAGES-$(PTXCONF_LLAMA_CPP) += llama-cpp

#
# Paths and names
#
LLAMA_CPP_VERSION	:= b9789
LLAMA_CPP_SHA256	:= b51f13a1a6656855ff6c0459041e6163c59d5a8d63254a3c0e59c375ce7c2f15
LLAMA_CPP		:= llama.cpp-$(LLAMA_CPP_VERSION)
LLAMA_CPP_SUFFIX	:= tar.gz
LLAMA_CPP_URL		:= https://github.com/ggml-org/llama.cpp/archive/refs/tags/$(LLAMA_CPP_VERSION).$(LLAMA_CPP_SUFFIX)
LLAMA_CPP_SOURCE	:= $(SRCDIR)/$(LLAMA_CPP).$(LLAMA_CPP_SUFFIX)
LLAMA_CPP_DIR		:= $(BUILDDIR)/$(LLAMA_CPP)
LLAMA_CPP_LICENSE	:= MIT
LLAMA_CPP_LICENSE_FILES	:= \
	file://LICENSE;md5=223b26b3c1143120c87e2b13111d3e99

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

LLAMA_CPP_CONF_TOOL	:= cmake

LLAMA_CPP_CONF_OPT	:= \
	$(CROSS_CMAKE_USR) \
	-G Ninja \
	-DCMAKE_BUILD_TYPE=Release \
	-DBUILD_SHARED_LIBS=ON \
	\
	-DLLAMA_ALL_WARNINGS=ON \
	-DLLAMA_ALL_WARNINGS_3RD_PARTY=OFF \
	-DLLAMA_FATAL_WARNINGS=OFF \
	-DLLAMA_BUILD_APP=OFF \
	-DLLAMA_BUILD_EXAMPLES=OFF \
	-DLLAMA_BUILD_TESTS=OFF \
	-DLLAMA_BUILD_UI=OFF \
	-DLLAMA_LLGUIDANCE=OFF \
	-DLLAMA_OPENSSL=OFF \
	-DLLAMA_SANITIZE_ADDRESS=OFF \
	-DLLAMA_SANITIZE_THREAD=OFF \
	-DLLAMA_SANITIZE_UNDEFINED=OFF \
	-DLLAMA_TOOLS_INSTALL=ON \
	-DLLAMA_USE_SYSTEM_GGML=OFF \
	-DLLAMA_BUILD_COMMON=$(call ptx/onoff,PTXCONF_LLAMA_CPP_SERVER) \
	-DLLAMA_BUILD_SERVER=$(call ptx/onoff,PTXCONF_LLAMA_CPP_SERVER) \
	-DLLAMA_BUILD_TOOLS=$(call ptx/onoff,PTXCONF_LLAMA_CPP_SERVER) \
	\
	-DGGML_CPU=ON \
	-DGGML_NATIVE=OFF \
	-DGGML_CPU_ALL_VARIANTS=ON \
	-DGGML_BACKEND_DL=ON \
	-DGGML_BACKEND_DIR=/usr/lib \
	-DGGML_CPU_REPACK=ON \
	-DGGML_CPU_HBM=OFF \
	-DGGML_CPU_KLEIDIAI=OFF \
	-DGGML_LLAMAFILE=ON \
	-DGGML_OPENMP=OFF \
	-DGGML_CCACHE=OFF \
	-DGGML_LTO=OFF \
	-DGGML_GPROF=OFF \
	-DGGML_STATIC=OFF \
	-DGGML_ALL_WARNINGS_3RD_PARTY=OFF \
	-DGGML_SANITIZE_ADDRESS=OFF \
	-DGGML_SANITIZE_THREAD=OFF \
	-DGGML_SANITIZE_UNDEFINED=OFF \
	-DGGML_SCHED_MAX_COPIES=4 \
	-DGGML_SCHED_NO_REALLOC=OFF \
	\
	-DGGML_ACCELERATE=OFF \
	-DGGML_BLAS=OFF \
	-DGGML_CUDA=OFF \
	-DGGML_HEXAGON=OFF \
	-DGGML_HIP=OFF \
	-DGGML_METAL=OFF \
	-DGGML_MUSA=OFF \
	-DGGML_OPENCL=OFF \
	-DGGML_OPENVINO=OFF \
	-DGGML_RPC=OFF \
	-DGGML_SYCL=OFF \
	-DGGML_VIRTGPU=OFF \
	-DGGML_VULKAN=OFF \
	-DGGML_WEBGPU=OFF \
	-DGGML_ZDNN=OFF \
	-DGGML_ZENDNN=OFF

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/llama-cpp.targetinstall:
	@$(call targetinfo)

	@$(call install_init, llama-cpp)
	@$(call install_fixup, llama-cpp,PRIORITY,optional)
	@$(call install_fixup, llama-cpp,SECTION,base)
	@$(call install_fixup, llama-cpp,AUTHOR,"Artur Wiebe <artur@4wiebe.de>")
	@$(call install_fixup, llama-cpp,DESCRIPTION,missing)

	@$(call install_lib, llama-cpp, 0, 0, 0644, libllama)
	@$(call install_lib, llama-cpp, 0, 0, 0644, libggml)
	@$(call install_lib, llama-cpp, 0, 0, 0644, libggml-base)

# CPU backend variants (GGML_CPU_ALL_VARIANTS). ggml builds every feature level
# but we only ship the embedded/client ones and skip the server-class variants
# (AVX-512/AMX on x86, SVE/SVE2/SME/i8mm on ARM). The loader picks the best of
# whatever is installed at runtime, so omitting a variant simply drops that tier.
ifdef PTXCONF_ARCH_X86_64
	@$(call install_lib, llama-cpp, 0, 0, 0644, libggml-cpu-x64)
	@$(call install_lib, llama-cpp, 0, 0, 0644, libggml-cpu-sse42)
	@$(call install_lib, llama-cpp, 0, 0, 0644, libggml-cpu-sandybridge)
	@$(call install_lib, llama-cpp, 0, 0, 0644, libggml-cpu-ivybridge)
	@$(call install_lib, llama-cpp, 0, 0, 0644, libggml-cpu-piledriver)
	@$(call install_lib, llama-cpp, 0, 0, 0644, libggml-cpu-haswell)
	@$(call install_lib, llama-cpp, 0, 0, 0644, libggml-cpu-alderlake)
endif
ifdef PTXCONF_ARCH_ARM64
	@$(call install_lib, llama-cpp, 0, 0, 0644, libggml-cpu-armv8.0_1)
	@$(call install_lib, llama-cpp, 0, 0, 0644, libggml-cpu-armv8.2_1)
	@$(call install_lib, llama-cpp, 0, 0, 0644, libggml-cpu-armv8.2_2)
endif

ifdef PTXCONF_LLAMA_CPP_SERVER
	@$(call install_lib, llama-cpp, 0, 0, 0644, libllama-common)
	@$(call install_lib, llama-cpp, 0, 0, 0644, libmtmd)
	@$(call install_lib, llama-cpp, 0, 0, 0644, libllama-server-impl)
	@$(call install_copy, llama-cpp, 0, 0, 0755, -, /usr/bin/llama-server)
endif

ifdef PTXCONF_LLAMA_CPP_CLI
	@$(call install_lib, llama-cpp, 0, 0, 0644, libllama-cli-impl)
	@$(call install_copy, llama-cpp, 0, 0, 0755, -, /usr/bin/llama-cli)
endif

	@$(call install_finish, llama-cpp)

	@$(call touch)

# vim: syntax=make
