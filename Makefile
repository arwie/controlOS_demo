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

system_img: update
	@cd boot \
		&& $(PTXDIST) --collectionconfig=configs/system  image system.img


update: .initramfs keygen
	@cd root \
		&& ln -sf platform-$(PLATFORM) platform-any \
		&& $(PTXDIST) images

.initramfs:
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



keygen: \
	keys/projectroot/etc/gpg/update.pubkey \
	keys/projectroot/etc/gpg/backup.pubkey \
	keys/projectroot/etc/gpg/common.symkey \
	keys/projectroot/etc/ssh/ssh_host_rsa_key \
	keys/projectroot/root/.ssh/authorized_keys \
	keys/projectroot/root/.ssh/id_rsa

keys/projectroot/etc/gpg/%.pubkey:
	@mkdir -p keys/projectroot/etc/gpg \
	&& gpg --homedir=keys --batch --passphrase='' --quick-generate-key $* default default never \
	&& gpg --homedir=keys --output=keys/projectroot/etc/gpg/$*.pubkey --export $*

keys/projectroot/etc/gpg/common.symkey:
	@mkdir -p keys/projectroot/etc/gpg \
	&& gpg --homedir=keys --no-random-seed-file --armor --gen-random 2 64 > keys/common.symkey \
	&& cp keys/common.symkey keys/projectroot/etc/gpg

keys/projectroot/etc/ssh/ssh_host_rsa_key:
	@mkdir -p keys/projectroot/etc/ssh \
	&& ssh-keygen -f keys/projectroot/etc/ssh/ssh_host_rsa_key -N ""

keys/projectroot/root/.ssh/authorized_keys:
	@mkdir -p keys/projectroot/root/.ssh \
	&& ssh-keygen -f keys/id_rsa -N "" \
	&& cp keys/id_rsa.pub keys/projectroot/root/.ssh/authorized_keys

keys/projectroot/root/.ssh/id_rsa:
	@mkdir -p keys/projectroot/root/.ssh \
	&& ssh-keygen -f keys/projectroot/root/.ssh/id_rsa -N ""
