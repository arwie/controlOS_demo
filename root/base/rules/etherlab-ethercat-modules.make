# -*-makefile-*-
#
# Copyright (C) 2022 by Artur Wiebe <artur@4wiebe.de>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_ETHERLAB_ETHERCAT_MODULES) += etherlab-ethercat-modules

#
# Paths and names and versions
#
ETHERLAB_ETHERCAT_MODULES_VERSION	= $(ETHERLAB_ETHERCAT_VERSION)
ETHERLAB_ETHERCAT_MODULES_MD5		= $(ETHERLAB_ETHERCAT_MD5)
ETHERLAB_ETHERCAT_MODULES		= etherlab-ethercat-modules-$(ETHERLAB_ETHERCAT_MODULES_VERSION)
ETHERLAB_ETHERCAT_MODULES_SUFFIX	= $(ETHERLAB_ETHERCAT_SUFFIX)
ETHERLAB_ETHERCAT_MODULES_URL		= $(ETHERLAB_ETHERCAT_URL)
ETHERLAB_ETHERCAT_MODULES_SOURCE	= $(ETHERLAB_ETHERCAT_SOURCE)
ETHERLAB_ETHERCAT_MODULES_DIR		= $(BUILDDIR)/$(ETHERLAB_ETHERCAT_MODULES)
ETHERLAB_ETHERCAT_MODULES_LICENSE	= $(ETHERLAB_ETHERCAT_LICENSE)
ETHERLAB_ETHERCAT_MODULES_LICENSE_FILES	= $(ETHERLAB_ETHERCAT_LICENSE_FILES)

ifneq ($(filter $(if $(PTX_COLLECTION),y,y m),$(PTXCONF_ETHERLAB_ETHERCAT_MODULES)),)
$(STATEDIR)/kernel.targetinstall.post: $(STATEDIR)/etherlab-ethercat-modules.targetinstall
endif

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

ETHERLAB_ETHERCAT_MODULES_WRAPPER_BLACKLIST = $(KERNEL_WRAPPER_BLACKLIST)

ETHERLAB_ETHERCAT_MODULES_CONF_TOOL	= $(ETHERLAB_ETHERCAT_CONF_TOOL)
ETHERLAB_ETHERCAT_MODULES_CONF_OPT	= $(ETHERLAB_ETHERCAT_CONF_OPT)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

ETHERLAB_ETHERCAT_MODULES_MAKE_OPT = \
	$(KERNEL_MODULE_OPT) \
	-C $(KERNEL_DIR) \
	M=$(ETHERLAB_ETHERCAT_MODULES_DIR) \
	modules

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

$(STATEDIR)/etherlab-ethercat-modules.install:
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/etherlab-ethercat-modules.targetinstall:
	@$(call targetinfo)
	@$(call compile, ETHERLAB_ETHERCAT_MODULES, $(ETHERLAB_ETHERCAT_MODULES_MAKE_OPT)_install)
	@$(call touch)

# vim: syntax=make
