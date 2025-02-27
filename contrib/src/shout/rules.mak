# shout

SHOUT_VERSION := 2.4.6
SHOUT_URL := http://downloads.us.xiph.org/releases/libshout/libshout-$(SHOUT_VERSION).tar.gz

ifdef BUILD_ENCODERS
ifdef BUILD_NETWORK
PKGS += shout
endif
endif
ifeq ($(call need_pkg,"shout >= 2.4.3"),)
PKGS_FOUND += shout
endif

$(TARBALLS)/libshout-$(SHOUT_VERSION).tar.gz:
	$(call download_pkg,$(SHOUT_URL),shout)

.sum-shout: libshout-$(SHOUT_VERSION).tar.gz

# TODO: fix socket stuff on POSIX and Linux
libshout: libshout-$(SHOUT_VERSION).tar.gz .sum-shout
	$(UNPACK)
	$(APPLY) $(SRC)/shout/fix-xiph_openssl.patch
	$(APPLY) $(SRC)/shout/shout-strings.patch
	$(APPLY) $(SRC)/shout/shout-timeval.patch
	$(APPLY) $(SRC)/shout/shout-win32-socklen.patch
	$(APPLY) $(SRC)/shout/no-force-libwsock.patch
	$(APPLY) $(SRC)/shout/should-win32-ws2tcpip.patch
	$(APPLY) $(SRC)/shout/win32-gettimeofday.patch
	$(APPLY) $(SRC)/shout/add-missing-stdlib-stdio.patch
	$(call pkg_static,"shout.pc.in")
	$(UPDATE_AUTOCONFIG)
	$(MOVE)

DEPS_shout = ogg $(DEPS_ogg) theora $(DEPS_theora) speex $(DEPS_speex)
DEPS_shout += vorbis $(DEPS_vorbis)

SHOUT_CONF := --disable-examples --disable-tools --without-openssl

ifdef HAVE_WIN32
SHOUT_CONF += --disable-thread
endif
ifdef HAVE_ANDROID
SHOUT_CONF += --disable-thread
endif

.shout: libshout
	$(RECONF)
	$(MAKEBUILDDIR)
	$(MAKECONFIGURE) $(SHOUT_CONF)
	+$(MAKEBUILD)
	+$(MAKEBUILD) install
	touch $@
