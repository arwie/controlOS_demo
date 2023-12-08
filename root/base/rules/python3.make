# -*-makefile-*-
#
# Copyright (C) 2009 by Marc Kleine-Budde <mkl@pengutronix.de>
#               2010 by Michael Olbrich <m.olbrich@pengutronix.de>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_PYTHON3) += python3

#
# Paths and names
#
PYTHON3_VERSION		:= 3.11.6
PYTHON3_MD5		:= d0c5a1a31efe879723e51addf56dd206
PYTHON3_MAJORMINOR	:= $(basename $(PYTHON3_VERSION))
PYTHON3_SITEPACKAGES	:= /usr/lib/python$(PYTHON3_MAJORMINOR)/site-packages
PYTHON3			:= Python-$(PYTHON3_VERSION)
PYTHON3_SUFFIX		:= tar.xz
PYTHON3_SOURCE		:= $(SRCDIR)/$(PYTHON3).$(PYTHON3_SUFFIX)
PYTHON3_DIR		:= $(BUILDDIR)/$(PYTHON3)
PYTHON3_DEVPKG		:= NO

PYTHON3_URL		:= \
	https://www.python.org/ftp/python/$(PYTHON3_VERSION)/$(PYTHON3).$(PYTHON3_SUFFIX) \
	http://python.org/ftp/python/$(PYTHON3_MAJORMINOR)/$(PYTHON3).$(PYTHON3_SUFFIX)

CROSS_PYTHON3		:= $(PTXDIST_SYSROOT_CROSS)/usr/bin/python$(PYTHON3_MAJORMINOR)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

# Note: the LDFLAGS are used by setup.py for manual searches
PYTHON3_CONF_ENV	:= \
	$(CROSS_ENV) \
	ac_sys_system=Linux \
	ac_sys_release=2 \
	MACHDEP=linux \
	ac_cv_have_chflags=no \
	ac_cv_have_lchflags=no \
	ac_cv_broken_sem_getvalue=no \
	ac_cv_file__dev_ptmx=no \
	ac_cv_file__dev_ptc=no \
	ac_cv_lib_bsd_flock=no \
	ac_cv_working_tzset=yes \
	ac_cv_header_bluetooth_bluetooth_h=no \
	LDFLAGS="-L$(PTXDIST_SYSROOT_TARGET)/usr/lib"

PYTHON3_BINCONFIG_GLOB := ""

#
# autoconf
#
PYTHON3_CONF_TOOL	:= autoconf
PYTHON3_CONF_OPT	:= \
	$(CROSS_AUTOCONF_USR) \
	--enable-shared \
	--disable-profiling \
	--disable-optimizations \
	--disable-loadable-sqlite-extensions \
	$(GLOBAL_IPV6_OPTION) \
	--without-pydebug \
	--without-assertions \
	--without-lto \
	--with-system-expat \
	--without-system-libmpdec \
	--with-dbmliborder=$(call ptx/ifdef, PTXCONF_PYTHON3_DB,bdb) \
	--without-doc-strings \
	--with-pymalloc \
	--with-c-locale-coercion \
	--without-valgrind \
	--without-dtrace \
	--with-computed-gotos \
	--without-ensurepip \
	--with-openssl=$(SYSROOT)/usr \
	--with-build-python=$(PTXDIST_SYSROOT_HOST)/usr/bin/python$(PYTHON3_MAJORMINOR)

# Keep dictionary order in .pyc files stable
PYTHON3_MAKE_ENV := \
	PYTHONHASHSEED=0

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

$(STATEDIR)/python3.install:
	@$(call targetinfo)

#	# remove unneeded stuff
	@find $(PYTHON3_DIR) \( -name test -o -name tests \) -print0 | xargs -0 rm -vrf

	@$(call world/install, PYTHON3)

