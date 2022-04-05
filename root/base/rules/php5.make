# -*-makefile-*-
#
# Copyright (C) 2006-2008 by Robert Schwebel
#               2009, 2012 by Marc Kleine-Budde <mkl@pengutronix.de>
#               2015 by Bruno Thomsen <bth@kamstrup.com>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_PHP5) += php5

#
# Paths and names
#
PHP5_VERSION	:= 5.6.40
PHP5_MD5	:= c7dde3afb16ce7b761abf2805125d372
PHP5		:= php-$(PHP5_VERSION)
PHP5_SUFFIX	:= tar.xz
PHP5_SOURCE	:= $(SRCDIR)/$(PHP5).$(PHP5_SUFFIX)
PHP5_DIR	:= $(BUILDDIR)/$(PHP5)

#
# Note: older releases are moved to the 'museum', but the 'de.php.net'
# response with a HTML file instead of the archive. So, try the 'museum'
# URL first
#
PHP5_URL := \
	http://museum.php.net/php5/$(PHP5).$(PHP5_SUFFIX) \
	http://de.php.net/distributions/$(PHP5).$(PHP5_SUFFIX)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

PHP5_CONF_ENV := \
	$(CROSS_ENV) \
	ac_cv_prog_cc_cross=yes \
	ac_cv_c_bigendian_php=$(call ptx/yesno, PTXCONF_ENDIAN_BIG)

#
# autoconf
#
PHP5_AUTOCONF := \
	$(CROSS_AUTOCONF_USR) \
	--disable-phar \
	--with-config-file-path=/etc/php5 \
	--enable-opcache=no \
	--disable-fileinfo \
	--without-xmlrpc \
	--without-iconv

# FIXME: php5 doesn't interprete "with_foo=no" correctly, so we cannot
# give --without-foo options. Should be fixed in php5's configure.in.

# ------------
# SAPI Modules
# ------------

ifdef PTXCONF_PHP5_SAPI_AOLSERVER
PHP5_AUTOCONF += --with-aolserver=FIXME
else
PHP5_AUTOCONF += --without-aolserver
endif

ifdef PTXCONF_PHP5_SAPI_APXS2FILTER
PHP5_AUTOCONF += --with-apxs2filter=$(PTXDIST_SYSROOT_TARGET)/usr/bin/apxs
else
#PHP5_AUTOCONF += --without-apxs2filter
endif

ifdef PTXCONF_PHP5_SAPI_APXS2
PHP5_AUTOCONF += --with-apxs2=$(PTXDIST_SYSROOT_TARGET)/usr/bin/apxs
else
# PHP5_AUTOCONF += --without-apxs2
endif

ifdef PTXCONF_PHP5_SAPI_CAUDIUM
PHP5_AUTOCONF += --with-caudium
else
# PHP5_AUTOCONF += --without-caudium
endif

ifdef PTXCONF_PHP5_SAPI_CLI
PHP5_AUTOCONF += --enable-cli
else
PHP5_AUTOCONF += --disable-cli
endif

ifdef PTXCONF_PHP5_SAPI_CONTINUITY
PHP5_AUTOCONF += --with-continuity
else
#PHP5_AUTOCONF += --without-continuity
endif

ifdef PTXCONF_PHP5_SAPI_EMBEDDED
PHP5_AUTOCONF += --enable-embed
else
#PHP5_AUTOCONF += --disable-embed
endif

ifdef PTXCONF_PHP5_SAPI_ISAPI
PHP5_AUTOCONF += --with-isapi
else
#PHP5_AUTOCONF += --without-isapi
endif

ifdef PTXCONF_PHP5_SAPI_MILTER
PHP5_AUTOCONF += --with-milter
else
#PHP5_AUTOCONF += --without-milter
endif

ifdef PTXCONF_PHP5_SAPI_NSAPI
PHP5_AUTOCONF += --with-nsapi
else
#PHP5_AUTOCONF += --without-nsapi
endif

ifdef PTXCONF_PHP5_SAPI_PHTTPD
PHP5_AUTOCONF += --with-phttpd
else
#PHP5_AUTOCONF += --without-phttpd
endif

ifdef PTXCONF_PHP5_SAPI_PI3WEB
PHP5_AUTOCONF += --with-pi3web
else
#PHP5_AUTOCONF += --without-pi3web
endif

ifdef PTXCONF_PHP5_SAPI_ROXEN
PHP5_AUTOCONF += --with-roxen
else
#PHP5_AUTOCONF += --without-roxen
endif

ifdef PTXCONF_PHP5_SAPI_ROXEN_ZTS
PHP5_AUTOCONF += --with-roxen-zts
else
#PHP5_AUTOCONF += --without-roxen-zts
endif

ifdef PTXCONF_PHP5_SAPI_THTTPD
PHP5_AUTOCONF += --with-thttpd
else
#PHP5_AUTOCONF += --without-thttpd
endif

