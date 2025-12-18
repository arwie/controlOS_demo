# -*-makefile-*-
#
# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

#
# We provide this package
#
PACKAGES-$(PTXCONF_PYTHON_SHARED) += python-shared

PYTHON_SHARED_VERSION	:= 1
PYTHON_SHARED		:= python-shared
PYTHON_SHARED_SRC	:= $(PTXDIST_WORKSPACE)/../code/shared

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/python-shared.targetinstall: $(shell find $(PYTHON_SHARED_SRC) -type d)
	@$(call targetinfo)
	@$(call install_init, python-shared)

	@$(call install_tree, python-shared, 0, 0, \
		$(PYTHON_SHARED_SRC), $(PYTHON3_SITEPACKAGES)/shared)

	@$(call install_finish,python-shared)
	@$(call touch)


# vim: syntax=make
