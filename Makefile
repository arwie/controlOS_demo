PLATFORM ?= x86
JOBS ?= $(shell jmax=16 ; j=$$(nproc); echo $$((j < jmax ? j : jmax)))

PLATFORMCONFIG = configs/platform-$(PLATFORM)/platformconfig
KERNELCONFIG   = configs/platform-$(PLATFORM)/kernelconfig

PTXDIST = ptxdist --quiet --progress -j$(JOBS) --platformconfig=$(PLATFORMCONFIG)



all: install
	@echo "#############################################"
	@echo "Build completed successfully!"


install: update
	@cd boot \
		&& $(PTXDIST) images

update: .initramfs keygen
	@cd root \
		&& ln -sf platform-$(PLATFORM) platform-any \
		&& $(PTXDIST) images

.initramfs:
	@cd boot \
		&& $(PTXDIST) image root.cpio


get:
	@for p in boot root; do( \
		cd $$p \
			&& $(PTXDIST) get \
	);done



clean:
	@for p in boot/base boot root/base root; do( \
		echo "Removing: $$p/platform-*" \
		&& rm -rf $$p/platform-* \
	);done


clean-target:
	@for p in boot root; do( \
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
	@for p in boot root; do( \
		cd $$p \
			&& $(PTXDIST) oldconfig \
			&& $(PTXDIST) oldconfig platform \
	);done



include ptxdist/config

migrate:
	@for p in boot root; do( \
		echo "####################\n\n Migrating: $$p \n\n####################" \
		&& cd $$p \
			&& /usr/local/lib/ptxdist-$(PTXDIST_VERSION)/bin/$(PTXDIST) migrate \
	);done



menuconfig:
	@cd root \
		&& $(PTXDIST) menuconfig


select-platform:
	@for p in boot/base boot root/base; do( \
		cd $$p \
			&& ln -sf $(PLATFORMCONFIG) selected_platformconfig \
	);done



keygen: \
	keys/sb.key \
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

keys/sb.key:
	@openssl req -new -x509 -newkey rsa:2048 -sha256 -nodes -keyout keys/sb.key -out keys/sb.crt -days 365000 -subj "/CN=controlOS/"
