# -*-makefile-*-
#
# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

#
# We provide this package
#
PACKAGES-$(PTXCONF_PYTHON_SHARED) += python-shared

PYTHON_SHARED_VERSION	:= 1
PYTHON_SHARED			:= python-shared
PYTHON_SHARED_SRC		:= $(PTXDIST_WORKSPACE)/local_src/python-shared
PYTHON_SHARED_URL		:= lndir://$(PYTHON_SHARED_SRC)
PYTHON_SHARED_DIR		:= $(BUILDDIR)/$(PYTHON_SHARED)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

$(STATEDIR)/python-shared.extract: $(shell find $(PYTHON_SHARED_SRC))
	@$(call targetinfo)
	@rm -rf $(PYTHON_SHARED_DIR)
	@$(call extract, PYTHON_SHARED)
	@$(call touch)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

PYTHON_SHARED_CONF_TOOL	:= python3

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/python-shared.targetinstall:
	@$(call targetinfo)
	@$(call install_init, python-shared)

	@$(call install_glob, python-shared, 0, 0, -, \
		$(PYTHON3_SITEPACKAGES)/shared,, *.py)

	@$(call install_finish,python-shared)
	@$(call touch)


# vim: syntax=make
