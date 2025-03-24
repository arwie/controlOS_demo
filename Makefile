PLATFORM ?= x86

PLATFORMCONFIG = configs/platform-$(PLATFORM)/platformconfig
KERNELCONFIG   = configs/platform-$(PLATFORM)/kernelconfig

PTXDIST = ptxdist --quiet --progress -j$(shell nproc) --platformconfig=$(PLATFORMCONFIG)



all: install_img
	@echo "#############################################"
	@echo "Build completed successfully!"


install_img: system_img
	@cd boot \
		&& $(PTXDIST) --collectionconfig=configs/install image install.img

system_img: update .boot-go
	@cd boot \
		&& $(PTXDIST) --collectionconfig=configs/system  image system.img

.boot-go: get
	@cd boot \
		&& $(PTXDIST) go


update: .initramfs
	@cd root \
		&& $(PTXDIST) images

.initramfs: get
	@cd root/base/initramfs \
		&& $(PTXDIST) images


get:
	@for p in boot root/base/initramfs root; do( \
		cd $$p \
			&& $(PTXDIST) get \
	);done



clean:
	@for p in boot/base boot root/base/initramfs root/base root; do( \
		echo "Removing: $$p/platform-*" \
		&& rm -rf $$p/platform-* \
	);done


clean-target:
	@for p in boot root/base/initramfs root; do( \
		cd $$p \
			&& $(PTXDIST) clean target \
	);done



kernel-oldconfig:
	@cd boot \
		&& cat base/$(KERNELCONFIG).d/* $(KERNELCONFIG).d/* > $(KERNELCONFIG) \
		&& yes "" | $(PTXDIST) oldconfig kernel > /dev/null

	@cd root/base \
		&& cat base/$(KERNELCONFIG).d/* $(KERNELCONFIG).d/* > $(KERNELCONFIG) \
		&& yes "" | $(PTXDIST) oldconfig kernel > /dev/null

	@if [ -d "root/$(KERNELCONFIG).d" ]; then \
		cd root \
			&& cat base/base/$(KERNELCONFIG).d/* base/$(KERNELCONFIG).d/* $(KERNELCONFIG).d/* > $(KERNELCONFIG) \
			&& rm -f $(KERNELCONFIG).diff \
			&& yes "" | $(PTXDIST) oldconfig kernel > /dev/null \
	;fi


oldconfig:
	@for p in root/base/initramfs boot root; do( \
		cd $$p \
			&& $(PTXDIST) oldconfig \
			&& $(PTXDIST) oldconfig platform \
	);done



include ptxdist/config

migrate:
	@for p in root/base/initramfs boot root; do( \
		echo "####################\n\n Migrating: $$p \n\n####################" \
		&& cd $$p \
			&& /usr/local/lib/ptxdist-$(PTXDIST_VERSION)/bin/$(PTXDIST) migrate \
	);done



menuconfig:
	@cd root \
		&& $(PTXDIST) menuconfig


select-platform:
	@for p in boot/base boot root/base/initramfs root/base; do( \
		cd $$p \
			&& ln -sf $(PLATFORMCONFIG) selected_platformconfig \
	);done



keygen:
	@cd keys \
		&& ./gpg-keygen \
		&& ./ssh-keygen
