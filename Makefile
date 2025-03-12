BASEDIR=$(shell pwd)
NP=$(shell nproc)



all: system
	@echo "#############################################"
	@echo "Build completed successfully!"

system: update
	@cd boot \
		&& ptxdist -j$(NP) -k --collectionconfig=configs/system  image system.img \
		&& ptxdist -j$(NP) -k --collectionconfig=configs/install image install.img

update: initramfs
	@cd root \
		&& ptxdist -j$(NP) -k images

initramfs:
	@cd root/base/initramfs \
		&& ptxdist -j$(NP) -k images



clean:
	@for p in boot/base boot root/base/initramfs root/base root; do \
		echo "Removing: $$p/platform-*" \
		&& rm -rf $(BASEDIR)/$$p/platform-* \
	;done


clean-target:
	@for p in boot root/base/initramfs root; do \
		cd $(BASEDIR)/$$p \
		&& ptxdist -q clean target \
	;done



PLATFORM=$(shell cd boot && ptxdist print PTXCONF_PLATFORM)
KERNELCONFIG=configs/platform-$(PLATFORM)/kernelconfig

kernel-oldconfig:
	@cd $(BASEDIR)/boot \
		&& cat base/$(KERNELCONFIG).d/* $(KERNELCONFIG).d/* > $(KERNELCONFIG) \
		&& yes "" | ptxdist oldconfig kernel > /dev/null

	@cd $(BASEDIR)/root/base \
		&& cat base/$(KERNELCONFIG).d/* $(KERNELCONFIG).d/* > $(KERNELCONFIG) \
		&& yes "" | ptxdist oldconfig kernel > /dev/null

	@if [ -d "$(BASEDIR)/root/$(KERNELCONFIG).d" ]; then \
		cd $(BASEDIR)/root \
			&& cat base/base/$(KERNELCONFIG).d/* base/$(KERNELCONFIG).d/* $(KERNELCONFIG).d/* > $(KERNELCONFIG) \
			&& rm -f $(KERNELCONFIG).diff \
			&& yes "" | ptxdist oldconfig kernel > /dev/null \
	;fi


oldconfig:
	@for p in root/base/initramfs boot root; do \
		cd $(BASEDIR)/$$p \
		&& ptxdist oldconfig \
		&& ptxdist oldconfig platform \
	;done



include ptxdist/config

migrate:
	@for p in root/base/initramfs boot root; do \
		echo "####################\n\n Migrating: $$p \n\n####################" \
		&& cd $(BASEDIR)/$$p \
		&& /usr/local/lib/ptxdist-$(PTXDIST_VERSION)/bin/ptxdist migrate \
	;done



keygen:
	$(BASEDIR)/keys/gpg-keygen
	$(BASEDIR)/keys/ssh-keygen