#	# grab the host binary modules for cross-building
	@install -v -m644 -t \
		$(PYTHON3_PKGDIR)/usr/lib/python$(PYTHON3_MAJORMINOR)/lib-dynload/ \
		$(PTXDIST_SYSROOT_HOST)/usr/lib/python$(PYTHON3_MAJORMINOR)/lib-dynload/*-x86_64-host-gnu.so
	@chrpath -r '$${ORIGIN}/../../../../../sysroot-host/usr/lib' \
		$(PYTHON3_PKGDIR)/usr/lib/python$(PYTHON3_MAJORMINOR)/lib-dynload/*-x86_64-host-gnu.so

	@rm -vrf $(PYTHON3_PKGDIR)/usr/lib/python$(PYTHON3_MAJORMINOR)/config-$(PYTHON3_MAJORMINOR)*
	@$(call world/env, PYTHON3) ptxd_make_world_install_python_cleanup

	@$(call touch)

PYTHON3_PLATFORM := $(call remove_quotes,$(PTXCONF_ARCH_STRING))
ifdef PTXCONF_ARCH_ARM64
PYTHON3_PLATFORM := arm
endif

define PYTHON3_CROSS_PYTHON_DATA
#!/bin/sh
PYTHONEXECUTABLE=$(PTXDIST_SYSROOT_TARGET)/usr/bin/python$(PYTHON3_MAJORMINOR)
_PYTHON_HOST_PLATFORM=linux-$(PYTHON3_PLATFORM)
_PYTHON_SYSCONFIGDATA_NAME=_sysconfigdata__linux_@arch@
PYTHONPATH="$(PTXDIST_SYSROOT_HOST)/usr/lib/python$(PYTHON3_MAJORMINOR)/site-packages:$(PTXDIST_SYSROOT_HOST)/usr/lib/python3/site-packages"
PYTHONHASHSEED=0
export PYTHONEXECUTABLE  _PYTHON_HOST_PLATFORM
export _PYTHON_SYSCONFIGDATA_NAME PYTHONPATH
export PYTHONHASHSEED
exec $(HOSTPYTHON3) "$${@}"
endef

$(STATEDIR)/python3.install.post:
	@$(call targetinfo)
	@$(call world/install.post, PYTHON3)

	@$(file > $(PTXDIST_TEMPDIR)/cross-python,$(PYTHON3_CROSS_PYTHON_DATA))
	@rm -f "$(CROSS_PYTHON3)"
	@m=`sed -n 's/^MULTIARCH=[\t ]*\(.*\)/\1/p' $(PYTHON3_DIR)/Makefile` && \
	 sed -i "s;'\(/usr/include\);'$(PTXDIST_SYSROOT_TARGET)\1;g" \
		$(PTXDIST_SYSROOT_TARGET)/usr/lib/python$(PYTHON3_MAJORMINOR)/_sysconfigdata__linux_$$m.py && \
	 sed "s;@arch@;$$m;" $(PTXDIST_TEMPDIR)/cross-python > "$(CROSS_PYTHON3)"
	@chmod a+x "$(CROSS_PYTHON3)"
	@sed -e 's;prefix_real=.*;prefix_real=$(SYSROOT)/usr;' \
		"$(PTXDIST_SYSROOT_TARGET)/usr/bin/python$(PYTHON3_MAJORMINOR)-config" \
		> "$(PTXDIST_SYSROOT_CROSS)/usr/bin/python$(PYTHON3_MAJORMINOR)-config"
	@chmod +x "$(PTXDIST_SYSROOT_CROSS)/usr/bin/python$(PYTHON3_MAJORMINOR)-config"

#	# make sure executing $PYTHONEXECUTABLE works
	@ln -sf ../../../sysroot-cross/usr/bin/python$(PYTHON3_MAJORMINOR) \
		$(PTXDIST_SYSROOT_TARGET)/usr/bin/python$(PYTHON3_MAJORMINOR)

#	# make sure grammar pickle is generated to avoid parallel building issues
	@"$(CROSS_PYTHON3)" -c 'from setuptools.command import build_py'

	@$(call touch)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

# nis may add extra dependencies and is not useful for embedded
PYTHON3_SKIP-y							+= */nis.* */tkinter */idlelib

# These cannot be disabled during build, so just don't install the disabled modules
PYTHON3_SKIP-$(call ptx/opt-dis, PTXCONF_PYTHON3_BZ2)		+= */bz2.pyc */_bz2*.so
PYTHON3_SKIP-$(call ptx/opt-dis, PTXCONF_PYTHON3_LZMA)		+= */lzma.pyc */_lzma*.so
PYTHON3_SKIP-$(call ptx/opt-dis, PTXCONF_PYTHON3_NCURSES)	+= */curses */_curses*.so
PYTHON3_SKIP-$(call ptx/opt-dis, PTXCONF_PYTHON3_READLINE)	+= */readline*so
PYTHON3_SKIP-$(call ptx/opt-dis, PTXCONF_PYTHON3_SQLITE)	+= */sqlite3 */_sqlite3*.so
PYTHON3_SKIP-$(call ptx/opt-dis, PTXCONF_PYTHON3_SSL)		+= */ssl.pyc */_ssl*.so */hashlib.pyc */_hashlib*.so
PYTHON3_SKIP-$(call ptx/opt-dis, PTXCONF_PYTHON3_DISTUTILS)	+= */distutils

$(STATEDIR)/python3.targetinstall:
	@$(call targetinfo)

	@$(call install_init, python3)
	@$(call install_fixup, python3,PRIORITY,optional)
	@$(call install_fixup, python3,SECTION,base)
	@$(call install_fixup, python3,AUTHOR,"Marc Kleine-Budde <mkl@pengutronix.de>, Han Sierkstra <han@protonic.nl>")
	@$(call install_fixup, python3,DESCRIPTION,missing)

	@$(call install_glob, python3, 0, 0, -, /usr/lib/python$(PYTHON3_MAJORMINOR), \
		*.so *.pyc *.whl, *-x86_64-host-gnu.so */test */tests */__pycache__ $(PYTHON3_SKIP-y))

	@$(call install_copy, python3, 0, 0, 0755, -, /usr/bin/python$(PYTHON3_MAJORMINOR))
	@$(call install_link, python3, python$(PYTHON3_MAJORMINOR), /usr/bin/python3)
	@$(call install_lib, python3, 0, 0, 0644, libpython$(PYTHON3_MAJORMINOR))

	@$(call install_copy, python3, 0, 0, 0644, -, /usr/lib/python$(PYTHON3_MAJORMINOR)/venv/scripts/common/activate)

ifdef PTXCONF_PYTHON3_SYMLINK
	@$(call install_link, python3, python$(PYTHON3_MAJORMINOR), /usr/bin/python)
endif

	@$(call install_finish, python3)

	@$(call touch)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

$(STATEDIR)/python3.clean:
	@$(call targetinfo)
	@$(call clean_pkg, PYTHON3)
	@rm -vf \
		"$(CROSS_PYTHON3)" \
		"$(PTXDIST_SYSROOT_CROSS)/usr/bin/python3" \
		"$(PTXDIST_SYSROOT_CROSS)/usr/bin/python$(PYTHON3_MAJORMINOR)-config" \
		"$(PTXDIST_SYSROOT_CROSS)/usr/lib/python$(PYTHON3_MAJORMINOR)/"_sysconfigdata_m_linux_*.py

# vim: syntax=make
