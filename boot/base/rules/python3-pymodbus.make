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
PACKAGES-$(PTXCONF_PYTHON3_PYMODBUS) += python3-pymodbus

#
# Paths and names
#
PYTHON3_PYMODBUS_VERSION	:= 3.8.6
PYTHON3_PYMODBUS_MD5		:= af760b61450c670a280c098e3484635d
PYTHON3_PYMODBUS		:= pymodbus-$(PYTHON3_PYMODBUS_VERSION)
PYTHON3_PYMODBUS_SUFFIX		:= tar.gz
PYTHON3_PYMODBUS_URL		:= $(call ptx/mirror-pypi, pymodbus, $(PYTHON3_PYMODBUS).$(PYTHON3_PYMODBUS_SUFFIX))
PYTHON3_PYMODBUS_SOURCE		:= $(SRCDIR)/$(PYTHON3_PYMODBUS).$(PYTHON3_PYMODBUS_SUFFIX)
PYTHON3_PYMODBUS_DIR		:= $(BUILDDIR)/$(PYTHON3_PYMODBUS)
PYTHON3_PYMODBUS_LICENSE	:= BSD-3-Clause
PYTHON3_PYMODBUS_LICENSE_FILES	:= \
	file://LICENSE;md5=eba8057aa82c058d2042b4b0a0e9cc63

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

PYTHON3_PYMODBUS_CONF_TOOL	:= python3

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/python3-pymodbus.targetinstall:
	@$(call targetinfo)

	@$(call install_init, python3-pymodbus)
	@$(call install_fixup, python3-pymodbus,PRIORITY,optional)
	@$(call install_fixup, python3-pymodbus,SECTION,base)
	@$(call install_fixup, python3-pymodbus,AUTHOR,"Artur Wiebe <artur@4wiebe.de>")
	@$(call install_fixup, python3-pymodbus,DESCRIPTION,missing)

	@$(call install_glob, python3-pymodbus, 0, 0, -, \
		$(PYTHON3_SITEPACKAGES)/pymodbus,, *.py)

	@$(call install_finish, python3-pymodbus)

	@$(call touch)

# vim: syntax=make
