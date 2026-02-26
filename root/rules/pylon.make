#
# We provide this package
#
PACKAGES-$(PTXCONF_PYLON) += pylon

PYLON_VERSION	:= 6.1.1.19861
PYLON_MD5		:= 6f1f5ed9e6fc2a564bd83a1109043acd
PYLON			:= pylon_$(PYLON_VERSION)_x86_64
PYLON_SUFFIX	:= tar.gz
PYLON_URL		:= https://www.baslerweb.com/en/sales-support/downloads/software-downloads/pylon-6-1-1-linux-x86-64-bit/
PYLON_SOURCE	:= $(SRCDIR)/$(PYLON).$(PYLON_SUFFIX)
PYLON_DIR		:= $(BUILDDIR)/$(PYLON)

PYLON_PYPYLON_VERSION	:= 1.6.0
PYLON_PYPYLON_MD5		:= 45feb2ef9b4734044bf6095925a62352
PYLON_PYPYLON			:= pypylon-$(PYLON_PYPYLON_VERSION)-cp37-cp37m-linux_x86_64
PYLON_PYPYLON_SUFFIX	:= whl
PYLON_PYPYLON_URL		:= https://github.com/basler/pypylon/releases/download/1.6.0/pypylon-1.6.0-cp37-cp37m-linux_x86_64.whl
PYLON_PYPYLON_SOURCE	:= $(SRCDIR)/$(PYLON_PYPYLON).$(PYLON_PYPYLON_SUFFIX)
PYLON_PYPYLON_DIR		:= $(PYLON_DIR)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

$(STATEDIR)/pylon.extract:
	@$(call targetinfo)

	@$(call clean, $(PYLON_DIR))
	@mkdir -p $(PYLON_DIR)
	@tar --no-same-owner -C $(PYLON_DIR) -xf $(PYLON_SOURCE)
	
ifdef PTXCONF_PYLON_PYTHON
	@unzip -d $(PYLON_PYPYLON_DIR) $(PYLON_PYPYLON_SOURCE)
endif

	@$(call touch)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

ARDUINO_CONF_TOOL	:= NO

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

$(STATEDIR)/pylon.compile:
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

$(STATEDIR)/pylon.install:
	@$(call targetinfo)

	@mkdir -p $(PYLON_PKGDIR)/opt/pylon/lib $(PYLON_PKGDIR)/opt/pylon/bin
	@cp -dr $(PYLON_DIR)/include $(PYLON_PKGDIR)/opt/pylon
	@cp -d  $(PYLON_DIR)/lib/*.so $(PYLON_PKGDIR)/opt/pylon/lib
	@cp -d  $(PYLON_DIR)/bin/pylon-config $(PYLON_PKGDIR)/opt/pylon/bin
	
ifdef PTXCONF_PYLON_PYTHON
	@mkdir -p $(PYLON_PKGDIR)/$(PYTHON3_SITEPACKAGES)
	@cp -dr $(PYLON_DIR)/pypylon $(PYLON_PKGDIR)/$(PYTHON3_SITEPACKAGES)
endif

	@$(call touch)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/pylon.targetinstall:
	@$(call targetinfo)
	@$(call install_init, pylon)

	@$(call install_tree, pylon, 0, 0, $(PYLON_PKGDIR)/opt/pylon/lib, /usr/lib)

ifdef PTXCONF_PYLON_PYTHON
	@$(call install_tree, pylon, 0, 0, -, $(PYTHON3_SITEPACKAGES))
endif

	@$(call install_finish, pylon)
	@$(call touch)

# vim: syntax=make
