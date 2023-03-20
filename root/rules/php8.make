# -*-makefile-*-
#
# Copyright (C) 2006-2008 by Robert Schwebel
#               2009, 2012 by Marc Kleine-Budde <mkl@pengutronix.de>
#               2015 by Bruno Thomsen <bth@kamstrup.com>
#               2021 by Juergen Borleis <jbe@pengutronix.de>
#               2022 by Andreas Helmcke <ahelmcke@ela-soft.com>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_PHP8) += php8

#
# Paths and names
#
PHP8_VERSION	:= 8.2.1
PHP8_MD5	:= b30961d64b35fe4c6727ee3add54d16e
PHP8		:= php-$(PHP8_VERSION)
PHP8_SUFFIX	:= tar.xz
PHP8_SOURCE	:= $(SRCDIR)/$(PHP8).$(PHP8_SUFFIX)
PHP8_DIR	:= $(BUILDDIR)/$(PHP8)
PHP8_LICENSE 	:= PHP-3.01
PHP8_LICENSE_FILES := file://LICENSE;md5=5ebd5be8e2a89f634486445bd164bef0

#
# Note: older releases are moved to the 'museum', but the 'de.php.net'
# response with a HTML file instead of the archive. So, try the 'museum'
# URL first
#
PHP8_URL := \
	http://museum.php.net/php8/$(PHP8).$(PHP8_SUFFIX) \
	http://de.php.net/distributions/$(PHP8).$(PHP8_SUFFIX)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

#
# autoconf
#
PHP8_CONF_TOOL := autoconf
PHP8_CONF_OPT := \
	$(CROSS_AUTOCONF_USR) \
	--disable-rpath \
	--disable-re2c-cgoto \
	--disable-gcc-global-regs \
	--without-apxs2 \
	--$(call ptx/endis, PTXCONF_PHP8_SAPI_CLI)-cli \
	--without-pear \
	--disable-embed \
	--disable-fpm \
	--without-fpm-user \
	--without-fpm-group \
	--without-fpm-systemd \
	--without-fpm-acl \
	--without-fpm-apparmor \
	--without-fpm-selinux \
	--disable-fuzzer \
	--disable-litespeed \
	--disable-phpdbg \
	--disable-phpdbg-debug \
	--disable-phpdbg-readline \
	--$(call ptx/endis, PTXCONF_PHP8_SAPI_CGI)-cgi \
	--without-valgrind \
	--disable-gcov \
	--disable-debug \
	--disable-debug-assertions \
	--disable-zts \
	--disable-rtld-now \
	--without-layout \
	--with-config-file-path=/etc/php8 \
	--without-config-file-scan-dir \
	--disable-sigchild \
	--disable-libgcc \
	--enable-short-tags \
	--disable-dmalloc \
	--$(call ptx/endis, PTXCONF_GLOBAL_IPV6)-ipv6 \
	--disable-dtrace \
	--disable-fd-setsize \
	--disable-werror \
	--disable-memory-sanitizer \
	--disable-address-sanitizer \
	--disable-undefined-sanitizer \
	--disable-all \
	--without-libxml \
	--without-openssl \
	--without-kerberos \
	--without-system-ciphers \
	--without-external-pcre \
	--without-pcre-jit \
	--without-sqlite3 \
	--without-zlib \
	--disable-bcmath \
	--without-bz2 \
	--disable-calendar \
	--disable-ctype \
	--without-curl \
	--disable-dba \
	--without-qdbm \
	--without-gdbm \
	--without-ndbm \
	--without-db4 \
	--without-db3 \
	--without-db2 \
	--without-db1 \
	--without-dbm \
	--without-tcadb \
	--without-lmdb \
	--without-cdb \
	--disable-inifile \
	--disable-flatfile \
	--disable-dl-test \
	--disable-dom \
	--without-enchant \
	--disable-exif \
	--without-ffi \
	--disable-fileinfo \
	--$(call ptx/endis, PTXCONF_PHP8_FILTER)-filter \
	--disable-ftp \
	--without-openssl-dir \
	--disable-gd \
	--without-external-gd \
	--without-avif \
	--without-webp \
	--without-jpeg \
	--without-xpm \
	--without-freetype \
	--disable-gd-jis-conv \
	--without-gettext \
	--without-gmp \
	--without-mhash \
	--without-iconv \
	--without-imap \
	--without-imap-ssl \
	--disable-intl \
	--without-ldap \
	--without-ldap-sasl \
	--disable-mbstring \
	--disable-mbregex \
	--without-mysqli \
	--without-mysql-sock \
	--without-oci8 \
	--without-odbcver \
	--without-adabas \
	--without-sapdb \
	--without-solid \
	--without-ibm-db2 \
	--without-empress \
	--without-empress-bcs \
	--without-custom-odbc \
	--without-iodbc \
	--without-esoob \
	--without-unixODBC \
	--without-dbmaker \
	--disable-opcache \
	--disable-huge-code-pages \
	--disable-opcache-jit \
	--disable-pcntl \
	--disable-pdo \
	--without-pdo-dblib \
	--without-pdo-firebird \
	--without-pdo-mysql \
	--without-zlib-dir \
	--without-pdo-oci \
	--without-pdo-odbc \
	--without-pdo-pgsql \
	--without-pdo-sqlite \
	--without-pgsql \
	--disable-phar \
	--disable-posix \
	--without-pspell \
	--without-libedit \
	--without-readline \
	--$(call ptx/endis, PTXCONF_PHP8_SESSION)-session \
	--without-mm \
	--disable-shmop \
	--disable-simplexml \
	--without-snmp \
	--disable-soap \
	--disable-sockets \
	--without-sodium \
	--without-external-libcrypt \
	--without-password-argon2 \
	--disable-sysvmsg \
	--disable-sysvsem \
	--disable-sysvshm \
	--without-tidy \
	--disable-tokenizer \
	--disable-xml \
	--without-expat \
	--disable-xmlreader \
	--disable-xmlwriter \
	--without-xsl \
	--disable-zend-test \
	--without-zip \
	--disable-mysqlnd \
	--disable-mysqlnd-compression-support \
	--without-pear \
	--disable-fiber-asm \
	--disable-zend-signals

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

$(STATEDIR)/php8.install:
	@$(call targetinfo)
	@$(call world/install, PHP8)
	@install -vD -m644 $(PHP8_DIR)/php.ini-production \
		$(PHP8_PKGDIR)/etc/php8/php.ini
	@$(call touch)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/php8.targetinstall:
	@$(call targetinfo)

	@$(call install_init, php8)
	@$(call install_fixup, php8,PRIORITY,optional)
	@$(call install_fixup, php8,SECTION,base)
	@$(call install_fixup, php8,AUTHOR,"Robert Schwebel <r.schwebel@pengutronix.de>")
	@$(call install_fixup, php8,DESCRIPTION,missing)

ifdef PTXCONF_PHP8_SAPI_CLI
	@$(call install_copy, php8, 0, 0, 0755, -, /usr/bin/php)
endif

ifdef PTXCONF_PHP8_SAPI_CGI
	@$(call install_copy, php8, 0, 0, 0755, -, /usr/bin/php-cgi)
endif

ifdef PTXCONF_PHP8_INI
	@$(call install_alternative, php8, 0, 0, 0644, /etc/php8/php.ini)
endif

	@$(call install_finish, php8)

	@$(call touch)

# vim: syntax=make
