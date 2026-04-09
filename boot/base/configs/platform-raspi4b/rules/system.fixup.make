IMAGE_SYSTEM_BOOTFILES := start4.elf fixup4.dat config.txt cmdline.txt
IMAGE_SYSTEM_ENV += \
	BOOTFILES="$(foreach f,$(IMAGE_SYSTEM_BOOTFILES),file $(f) { image = "$(call ptx/in-platformconfigdir, $(f))" })"
