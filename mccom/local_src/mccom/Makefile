
ifeq ($(PLATFORM),i586)
	PLATFORM_ARGS := -static-libgcc -static-libstdc++ $(TOOLCHAIN)/sysroot-i586-unknown-linux-gnu/usr/lib/libc.a
endif
ifeq ($(PLATFORM),iMX6)
	PLATFORM_ARGS := -static-libgcc -static-libstdc++
endif


all:
	$(CXX) -oMCCOM.O -I./include -std=c++14 -fPIC -shared -Os -Wl,--strip-all  mccom.cpp $(SYSROOT)/usr/lib/libboost_system.a $(PLATFORM_ARGS)

install:
