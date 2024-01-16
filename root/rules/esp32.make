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
PACKAGES-$(PTXCONF_ESP32) += esp32

#
# Paths and names
#
ESP32_VERSION	:= 1
ESP32			:= esp32-$(ESP32_VERSION)
ESP32_URL		:= file://local_src/esp32
ESP32_DIR		:= $(BUILDDIR)/$(ESP32)
ESP32_LICENSE	:= unknown

ESP32_PROJECTS = $(call remove_quotes, $(PTXCONF_ESP32_PROJECTS))
ESP32_INSTALL  = /usr/lib/esp32

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

ESP32_CONF_TOOL	:= NO

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

$(STATEDIR)/esp32.compile:
	@$(call targetinfo)
	
	@$(foreach project, $(ESP32_PROJECTS), \
		$(ESP32_DIR)/build $(project) $(ESP32_PKGDIR)/$(ESP32_INSTALL)/$(project); \
	)
	
	@$(call touch)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

$(STATEDIR)/esp32.install:
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/esp32.targetinstall:
	@$(call targetinfo)
	@$(call install_init, esp32)
	@$(call install_fixup, esp32,PRIORITY,optional)
	@$(call install_fixup, esp32,SECTION,base)
	@$(call install_fixup, esp32,AUTHOR,"Artur Wiebe <artur@4wiebe.de>")
	@$(call install_fixup, esp32,DESCRIPTION,missing)
	
	@$(foreach project, $(ESP32_PROJECTS), \
		@$(call install_copy, esp32, 0, 0, 0644, -, $(ESP32_INSTALL)/$(project)/boot.bin, no); \
		@$(call install_copy, esp32, 0, 0, 0644, -, $(ESP32_INSTALL)/$(project)/part.bin, no); \
		@$(call install_copy, esp32, 0, 0, 0644, -, $(ESP32_INSTALL)/$(project)/ota.bin,  no); \
		@$(call install_copy, esp32, 0, 0, 0644, -, $(ESP32_INSTALL)/$(project)/app.bin,  no); \
		@$(call install_copy, esp32, 0, 0, 0644, -, $(ESP32_INSTALL)/$(project)/app.hash); \
		@$(call install_copy, esp32, 0, 0, 0644, -, $(ESP32_INSTALL)/$(project)/flash.conf); \
	)
	
	@$(call install_alternative, esp32, 0, 0, 0755, /usr/bin/esp32-update)
	
	@$(call install_alternative, esp32, 0, 0, 0755, $(ESP32_INSTALL)/esp32-ota)
	@$(call install_alternative, esp32, 0, 0, 0644, /usr/lib/systemd/system/esp32-ota@.service)
	@$(call install_alternative, esp32, 0, 0, 0644, /usr/lib/systemd/system/esp32-ota.socket)
	@$(call install_link,        esp32, ../esp32-ota.socket, /usr/lib/systemd/system/sockets.target.wants/esp32-ota.socket)
	
	@$(call install_finish, esp32)
	@$(call touch)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

$(STATEDIR)/esp32.clean:
	@$(call targetinfo)
	@$(call clean_pkg, ESP32)

# vim: syntax=make