ifdef PTXCONF_PHP5_SAPI_TUX
PHP5_AUTOCONF += --with-tux
else
#PHP5_AUTOCONF += --without-tux
endif

ifdef PTXCONF_PHP5_SAPI_CGI
PHP5_AUTOCONF += --enable-cgi
else
PHP5_AUTOCONF += --disable-cgi
endif

# ---------------
# General Options
# ---------------

ifdef PTXCONF_PHP5_XML
PHP5_AUTOCONF += --enable-xml
else
PHP5_AUTOCONF += --disable-xml
endif

ifdef PTXCONF_PHP5_XML_LIBXML2
PHP5_AUTOCONF += \
	--enable-libxml \
	--with-libxml-dir=$(SYSROOT)/usr
else
PHP5_AUTOCONF += --disable-libxml
endif

ifdef PTXCONF_PHP5_XML_LIBXML2_READER
PHP5_AUTOCONF += --enable-xmlreader
else
PHP5_AUTOCONF += --disable-xmlreader
endif

ifdef PTXCONF_PHP5_XML_LIBXML2_WRITER
PHP5_AUTOCONF += --enable-xmlwriter
else
PHP5_AUTOCONF += --disable-xmlwriter
endif

ifdef PTXCONF_PHP5_XML_LIBXML2_DOM
PHP5_AUTOCONF += --enable-dom
else
PHP5_AUTOCONF += --disable-dom
endif

ifdef PTXCONF_PHP5_XML_LIBXML2_XSLT
PHP5_AUTOCONF += --with-xsl=$(SYSROOT)/usr
else
PHP5_AUTOCONF += --without-xsl
endif

ifdef PTXCONF_PHP5_XML_LIBXML2_SIMPLEXML
PHP5_AUTOCONF += --enable-simplexml
else
PHP5_AUTOCONF += --disable-simplexml
endif

ifdef PTXCONF_PHP5_EXT_ZLIB
PHP5_AUTOCONF += --with-zlib=$(SYSROOT)/usr
else
PHP5_AUTOCONF += --without-zlib
endif

ifdef PTXCONF_PHP5_EXT_OPENSSL
PHP5_AUTOCONF += --with-openssl=$(SYSROOT)/usr
else
PHP5_AUTOCONF += --without-openssl
endif

ifdef PTXCONF_PHP5_EXT_CURL
PHP5_AUTOCONF += \
	--with-curl=$(SYSROOT)/usr
else
PHP5_AUTOCONF += --without-curl
endif

ifdef PTXCONF_PHP5_EXT_MYSQL
PHP5_AUTOCONF += \
	--with-mysql=$(SYSROOT)/usr \
	--with-pdo-mysql=$(SYSROOT)/usr
else
PHP5_AUTOCONF += --without-mysql
endif

ifdef PTXCONF_PHP5_EXT_SOAP
PHP5_AUTOCONF += --enable-soap
else
PHP5_AUTOCONF += --disable-soap
endif

ifdef PTXCONF_PHP5_EXT_SOCKETS
PHP5_AUTOCONF += --enable-sockets
else
PHP5_AUTOCONF += --disable-sockets
endif

ifdef PTXCONF_PHP5_EXT_SQLITE3
PHP5_AUTOCONF += --with-sqlite3=$(PTXDIST_SYSROOT_TARGET)/usr --with-pdo-sqlite
# broken config system: sqlite3 (local copy) uses it
# but it is only linked to if used by external dependencies
PHP5_CONF_ENV += PHP_LDFLAGS="-ldl -lpthread"
else
PHP5_AUTOCONF += --without-sqlite3 --without-pdo-sqlite
endif

ifdef PTXCONF_PHP5_EXT_PEAR
PHP5_AUTOCONF += --with-pear=FIXME
else
PHP5_AUTOCONF += --without-pear
endif

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/php5.targetinstall:
	@$(call targetinfo)

	@$(call install_init, php5)
	@$(call install_fixup, php5,PRIORITY,optional)
	@$(call install_fixup, php5,SECTION,base)
	@$(call install_fixup, php5,AUTHOR,"Robert Schwebel <r.schwebel@pengutronix.de>")
	@$(call install_fixup, php5,DESCRIPTION,missing)

ifdef PTXCONF_PHP5_SAPI_APXS2
	@$(call install_copy, php5, 0, 0, 0644, -, \
		/usr/modules/libphp5.so)
endif

ifdef PTXCONF_PHP5_SAPI_CLI
	@$(call install_copy, php5, 0, 0, 0755, $(PHP5_PKGDIR)/usr/bin/php, \
		/usr/bin/php5)
endif

ifdef PTXCONF_PHP5_SAPI_CGI
	@$(call install_copy, php5, 0, 0, 0755, -, /usr/bin/php-cgi)
endif

ifdef PTXCONF_PHP5_INI
	@$(call install_alternative, php5, 0, 0, 0644, /etc/php5/php.ini)
endif

	@$(call install_finish, php5)

	@$(call touch)

# vim: syntax=make
