
RELEASE=stretch



# as root

pacman -S --needed debootstrap debian-archive-keyring

cd /var/lib/machines
debootstrap $RELEASE ptxdist/


# within container as root

echo "deb http://debian.pengutronix.de/debian/ $RELEASE main contrib non-free" > /etc/apt/sources.list.d/pengutronix.list
apt-get update
apt-get install pengutronix-archive-keyring

apt-get install -y \
	build-essential libncurses-dev gawk flex bison texinfo file gettext python-dev python3-dev python3-setuptools pkg-config bc libelf-dev ccache zip bzip2 xz-utils \
	python3-systemd python3-tornado systemd-journal-remote \
	sudo git man bash-completion less vim

install toolchain(s)
#apt-get install oselas.toolchain-2018.12.0-arm-v7a-linux-gnueabihf-gcc-8.2.1-glibc-2.28-binutils-2.31.1-kernel-4.19-sanitized

apt-get clean

ln -fs /bin/journalctl /usr/bin/journalctl

#chmod 777 /opt


install ptxdist(s)


# within container as user
ccache --max-size=1G
ptxdist setup
	#-> set src directory
	#-> enable ccache
