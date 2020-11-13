# -*-makefile-*-
#
# Copyright (C) 2020 by Artur Wiebe <artur@4wiebe.de>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_ARDUINO) += arduino

#
# Paths and names
#
ARDUINO_VERSION	:= 1
ARDUINO			:= arduino-$(ARDUINO_VERSION)
ARDUINO_URL		:= file://local_src/arduino
ARDUINO_DIR		:= $(BUILDDIR)/$(ARDUINO)
ARDUINO_LICENSE	:= unknown

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

ARDUINO_CONF_TOOL	:= NO

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

$(STATEDIR)/arduino.compile:
	@$(call targetinfo)
	
	@cd $(ARDUINO_DIR) && \
		find -mindepth 1 -maxdepth 1 -type d -print0 | \
			xargs -0 -n1 -I{} ./build {} $(ARDUINO_PKGDIR)/usr/lib/arduino
	
	@$(call touch)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

$(STATEDIR)/arduino.install:
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/arduino.targetinstall:
	@$(call targetinfo)
	@$(call install_init, arduino)
	@$(call install_fixup, arduino,PRIORITY,optional)
	@$(call install_fixup, arduino,SECTION,base)
	@$(call install_fixup, arduino,AUTHOR,"Artur Wiebe <artur@4wiebe.de>")
	@$(call install_fixup, arduino,DESCRIPTION,missing)
	
	@$(call install_glob, arduino, 0, 0, -, /usr/lib/arduino, *.ino.bin, , no)
	
	@$(call install_alternative, arduino, 0, 0, 0755, /usr/lib/arduino/arduino-update)
	@$(call install_link, arduino, /usr/lib/arduino/arduino-update, /usr/bin/arduino-update)
	
	@$(call install_alternative, arduino, 0, 0, 0644, /usr/lib/systemd/system/arduino-update@.service)
	@$(call install_alternative, arduino, 0, 0, 0644, /usr/lib/systemd/system/arduino-update.socket)
	@$(call install_link,        arduino, ../arduino-update.socket, /usr/lib/systemd/system/sockets.target.wants/arduino-update.socket)
	
	@$(call install_finish, arduino)
	@$(call touch)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

$(STATEDIR)/arduino.clean:
	@$(call targetinfo)
	@$(call clean_pkg, ARDUINO)

# vim: syntax=make
