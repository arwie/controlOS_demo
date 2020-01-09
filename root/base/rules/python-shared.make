# -*-makefile-*-
#
# Copyright (c) 2017 Artur Wiebe <artur@4wiebe.de>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
# associated documentation files (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#
# We provide this package
#
PACKAGES-$(PTXCONF_PYTHON_SHARED) += python-shared

PYTHON_SHARED_VERSION	:= 1
PYTHON_SHARED			:= python-shared
PYTHON_SHARED_URL		:= lndir://$(PTXDIST_WORKSPACE)/local_src/python-shared
PYTHON_SHARED_DIR		:= $(BUILDDIR)/$(PYTHON_SHARED)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

PYTHON_SHARED_CONF_TOOL    := python3

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/python-shared.targetinstall:
	@$(call targetinfo)
	@$(call install_init, python-shared)

	@$(call install_glob, python-shared, 0, 0, -, \
		/usr/lib/python$(PYTHON3_MAJORMINOR)/site-packages/shared,, *.py)

	@$(call install_finish,python-shared)
	@$(call touch)


# vim: syntax=make
