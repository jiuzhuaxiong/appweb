#
#   appweb-macosx-default.mk -- Makefile to build Embedthis Appweb for macosx
#

NAME                  := appweb
VERSION               := 5.0.0-rc0
PROFILE               ?= default
ARCH                  ?= $(shell uname -m | sed 's/i.86/x86/;s/x86_64/x64/;s/arm.*/arm/;s/mips.*/mips/')
CC_ARCH               ?= $(shell echo $(ARCH) | sed 's/x86/i686/;s/x64/x86_64/')
OS                    ?= macosx
CC                    ?= clang
CONFIG                ?= $(OS)-$(ARCH)-$(PROFILE)
LBIN                  ?= $(CONFIG)/bin
PATH                  := $(LBIN):$(PATH)

ME_COM_CGI            ?= 1
ME_COM_DIR            ?= 1
ME_COM_EJS            ?= 0
ME_COM_ESP            ?= 1
ME_COM_EST            ?= 1
ME_COM_HTTP           ?= 1
ME_COM_MATRIXSSL      ?= 0
ME_COM_MDB            ?= 1
ME_COM_NANOSSL        ?= 0
ME_COM_OPENSSL        ?= 0
ME_COM_PCRE           ?= 1
ME_COM_PHP            ?= 0
ME_COM_SQLITE         ?= 0
ME_COM_SSL            ?= 1
ME_COM_VXWORKS        ?= 0
ME_COM_WINSDK         ?= 0
ME_COM_ZLIB           ?= 1

ifeq ($(ME_COM_EST),1)
    ME_COM_SSL := 1
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    ME_COM_SSL := 1
endif
ifeq ($(ME_COM_NANOSSL),1)
    ME_COM_SSL := 1
endif
ifeq ($(ME_COM_OPENSSL),1)
    ME_COM_SSL := 1
endif
ifeq ($(ME_COM_EJS),1)
    ME_COM_ZLIB := 1
endif
ifeq ($(ME_COM_ESP),1)
    ME_COM_MDB := 1
endif

ME_COM_CGI_PATH       ?= src/modules/cgiHandler.c
ME_COM_COMPILER_PATH  ?= clang
ME_COM_DIR_PATH       ?= src/dirHandler.c
ME_COM_EJS_PATH       ?= src/paks/ejs
ME_COM_ESP_PATH       ?= src/paks/esp
ME_COM_EST_PATH       ?= src/paks/est
ME_COM_HTTP_PATH      ?= src/paks/http
ME_COM_LIB_PATH       ?= ar
ME_COM_MATRIXSSL_PATH ?= /usr/src/matrixssl
ME_COM_MDB_PATH       ?= src/mdb.c
ME_COM_MPR_PATH       ?= src/paks/mpr
ME_COM_NANOSSL_PATH   ?= /usr/src/nanossl
ME_COM_OPENSSL_PATH   ?= [object Object]
ME_COM_OSDEP_PATH     ?= src/paks/osdep
ME_COM_PCRE_PATH      ?= src/paks/pcre
ME_COM_PHP_PATH       ?= /usr/src/php
ME_COM_SQLITE_PATH    ?= src/paks/sqlite
ME_COM_SSL_PATH       ?= src/paks/ssl
ME_COM_ZLIB_PATH      ?= src/paks/zlib

CFLAGS                += -w
DFLAGS                +=  $(patsubst %,-D%,$(filter ME_%,$(MAKEFLAGS))) -DME_COM_CGI=$(ME_COM_CGI) -DME_COM_DIR=$(ME_COM_DIR) -DME_COM_EJS=$(ME_COM_EJS) -DME_COM_ESP=$(ME_COM_ESP) -DME_COM_EST=$(ME_COM_EST) -DME_COM_HTTP=$(ME_COM_HTTP) -DME_COM_MATRIXSSL=$(ME_COM_MATRIXSSL) -DME_COM_MDB=$(ME_COM_MDB) -DME_COM_NANOSSL=$(ME_COM_NANOSSL) -DME_COM_OPENSSL=$(ME_COM_OPENSSL) -DME_COM_PCRE=$(ME_COM_PCRE) -DME_COM_PHP=$(ME_COM_PHP) -DME_COM_SQLITE=$(ME_COM_SQLITE) -DME_COM_SSL=$(ME_COM_SSL) -DME_COM_VXWORKS=$(ME_COM_VXWORKS) -DME_COM_WINSDK=$(ME_COM_WINSDK) -DME_COM_ZLIB=$(ME_COM_ZLIB) 
IFLAGS                += "-I$(CONFIG)/inc"
LDFLAGS               += '-Wl,-rpath,@executable_path/' '-Wl,-rpath,@loader_path/'
LIBPATHS              += -L$(CONFIG)/bin
LIBS                  += -ldl -lpthread -lm

DEBUG                 ?= debug
CFLAGS-debug          ?= -g
DFLAGS-debug          ?= -DME_DEBUG
LDFLAGS-debug         ?= -g
DFLAGS-release        ?= 
CFLAGS-release        ?= -O2
LDFLAGS-release       ?= 
CFLAGS                += $(CFLAGS-$(DEBUG))
DFLAGS                += $(DFLAGS-$(DEBUG))
LDFLAGS               += $(LDFLAGS-$(DEBUG))

ME_ROOT_PREFIX        ?= 
ME_BASE_PREFIX        ?= $(ME_ROOT_PREFIX)/usr/local
ME_DATA_PREFIX        ?= $(ME_ROOT_PREFIX)/
ME_STATE_PREFIX       ?= $(ME_ROOT_PREFIX)/var
ME_APP_PREFIX         ?= $(ME_BASE_PREFIX)/lib/$(NAME)
ME_VAPP_PREFIX        ?= $(ME_APP_PREFIX)/$(VERSION)
ME_BIN_PREFIX         ?= $(ME_ROOT_PREFIX)/usr/local/bin
ME_INC_PREFIX         ?= $(ME_ROOT_PREFIX)/usr/local/include
ME_LIB_PREFIX         ?= $(ME_ROOT_PREFIX)/usr/local/lib
ME_MAN_PREFIX         ?= $(ME_ROOT_PREFIX)/usr/local/share/man
ME_SBIN_PREFIX        ?= $(ME_ROOT_PREFIX)/usr/local/sbin
ME_ETC_PREFIX         ?= $(ME_ROOT_PREFIX)/etc/$(NAME)
ME_WEB_PREFIX         ?= $(ME_ROOT_PREFIX)/var/www/$(NAME)-default
ME_LOG_PREFIX         ?= $(ME_ROOT_PREFIX)/var/log/$(NAME)
ME_SPOOL_PREFIX       ?= $(ME_ROOT_PREFIX)/var/spool/$(NAME)
ME_CACHE_PREFIX       ?= $(ME_ROOT_PREFIX)/var/spool/$(NAME)/cache
ME_SRC_PREFIX         ?= $(ME_ROOT_PREFIX)$(NAME)-$(VERSION)


TARGETS               += $(CONFIG)/bin/appweb
TARGETS               += $(CONFIG)/bin/authpass
ifeq ($(ME_COM_EST),1)
    TARGETS           += $(CONFIG)/bin/ca.crt
endif
ifeq ($(ME_COM_CGI),1)
    TARGETS           += $(CONFIG)/bin/cgiProgram
endif
ifeq ($(ME_COM_EJS),1)
    TARGETS           += $(CONFIG)/bin/ejs.mod
endif
ifeq ($(ME_COM_EJS),1)
    TARGETS           += $(CONFIG)/bin/ejscmd
endif
ifeq ($(ME_COM_ESP),1)
    TARGETS           += $(CONFIG)/paks
endif
ifeq ($(ME_COM_ESP),1)
    TARGETS           += $(CONFIG)/bin/esp.conf
endif
ifeq ($(ME_COM_ESP),1)
    TARGETS           += $(CONFIG)/bin/esp
endif
ifeq ($(ME_COM_HTTP),1)
    TARGETS           += $(CONFIG)/bin/http
endif
ifeq ($(ME_COM_EST),1)
    TARGETS           += $(CONFIG)/bin/libest.dylib
endif
ifeq ($(ME_COM_CGI),1)
    TARGETS           += $(CONFIG)/bin/libmod_cgi.dylib
endif
ifeq ($(ME_COM_EJS),1)
    TARGETS           += $(CONFIG)/bin/libmod_ejs.dylib
endif
ifeq ($(ME_COM_PHP),1)
    TARGETS           += $(CONFIG)/bin/libmod_php.dylib
endif
ifeq ($(ME_COM_SSL),1)
    TARGETS           += $(CONFIG)/bin/libmod_ssl.dylib
endif
ifeq ($(ME_COM_SQLITE),1)
    TARGETS           += $(CONFIG)/bin/libsql.dylib
endif
TARGETS               += $(CONFIG)/bin/appman
TARGETS               += src/server/cache
ifeq ($(ME_COM_SQLITE),1)
    TARGETS           += $(CONFIG)/bin/sqlite
endif
ifeq ($(ME_COM_CGI),1)
    TARGETS           += test/web/auth/basic/basic.cgi
endif
ifeq ($(ME_COM_CGI),1)
    TARGETS           += test/web/caching/cache.cgi
endif
ifeq ($(ME_COM_CGI),1)
    TARGETS           += test/cgi-bin/cgiProgram
endif
ifeq ($(ME_COM_CGI),1)
    TARGETS           += test/cgi-bin/testScript
endif

unexport CDPATH

ifndef SHOW
.SILENT:
endif

all build compile: prep $(TARGETS)

.PHONY: prep

prep:
	@echo "      [Info] Use "make SHOW=1" to trace executed commands."
	@if [ "$(CONFIG)" = "" ] ; then echo WARNING: CONFIG not set ; exit 255 ; fi
	@if [ "$(ME_APP_PREFIX)" = "" ] ; then echo WARNING: ME_APP_PREFIX not set ; exit 255 ; fi
	@[ ! -x $(CONFIG)/bin ] && mkdir -p $(CONFIG)/bin; true
	@[ ! -x $(CONFIG)/inc ] && mkdir -p $(CONFIG)/inc; true
	@[ ! -x $(CONFIG)/obj ] && mkdir -p $(CONFIG)/obj; true
	@[ ! -f $(CONFIG)/inc/osdep.h ] && cp src/paks/osdep/osdep.h $(CONFIG)/inc/osdep.h ; true
	@if ! diff $(CONFIG)/inc/osdep.h src/paks/osdep/osdep.h >/dev/null ; then\
		cp src/paks/osdep/osdep.h $(CONFIG)/inc/osdep.h  ; \
	fi; true
	@[ ! -f $(CONFIG)/inc/me.h ] && cp projects/appweb-macosx-default-me.h $(CONFIG)/inc/me.h ; true
	@if ! diff $(CONFIG)/inc/me.h projects/appweb-macosx-default-me.h >/dev/null ; then\
		cp projects/appweb-macosx-default-me.h $(CONFIG)/inc/me.h  ; \
	fi; true
	@if [ -f "$(CONFIG)/.makeflags" ] ; then \
		if [ "$(MAKEFLAGS)" != " ` cat $(CONFIG)/.makeflags`" ] ; then \
			echo "   [Warning] Make flags have changed since the last build: "`cat $(CONFIG)/.makeflags`"" ; \
		fi ; \
	fi
	@echo $(MAKEFLAGS) >$(CONFIG)/.makeflags

clean:
	rm -f "$(CONFIG)/obj/appweb.o"
	rm -f "$(CONFIG)/obj/authpass.o"
	rm -f "$(CONFIG)/obj/cgiHandler.o"
	rm -f "$(CONFIG)/obj/cgiProgram.o"
	rm -f "$(CONFIG)/obj/config.o"
	rm -f "$(CONFIG)/obj/convenience.o"
	rm -f "$(CONFIG)/obj/dirHandler.o"
	rm -f "$(CONFIG)/obj/ejs.o"
	rm -f "$(CONFIG)/obj/ejsHandler.o"
	rm -f "$(CONFIG)/obj/ejsLib.o"
	rm -f "$(CONFIG)/obj/ejsc.o"
	rm -f "$(CONFIG)/obj/esp.o"
	rm -f "$(CONFIG)/obj/espLib.o"
	rm -f "$(CONFIG)/obj/estLib.o"
	rm -f "$(CONFIG)/obj/fileHandler.o"
	rm -f "$(CONFIG)/obj/http.o"
	rm -f "$(CONFIG)/obj/httpLib.o"
	rm -f "$(CONFIG)/obj/log.o"
	rm -f "$(CONFIG)/obj/makerom.o"
	rm -f "$(CONFIG)/obj/manager.o"
	rm -f "$(CONFIG)/obj/mprLib.o"
	rm -f "$(CONFIG)/obj/mprSsl.o"
	rm -f "$(CONFIG)/obj/pcre.o"
	rm -f "$(CONFIG)/obj/phpHandler.o"
	rm -f "$(CONFIG)/obj/server.o"
	rm -f "$(CONFIG)/obj/slink.o"
	rm -f "$(CONFIG)/obj/sqlite.o"
	rm -f "$(CONFIG)/obj/sqlite3.o"
	rm -f "$(CONFIG)/obj/sslModule.o"
	rm -f "$(CONFIG)/obj/testAppweb.o"
	rm -f "$(CONFIG)/obj/testHttp.o"
	rm -f "$(CONFIG)/obj/zlib.o"
	rm -f "$(CONFIG)/bin/appweb"
	rm -f "$(CONFIG)/bin/authpass"
	rm -f "$(CONFIG)/bin/ca.crt"
	rm -f "$(CONFIG)/bin/cgiProgram"
	rm -f "$(CONFIG)/bin/ejsc"
	rm -f "$(CONFIG)/bin/ejscmd"
	rm -f "$(CONFIG)/bin/esp.conf"
	rm -f "$(CONFIG)/bin/esp"
	rm -f "$(CONFIG)/bin/http"
	rm -f "$(CONFIG)/bin/libappweb.dylib"
	rm -f "$(CONFIG)/bin/libejs.dylib"
	rm -f "$(CONFIG)/bin/libest.dylib"
	rm -f "$(CONFIG)/bin/libhttp.dylib"
	rm -f "$(CONFIG)/bin/libmod_cgi.dylib"
	rm -f "$(CONFIG)/bin/libmod_ejs.dylib"
	rm -f "$(CONFIG)/bin/libmod_esp.dylib"
	rm -f "$(CONFIG)/bin/libmod_php.dylib"
	rm -f "$(CONFIG)/bin/libmod_ssl.dylib"
	rm -f "$(CONFIG)/bin/libmpr.dylib"
	rm -f "$(CONFIG)/bin/libmprssl.dylib"
	rm -f "$(CONFIG)/bin/libpcre.dylib"
	rm -f "$(CONFIG)/bin/libslink.dylib"
	rm -f "$(CONFIG)/bin/libsql.dylib"
	rm -f "$(CONFIG)/bin/libzlib.dylib"
	rm -f "$(CONFIG)/bin/makerom"
	rm -f "$(CONFIG)/bin/appman"
	rm -f "$(CONFIG)/bin/sqlite"
	rm -f "$(CONFIG)/bin/testAppweb"

clobber: clean
	rm -fr ./$(CONFIG)


#
#   mpr.h
#
$(CONFIG)/inc/mpr.h: $(DEPS_1)
	@echo '      [Copy] $(CONFIG)/inc/mpr.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/mpr/mpr.h $(CONFIG)/inc/mpr.h

#
#   me.h
#
$(CONFIG)/inc/me.h: $(DEPS_2)
	@echo '      [Copy] $(CONFIG)/inc/me.h'

#
#   osdep.h
#
$(CONFIG)/inc/osdep.h: $(DEPS_3)
	@echo '      [Copy] $(CONFIG)/inc/osdep.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/osdep/osdep.h $(CONFIG)/inc/osdep.h

#
#   mprLib.o
#
DEPS_4 += $(CONFIG)/inc/me.h
DEPS_4 += $(CONFIG)/inc/mpr.h
DEPS_4 += $(CONFIG)/inc/osdep.h

$(CONFIG)/obj/mprLib.o: \
    src/paks/mpr/mprLib.c $(DEPS_4)
	@echo '   [Compile] $(CONFIG)/obj/mprLib.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/mprLib.o -arch $(CC_ARCH) $(IFLAGS) src/paks/mpr/mprLib.c

#
#   libmpr
#
DEPS_5 += $(CONFIG)/inc/mpr.h
DEPS_5 += $(CONFIG)/inc/me.h
DEPS_5 += $(CONFIG)/inc/osdep.h
DEPS_5 += $(CONFIG)/obj/mprLib.o

$(CONFIG)/bin/libmpr.dylib: $(DEPS_5)
	@echo '      [Link] $(CONFIG)/bin/libmpr.dylib'
	$(CC) -dynamiclib -o $(CONFIG)/bin/libmpr.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libmpr.dylib -compatibility_version 5.0.0 -current_version 5.0.0 "$(CONFIG)/obj/mprLib.o" $(LIBS) 

#
#   pcre.h
#
$(CONFIG)/inc/pcre.h: $(DEPS_6)
	@echo '      [Copy] $(CONFIG)/inc/pcre.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/pcre/pcre.h $(CONFIG)/inc/pcre.h

#
#   pcre.o
#
DEPS_7 += $(CONFIG)/inc/me.h
DEPS_7 += $(CONFIG)/inc/pcre.h

$(CONFIG)/obj/pcre.o: \
    src/paks/pcre/pcre.c $(DEPS_7)
	@echo '   [Compile] $(CONFIG)/obj/pcre.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/pcre.o -arch $(CC_ARCH) $(IFLAGS) src/paks/pcre/pcre.c

ifeq ($(ME_COM_PCRE),1)
#
#   libpcre
#
DEPS_8 += $(CONFIG)/inc/pcre.h
DEPS_8 += $(CONFIG)/inc/me.h
DEPS_8 += $(CONFIG)/obj/pcre.o

$(CONFIG)/bin/libpcre.dylib: $(DEPS_8)
	@echo '      [Link] $(CONFIG)/bin/libpcre.dylib'
	$(CC) -dynamiclib -o $(CONFIG)/bin/libpcre.dylib -arch $(CC_ARCH) $(LDFLAGS) -compatibility_version 5.0.0 -current_version 5.0.0 $(LIBPATHS) -install_name @rpath/libpcre.dylib -compatibility_version 5.0.0 -current_version 5.0.0 "$(CONFIG)/obj/pcre.o" $(LIBS) 
endif

#
#   http.h
#
$(CONFIG)/inc/http.h: $(DEPS_9)
	@echo '      [Copy] $(CONFIG)/inc/http.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/http/http.h $(CONFIG)/inc/http.h

#
#   httpLib.o
#
DEPS_10 += $(CONFIG)/inc/me.h
DEPS_10 += $(CONFIG)/inc/http.h
DEPS_10 += $(CONFIG)/inc/mpr.h

$(CONFIG)/obj/httpLib.o: \
    src/paks/http/httpLib.c $(DEPS_10)
	@echo '   [Compile] $(CONFIG)/obj/httpLib.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/httpLib.o -arch $(CC_ARCH) $(IFLAGS) src/paks/http/httpLib.c

ifeq ($(ME_COM_HTTP),1)
#
#   libhttp
#
DEPS_11 += $(CONFIG)/inc/mpr.h
DEPS_11 += $(CONFIG)/inc/me.h
DEPS_11 += $(CONFIG)/inc/osdep.h
DEPS_11 += $(CONFIG)/obj/mprLib.o
DEPS_11 += $(CONFIG)/bin/libmpr.dylib
DEPS_11 += $(CONFIG)/inc/pcre.h
DEPS_11 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_11 += $(CONFIG)/bin/libpcre.dylib
endif
DEPS_11 += $(CONFIG)/inc/http.h
DEPS_11 += $(CONFIG)/obj/httpLib.o

LIBS_11 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_11 += -lpcre
endif

$(CONFIG)/bin/libhttp.dylib: $(DEPS_11)
	@echo '      [Link] $(CONFIG)/bin/libhttp.dylib'
	$(CC) -dynamiclib -o $(CONFIG)/bin/libhttp.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libhttp.dylib -compatibility_version 5.0.0 -current_version 5.0.0 "$(CONFIG)/obj/httpLib.o" $(LIBPATHS_11) $(LIBS_11) $(LIBS_11) $(LIBS) -lpam 
endif

#
#   appweb.h
#
$(CONFIG)/inc/appweb.h: $(DEPS_12)
	@echo '      [Copy] $(CONFIG)/inc/appweb.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/appweb.h $(CONFIG)/inc/appweb.h

#
#   customize.h
#
$(CONFIG)/inc/customize.h: $(DEPS_13)
	@echo '      [Copy] $(CONFIG)/inc/customize.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/customize.h $(CONFIG)/inc/customize.h

#
#   config.o
#
DEPS_14 += $(CONFIG)/inc/me.h
DEPS_14 += $(CONFIG)/inc/appweb.h
DEPS_14 += $(CONFIG)/inc/pcre.h
DEPS_14 += $(CONFIG)/inc/mpr.h
DEPS_14 += $(CONFIG)/inc/http.h
DEPS_14 += $(CONFIG)/inc/customize.h

$(CONFIG)/obj/config.o: \
    src/config.c $(DEPS_14)
	@echo '   [Compile] $(CONFIG)/obj/config.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/config.o -arch $(CC_ARCH) $(IFLAGS) src/config.c

#
#   convenience.o
#
DEPS_15 += $(CONFIG)/inc/me.h
DEPS_15 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/convenience.o: \
    src/convenience.c $(DEPS_15)
	@echo '   [Compile] $(CONFIG)/obj/convenience.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/convenience.o -arch $(CC_ARCH) $(IFLAGS) src/convenience.c

#
#   dirHandler.o
#
DEPS_16 += $(CONFIG)/inc/me.h
DEPS_16 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/dirHandler.o: \
    src/dirHandler.c $(DEPS_16)
	@echo '   [Compile] $(CONFIG)/obj/dirHandler.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/dirHandler.o -arch $(CC_ARCH) $(IFLAGS) src/dirHandler.c

#
#   fileHandler.o
#
DEPS_17 += $(CONFIG)/inc/me.h
DEPS_17 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/fileHandler.o: \
    src/fileHandler.c $(DEPS_17)
	@echo '   [Compile] $(CONFIG)/obj/fileHandler.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/fileHandler.o -arch $(CC_ARCH) $(IFLAGS) src/fileHandler.c

#
#   log.o
#
DEPS_18 += $(CONFIG)/inc/me.h
DEPS_18 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/log.o: \
    src/log.c $(DEPS_18)
	@echo '   [Compile] $(CONFIG)/obj/log.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/log.o -arch $(CC_ARCH) $(IFLAGS) src/log.c

#
#   server.o
#
DEPS_19 += $(CONFIG)/inc/me.h
DEPS_19 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/server.o: \
    src/server.c $(DEPS_19)
	@echo '   [Compile] $(CONFIG)/obj/server.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/server.o -arch $(CC_ARCH) $(IFLAGS) src/server.c

#
#   libappweb
#
DEPS_20 += $(CONFIG)/inc/mpr.h
DEPS_20 += $(CONFIG)/inc/me.h
DEPS_20 += $(CONFIG)/inc/osdep.h
DEPS_20 += $(CONFIG)/obj/mprLib.o
DEPS_20 += $(CONFIG)/bin/libmpr.dylib
DEPS_20 += $(CONFIG)/inc/pcre.h
DEPS_20 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_20 += $(CONFIG)/bin/libpcre.dylib
endif
DEPS_20 += $(CONFIG)/inc/http.h
DEPS_20 += $(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_20 += $(CONFIG)/bin/libhttp.dylib
endif
DEPS_20 += $(CONFIG)/inc/appweb.h
DEPS_20 += $(CONFIG)/inc/customize.h
DEPS_20 += $(CONFIG)/obj/config.o
DEPS_20 += $(CONFIG)/obj/convenience.o
DEPS_20 += $(CONFIG)/obj/dirHandler.o
DEPS_20 += $(CONFIG)/obj/fileHandler.o
DEPS_20 += $(CONFIG)/obj/log.o
DEPS_20 += $(CONFIG)/obj/server.o

ifeq ($(ME_COM_HTTP),1)
    LIBS_20 += -lhttp
endif
LIBS_20 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_20 += -lpcre
endif

$(CONFIG)/bin/libappweb.dylib: $(DEPS_20)
	@echo '      [Link] $(CONFIG)/bin/libappweb.dylib'
	$(CC) -dynamiclib -o $(CONFIG)/bin/libappweb.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libappweb.dylib -compatibility_version 5.0.0 -current_version 5.0.0 "$(CONFIG)/obj/config.o" "$(CONFIG)/obj/convenience.o" "$(CONFIG)/obj/dirHandler.o" "$(CONFIG)/obj/fileHandler.o" "$(CONFIG)/obj/log.o" "$(CONFIG)/obj/server.o" $(LIBPATHS_20) $(LIBS_20) $(LIBS_20) $(LIBS) -lpam 

#
#   slink.c
#
src/slink.c: $(DEPS_21)
	( \
	cd src; \
	[ ! -f slink.c ] && cp slink.empty slink.c ; true ; \
	)

#
#   esp.h
#
$(CONFIG)/inc/esp.h: $(DEPS_22)
	@echo '      [Copy] $(CONFIG)/inc/esp.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/esp/esp.h $(CONFIG)/inc/esp.h

#
#   slink.o
#
DEPS_23 += $(CONFIG)/inc/me.h
DEPS_23 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/slink.o: \
    src/slink.c $(DEPS_23)
	@echo '   [Compile] $(CONFIG)/obj/slink.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/slink.o -arch $(CC_ARCH) $(IFLAGS) src/slink.c

#
#   libslink
#
DEPS_24 += src/slink.c
DEPS_24 += $(CONFIG)/inc/me.h
DEPS_24 += $(CONFIG)/inc/esp.h
DEPS_24 += $(CONFIG)/obj/slink.o

$(CONFIG)/bin/libslink.dylib: $(DEPS_24)
	@echo '      [Link] $(CONFIG)/bin/libslink.dylib'
	$(CC) -dynamiclib -o $(CONFIG)/bin/libslink.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libslink.dylib -compatibility_version 5.0.0 -current_version 5.0.0 "$(CONFIG)/obj/slink.o" $(LIBS) 

#
#   appweb.o
#
DEPS_25 += $(CONFIG)/inc/me.h
DEPS_25 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/appweb.o: \
    src/server/appweb.c $(DEPS_25)
	@echo '   [Compile] $(CONFIG)/obj/appweb.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/appweb.o -arch $(CC_ARCH) $(IFLAGS) src/server/appweb.c

#
#   appweb
#
DEPS_26 += $(CONFIG)/inc/mpr.h
DEPS_26 += $(CONFIG)/inc/me.h
DEPS_26 += $(CONFIG)/inc/osdep.h
DEPS_26 += $(CONFIG)/obj/mprLib.o
DEPS_26 += $(CONFIG)/bin/libmpr.dylib
DEPS_26 += $(CONFIG)/inc/pcre.h
DEPS_26 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_26 += $(CONFIG)/bin/libpcre.dylib
endif
DEPS_26 += $(CONFIG)/inc/http.h
DEPS_26 += $(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_26 += $(CONFIG)/bin/libhttp.dylib
endif
DEPS_26 += $(CONFIG)/inc/appweb.h
DEPS_26 += $(CONFIG)/inc/customize.h
DEPS_26 += $(CONFIG)/obj/config.o
DEPS_26 += $(CONFIG)/obj/convenience.o
DEPS_26 += $(CONFIG)/obj/dirHandler.o
DEPS_26 += $(CONFIG)/obj/fileHandler.o
DEPS_26 += $(CONFIG)/obj/log.o
DEPS_26 += $(CONFIG)/obj/server.o
DEPS_26 += $(CONFIG)/bin/libappweb.dylib
DEPS_26 += src/slink.c
DEPS_26 += $(CONFIG)/inc/esp.h
DEPS_26 += $(CONFIG)/obj/slink.o
DEPS_26 += $(CONFIG)/bin/libslink.dylib
DEPS_26 += $(CONFIG)/obj/appweb.o

LIBS_26 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_26 += -lhttp
endif
LIBS_26 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_26 += -lpcre
endif
LIBS_26 += -lslink

$(CONFIG)/bin/appweb: $(DEPS_26)
	@echo '      [Link] $(CONFIG)/bin/appweb'
	$(CC) -o $(CONFIG)/bin/appweb -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/appweb.o" $(LIBPATHS_26) $(LIBS_26) $(LIBS_26) $(LIBS) -lpam 

#
#   authpass.o
#
DEPS_27 += $(CONFIG)/inc/me.h
DEPS_27 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/authpass.o: \
    src/utils/authpass.c $(DEPS_27)
	@echo '   [Compile] $(CONFIG)/obj/authpass.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/authpass.o -arch $(CC_ARCH) $(IFLAGS) src/utils/authpass.c

#
#   authpass
#
DEPS_28 += $(CONFIG)/inc/mpr.h
DEPS_28 += $(CONFIG)/inc/me.h
DEPS_28 += $(CONFIG)/inc/osdep.h
DEPS_28 += $(CONFIG)/obj/mprLib.o
DEPS_28 += $(CONFIG)/bin/libmpr.dylib
DEPS_28 += $(CONFIG)/inc/pcre.h
DEPS_28 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_28 += $(CONFIG)/bin/libpcre.dylib
endif
DEPS_28 += $(CONFIG)/inc/http.h
DEPS_28 += $(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_28 += $(CONFIG)/bin/libhttp.dylib
endif
DEPS_28 += $(CONFIG)/inc/appweb.h
DEPS_28 += $(CONFIG)/inc/customize.h
DEPS_28 += $(CONFIG)/obj/config.o
DEPS_28 += $(CONFIG)/obj/convenience.o
DEPS_28 += $(CONFIG)/obj/dirHandler.o
DEPS_28 += $(CONFIG)/obj/fileHandler.o
DEPS_28 += $(CONFIG)/obj/log.o
DEPS_28 += $(CONFIG)/obj/server.o
DEPS_28 += $(CONFIG)/bin/libappweb.dylib
DEPS_28 += $(CONFIG)/obj/authpass.o

LIBS_28 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_28 += -lhttp
endif
LIBS_28 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_28 += -lpcre
endif

$(CONFIG)/bin/authpass: $(DEPS_28)
	@echo '      [Link] $(CONFIG)/bin/authpass'
	$(CC) -o $(CONFIG)/bin/authpass -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/authpass.o" $(LIBPATHS_28) $(LIBS_28) $(LIBS_28) $(LIBS) -lpam 

ifeq ($(ME_COM_EST),1)
#
#   ca-crt
#
DEPS_29 += src/paks/est/ca.crt

$(CONFIG)/bin/ca.crt: $(DEPS_29)
	@echo '      [Copy] $(CONFIG)/bin/ca.crt'
	mkdir -p "$(CONFIG)/bin"
	cp src/paks/est/ca.crt $(CONFIG)/bin/ca.crt
endif

#
#   cgiProgram.o
#
DEPS_30 += $(CONFIG)/inc/me.h

$(CONFIG)/obj/cgiProgram.o: \
    src/utils/cgiProgram.c $(DEPS_30)
	@echo '   [Compile] $(CONFIG)/obj/cgiProgram.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/cgiProgram.o -arch $(CC_ARCH) $(IFLAGS) src/utils/cgiProgram.c

ifeq ($(ME_COM_CGI),1)
#
#   cgiProgram
#
DEPS_31 += $(CONFIG)/inc/me.h
DEPS_31 += $(CONFIG)/obj/cgiProgram.o

$(CONFIG)/bin/cgiProgram: $(DEPS_31)
	@echo '      [Link] $(CONFIG)/bin/cgiProgram'
	$(CC) -o $(CONFIG)/bin/cgiProgram -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/cgiProgram.o" $(LIBS) 
endif

#
#   zlib.h
#
$(CONFIG)/inc/zlib.h: $(DEPS_32)
	@echo '      [Copy] $(CONFIG)/inc/zlib.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/zlib/zlib.h $(CONFIG)/inc/zlib.h

#
#   zlib.o
#
DEPS_33 += $(CONFIG)/inc/me.h
DEPS_33 += $(CONFIG)/inc/zlib.h

$(CONFIG)/obj/zlib.o: \
    src/paks/zlib/zlib.c $(DEPS_33)
	@echo '   [Compile] $(CONFIG)/obj/zlib.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/zlib.o -arch $(CC_ARCH) $(IFLAGS) src/paks/zlib/zlib.c

ifeq ($(ME_COM_ZLIB),1)
#
#   libzlib
#
DEPS_34 += $(CONFIG)/inc/zlib.h
DEPS_34 += $(CONFIG)/inc/me.h
DEPS_34 += $(CONFIG)/obj/zlib.o

$(CONFIG)/bin/libzlib.dylib: $(DEPS_34)
	@echo '      [Link] $(CONFIG)/bin/libzlib.dylib'
	$(CC) -dynamiclib -o $(CONFIG)/bin/libzlib.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libzlib.dylib -compatibility_version 5.0.0 -current_version 5.0.0 "$(CONFIG)/obj/zlib.o" $(LIBS) 
endif

#
#   ejs.h
#
$(CONFIG)/inc/ejs.h: $(DEPS_35)
	@echo '      [Copy] $(CONFIG)/inc/ejs.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/ejs/ejs.h $(CONFIG)/inc/ejs.h

#
#   ejs.slots.h
#
$(CONFIG)/inc/ejs.slots.h: $(DEPS_36)
	@echo '      [Copy] $(CONFIG)/inc/ejs.slots.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/ejs/ejs.slots.h $(CONFIG)/inc/ejs.slots.h

#
#   ejsByteGoto.h
#
$(CONFIG)/inc/ejsByteGoto.h: $(DEPS_37)
	@echo '      [Copy] $(CONFIG)/inc/ejsByteGoto.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/ejs/ejsByteGoto.h $(CONFIG)/inc/ejsByteGoto.h

#
#   ejsLib.o
#
DEPS_38 += $(CONFIG)/inc/me.h
DEPS_38 += $(CONFIG)/inc/ejs.h
DEPS_38 += $(CONFIG)/inc/mpr.h
DEPS_38 += $(CONFIG)/inc/pcre.h
DEPS_38 += $(CONFIG)/inc/osdep.h
DEPS_38 += $(CONFIG)/inc/http.h
DEPS_38 += $(CONFIG)/inc/ejs.slots.h
DEPS_38 += $(CONFIG)/inc/zlib.h

$(CONFIG)/obj/ejsLib.o: \
    src/paks/ejs/ejsLib.c $(DEPS_38)
	@echo '   [Compile] $(CONFIG)/obj/ejsLib.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/ejsLib.o -arch $(CC_ARCH) $(IFLAGS) src/paks/ejs/ejsLib.c

ifeq ($(ME_COM_EJS),1)
#
#   libejs
#
DEPS_39 += $(CONFIG)/inc/mpr.h
DEPS_39 += $(CONFIG)/inc/me.h
DEPS_39 += $(CONFIG)/inc/osdep.h
DEPS_39 += $(CONFIG)/obj/mprLib.o
DEPS_39 += $(CONFIG)/bin/libmpr.dylib
DEPS_39 += $(CONFIG)/inc/pcre.h
DEPS_39 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_39 += $(CONFIG)/bin/libpcre.dylib
endif
DEPS_39 += $(CONFIG)/inc/http.h
DEPS_39 += $(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_39 += $(CONFIG)/bin/libhttp.dylib
endif
DEPS_39 += $(CONFIG)/inc/zlib.h
DEPS_39 += $(CONFIG)/obj/zlib.o
ifeq ($(ME_COM_ZLIB),1)
    DEPS_39 += $(CONFIG)/bin/libzlib.dylib
endif
DEPS_39 += $(CONFIG)/inc/ejs.h
DEPS_39 += $(CONFIG)/inc/ejs.slots.h
DEPS_39 += $(CONFIG)/inc/ejsByteGoto.h
DEPS_39 += $(CONFIG)/obj/ejsLib.o

ifeq ($(ME_COM_HTTP),1)
    LIBS_39 += -lhttp
endif
LIBS_39 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_39 += -lpcre
endif
ifeq ($(ME_COM_ZLIB),1)
    LIBS_39 += -lzlib
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_39 += -lsql
endif

$(CONFIG)/bin/libejs.dylib: $(DEPS_39)
	@echo '      [Link] $(CONFIG)/bin/libejs.dylib'
	$(CC) -dynamiclib -o $(CONFIG)/bin/libejs.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libejs.dylib -compatibility_version 5.0.0 -current_version 5.0.0 "$(CONFIG)/obj/ejsLib.o" $(LIBPATHS_39) $(LIBS_39) $(LIBS_39) $(LIBS) -lpam 
endif

#
#   ejsc.o
#
DEPS_40 += $(CONFIG)/inc/me.h
DEPS_40 += $(CONFIG)/inc/ejs.h

$(CONFIG)/obj/ejsc.o: \
    src/paks/ejs/ejsc.c $(DEPS_40)
	@echo '   [Compile] $(CONFIG)/obj/ejsc.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/ejsc.o -arch $(CC_ARCH) $(IFLAGS) src/paks/ejs/ejsc.c

ifeq ($(ME_COM_EJS),1)
#
#   ejsc
#
DEPS_41 += $(CONFIG)/inc/mpr.h
DEPS_41 += $(CONFIG)/inc/me.h
DEPS_41 += $(CONFIG)/inc/osdep.h
DEPS_41 += $(CONFIG)/obj/mprLib.o
DEPS_41 += $(CONFIG)/bin/libmpr.dylib
DEPS_41 += $(CONFIG)/inc/pcre.h
DEPS_41 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_41 += $(CONFIG)/bin/libpcre.dylib
endif
DEPS_41 += $(CONFIG)/inc/http.h
DEPS_41 += $(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_41 += $(CONFIG)/bin/libhttp.dylib
endif
DEPS_41 += $(CONFIG)/inc/zlib.h
DEPS_41 += $(CONFIG)/obj/zlib.o
ifeq ($(ME_COM_ZLIB),1)
    DEPS_41 += $(CONFIG)/bin/libzlib.dylib
endif
DEPS_41 += $(CONFIG)/inc/ejs.h
DEPS_41 += $(CONFIG)/inc/ejs.slots.h
DEPS_41 += $(CONFIG)/inc/ejsByteGoto.h
DEPS_41 += $(CONFIG)/obj/ejsLib.o
DEPS_41 += $(CONFIG)/bin/libejs.dylib
DEPS_41 += $(CONFIG)/obj/ejsc.o

LIBS_41 += -lejs
ifeq ($(ME_COM_HTTP),1)
    LIBS_41 += -lhttp
endif
LIBS_41 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_41 += -lpcre
endif
ifeq ($(ME_COM_ZLIB),1)
    LIBS_41 += -lzlib
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_41 += -lsql
endif

$(CONFIG)/bin/ejsc: $(DEPS_41)
	@echo '      [Link] $(CONFIG)/bin/ejsc'
	$(CC) -o $(CONFIG)/bin/ejsc -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/ejsc.o" $(LIBPATHS_41) $(LIBS_41) $(LIBS_41) $(LIBS) -lpam 
endif

ifeq ($(ME_COM_EJS),1)
#
#   ejs.mod
#
DEPS_42 += src/paks/ejs/ejs.es
DEPS_42 += $(CONFIG)/inc/mpr.h
DEPS_42 += $(CONFIG)/inc/me.h
DEPS_42 += $(CONFIG)/inc/osdep.h
DEPS_42 += $(CONFIG)/obj/mprLib.o
DEPS_42 += $(CONFIG)/bin/libmpr.dylib
DEPS_42 += $(CONFIG)/inc/pcre.h
DEPS_42 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_42 += $(CONFIG)/bin/libpcre.dylib
endif
DEPS_42 += $(CONFIG)/inc/http.h
DEPS_42 += $(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_42 += $(CONFIG)/bin/libhttp.dylib
endif
DEPS_42 += $(CONFIG)/inc/zlib.h
DEPS_42 += $(CONFIG)/obj/zlib.o
ifeq ($(ME_COM_ZLIB),1)
    DEPS_42 += $(CONFIG)/bin/libzlib.dylib
endif
DEPS_42 += $(CONFIG)/inc/ejs.h
DEPS_42 += $(CONFIG)/inc/ejs.slots.h
DEPS_42 += $(CONFIG)/inc/ejsByteGoto.h
DEPS_42 += $(CONFIG)/obj/ejsLib.o
DEPS_42 += $(CONFIG)/bin/libejs.dylib
DEPS_42 += $(CONFIG)/obj/ejsc.o
DEPS_42 += $(CONFIG)/bin/ejsc

$(CONFIG)/bin/ejs.mod: $(DEPS_42)
	( \
	cd src/paks/ejs; \
	../../../$(CONFIG)/bin/ejsc --out ../../../$(CONFIG)/bin/ejs.mod --optimize 9 --bind --require null ejs.es ; \
	)
endif

#
#   ejs.o
#
DEPS_43 += $(CONFIG)/inc/me.h
DEPS_43 += $(CONFIG)/inc/ejs.h

$(CONFIG)/obj/ejs.o: \
    src/paks/ejs/ejs.c $(DEPS_43)
	@echo '   [Compile] $(CONFIG)/obj/ejs.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/ejs.o -arch $(CC_ARCH) $(IFLAGS) src/paks/ejs/ejs.c

ifeq ($(ME_COM_EJS),1)
#
#   ejscmd
#
DEPS_44 += $(CONFIG)/inc/mpr.h
DEPS_44 += $(CONFIG)/inc/me.h
DEPS_44 += $(CONFIG)/inc/osdep.h
DEPS_44 += $(CONFIG)/obj/mprLib.o
DEPS_44 += $(CONFIG)/bin/libmpr.dylib
DEPS_44 += $(CONFIG)/inc/pcre.h
DEPS_44 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_44 += $(CONFIG)/bin/libpcre.dylib
endif
DEPS_44 += $(CONFIG)/inc/http.h
DEPS_44 += $(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_44 += $(CONFIG)/bin/libhttp.dylib
endif
DEPS_44 += $(CONFIG)/inc/zlib.h
DEPS_44 += $(CONFIG)/obj/zlib.o
ifeq ($(ME_COM_ZLIB),1)
    DEPS_44 += $(CONFIG)/bin/libzlib.dylib
endif
DEPS_44 += $(CONFIG)/inc/ejs.h
DEPS_44 += $(CONFIG)/inc/ejs.slots.h
DEPS_44 += $(CONFIG)/inc/ejsByteGoto.h
DEPS_44 += $(CONFIG)/obj/ejsLib.o
DEPS_44 += $(CONFIG)/bin/libejs.dylib
DEPS_44 += $(CONFIG)/obj/ejs.o

LIBS_44 += -lejs
ifeq ($(ME_COM_HTTP),1)
    LIBS_44 += -lhttp
endif
LIBS_44 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_44 += -lpcre
endif
ifeq ($(ME_COM_ZLIB),1)
    LIBS_44 += -lzlib
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_44 += -lsql
endif

$(CONFIG)/bin/ejscmd: $(DEPS_44)
	@echo '      [Link] $(CONFIG)/bin/ejscmd'
	$(CC) -o $(CONFIG)/bin/ejscmd -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/ejs.o" $(LIBPATHS_44) $(LIBS_44) $(LIBS_44) $(LIBS) -lpam -ledit 
endif

ifeq ($(ME_COM_ESP),1)
#
#   esp-paks
#
DEPS_45 += src/paks/angular
DEPS_45 += src/paks/angular/angular-animate.js
DEPS_45 += src/paks/angular/angular-csp.css
DEPS_45 += src/paks/angular/angular-route.js
DEPS_45 += src/paks/angular/angular.js
DEPS_45 += src/paks/angular/package.json
DEPS_45 += src/paks/ejs
DEPS_45 += src/paks/ejs/ejs.c
DEPS_45 += src/paks/ejs/ejs.es
DEPS_45 += src/paks/ejs/ejs.h
DEPS_45 += src/paks/ejs/ejs.me
DEPS_45 += src/paks/ejs/ejs.slots.h
DEPS_45 += src/paks/ejs/ejsByteGoto.h
DEPS_45 += src/paks/ejs/ejsc.c
DEPS_45 += src/paks/ejs/ejsLib.c
DEPS_45 += src/paks/ejs/LICENSE.md
DEPS_45 += src/paks/ejs/package.json
DEPS_45 += src/paks/ejs/README.md
DEPS_45 += src/paks/esp
DEPS_45 += src/paks/esp/esp.c
DEPS_45 += src/paks/esp/esp.conf
DEPS_45 += src/paks/esp/esp.h
DEPS_45 += src/paks/esp/esp.me
DEPS_45 += src/paks/esp/espLib.c
DEPS_45 += src/paks/esp/LICENSE.md
DEPS_45 += src/paks/esp/package.json
DEPS_45 += src/paks/esp/README.md
DEPS_45 += src/paks/esp-angular
DEPS_45 += src/paks/esp-angular/esp-click.js
DEPS_45 += src/paks/esp-angular/esp-edit.js
DEPS_45 += src/paks/esp-angular/esp-field-errors.js
DEPS_45 += src/paks/esp-angular/esp-fixnum.js
DEPS_45 += src/paks/esp-angular/esp-format.js
DEPS_45 += src/paks/esp-angular/esp-input-group.js
DEPS_45 += src/paks/esp-angular/esp-input.js
DEPS_45 += src/paks/esp-angular/esp-resource.js
DEPS_45 += src/paks/esp-angular/esp-session.js
DEPS_45 += src/paks/esp-angular/esp-titlecase.js
DEPS_45 += src/paks/esp-angular/esp.js
DEPS_45 += src/paks/esp-angular/package.json
DEPS_45 += src/paks/esp-angular-mvc
DEPS_45 += src/paks/esp-angular-mvc/package.json
DEPS_45 += src/paks/esp-angular-mvc/templates
DEPS_45 += src/paks/esp-angular-mvc/templates/esp-angular-mvc
DEPS_45 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/appweb.conf
DEPS_45 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/client
DEPS_45 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/client/app
DEPS_45 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/client/app/main.js
DEPS_45 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/client/assets
DEPS_45 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/client/assets/favicon.ico
DEPS_45 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/client/css
DEPS_45 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/client/css/all.css
DEPS_45 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/client/css/all.less
DEPS_45 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/client/css/app.less
DEPS_45 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/client/css/fix.css
DEPS_45 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/client/css/theme.less
DEPS_45 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/client/index.esp
DEPS_45 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/client/pages
DEPS_45 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/client/pages/splash.html
DEPS_45 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/controller-singleton.c
DEPS_45 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/controller.c
DEPS_45 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/controller.js
DEPS_45 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/edit.html
DEPS_45 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/list.html
DEPS_45 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/model.js
DEPS_45 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/start.bit
DEPS_45 += src/paks/esp-html-mvc
DEPS_45 += src/paks/esp-html-mvc/package.json
DEPS_45 += src/paks/esp-html-mvc/templates
DEPS_45 += src/paks/esp-html-mvc/templates/esp-html-mvc
DEPS_45 += src/paks/esp-html-mvc/templates/esp-html-mvc/appweb.conf
DEPS_45 += src/paks/esp-html-mvc/templates/esp-html-mvc/client
DEPS_45 += src/paks/esp-html-mvc/templates/esp-html-mvc/client/assets
DEPS_45 += src/paks/esp-html-mvc/templates/esp-html-mvc/client/assets/favicon.ico
DEPS_45 += src/paks/esp-html-mvc/templates/esp-html-mvc/client/css
DEPS_45 += src/paks/esp-html-mvc/templates/esp-html-mvc/client/css/all.css
DEPS_45 += src/paks/esp-html-mvc/templates/esp-html-mvc/client/css/all.less
DEPS_45 += src/paks/esp-html-mvc/templates/esp-html-mvc/client/css/app.less
DEPS_45 += src/paks/esp-html-mvc/templates/esp-html-mvc/client/css/theme.less
DEPS_45 += src/paks/esp-html-mvc/templates/esp-html-mvc/client/index.esp
DEPS_45 += src/paks/esp-html-mvc/templates/esp-html-mvc/client/layouts
DEPS_45 += src/paks/esp-html-mvc/templates/esp-html-mvc/client/layouts/default.esp
DEPS_45 += src/paks/esp-html-mvc/templates/esp-html-mvc/controller-singleton.c
DEPS_45 += src/paks/esp-html-mvc/templates/esp-html-mvc/controller.c
DEPS_45 += src/paks/esp-html-mvc/templates/esp-html-mvc/edit.esp
DEPS_45 += src/paks/esp-html-mvc/templates/esp-html-mvc/list.esp
DEPS_45 += src/paks/esp-html-mvc/templates/esp-html-mvc/start.bit
DEPS_45 += src/paks/esp-legacy-mvc
DEPS_45 += src/paks/esp-legacy-mvc/package.json
DEPS_45 += src/paks/esp-legacy-mvc/templates
DEPS_45 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc
DEPS_45 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/appweb.conf
DEPS_45 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/controller.c
DEPS_45 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/edit.esp
DEPS_45 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/layouts
DEPS_45 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/layouts/default.esp
DEPS_45 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/list.esp
DEPS_45 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/migration.c
DEPS_45 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/src
DEPS_45 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/src/app.c
DEPS_45 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/static
DEPS_45 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/static/css
DEPS_45 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/static/css/all.css
DEPS_45 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/static/images
DEPS_45 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/static/images/banner.jpg
DEPS_45 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/static/images/favicon.ico
DEPS_45 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/static/images/splash.jpg
DEPS_45 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/static/index.esp
DEPS_45 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/static/js
DEPS_45 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/static/js/jquery.esp.js
DEPS_45 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/static/js/jquery.js
DEPS_45 += src/paks/esp-server
DEPS_45 += src/paks/esp-server/package.json
DEPS_45 += src/paks/esp-server/templates
DEPS_45 += src/paks/esp-server/templates/esp-server
DEPS_45 += src/paks/esp-server/templates/esp-server/appweb.conf
DEPS_45 += src/paks/esp-server/templates/esp-server/controller.c
DEPS_45 += src/paks/esp-server/templates/esp-server/migration.c
DEPS_45 += src/paks/esp-server/templates/esp-server/src
DEPS_45 += src/paks/esp-server/templates/esp-server/src/app.c
DEPS_45 += src/paks/est
DEPS_45 += src/paks/est/ca.crt
DEPS_45 += src/paks/est/est.h
DEPS_45 += src/paks/est/est.me
DEPS_45 += src/paks/est/estLib.c
DEPS_45 += src/paks/est/LICENSE.md
DEPS_45 += src/paks/est/package.json
DEPS_45 += src/paks/est/README.md
DEPS_45 += src/paks/http
DEPS_45 += src/paks/http/http.c
DEPS_45 += src/paks/http/http.h
DEPS_45 += src/paks/http/http.me
DEPS_45 += src/paks/http/httpLib.c
DEPS_45 += src/paks/http/LICENSE.md
DEPS_45 += src/paks/http/package.json
DEPS_45 += src/paks/http/README.md
DEPS_45 += src/paks/me-dev
DEPS_45 += src/paks/me-dev/dev.es
DEPS_45 += src/paks/me-dev/dev.me
DEPS_45 += src/paks/me-dev/LICENSE.md
DEPS_45 += src/paks/me-dev/package.json
DEPS_45 += src/paks/me-dev/README.md
DEPS_45 += src/paks/me-doc
DEPS_45 += src/paks/me-doc/doc.es
DEPS_45 += src/paks/me-doc/doc.me
DEPS_45 += src/paks/me-doc/LICENSE.md
DEPS_45 += src/paks/me-doc/package.json
DEPS_45 += src/paks/me-doc/README.md
DEPS_45 += src/paks/me-package
DEPS_45 += src/paks/me-package/LICENSE.md
DEPS_45 += src/paks/me-package/manifest.me
DEPS_45 += src/paks/me-package/package.es
DEPS_45 += src/paks/me-package/package.json
DEPS_45 += src/paks/me-package/package.me
DEPS_45 += src/paks/me-package/README.md
DEPS_45 += src/paks/mpr
DEPS_45 += src/paks/mpr/LICENSE.md
DEPS_45 += src/paks/mpr/makerom.c
DEPS_45 += src/paks/mpr/manager.c
DEPS_45 += src/paks/mpr/mpr.h
DEPS_45 += src/paks/mpr/mpr.me
DEPS_45 += src/paks/mpr/mprLib.c
DEPS_45 += src/paks/mpr/mprSsl.c
DEPS_45 += src/paks/mpr/package.json
DEPS_45 += src/paks/mpr/README.md
DEPS_45 += src/paks/osdep
DEPS_45 += src/paks/osdep/LICENSE.md
DEPS_45 += src/paks/osdep/osdep.h
DEPS_45 += src/paks/osdep/osdep.me
DEPS_45 += src/paks/osdep/package.json
DEPS_45 += src/paks/osdep/README.md
DEPS_45 += src/paks/pcre
DEPS_45 += src/paks/pcre/LICENSE.md
DEPS_45 += src/paks/pcre/package.json
DEPS_45 += src/paks/pcre/pcre.c
DEPS_45 += src/paks/pcre/pcre.h
DEPS_45 += src/paks/pcre/pcre.me
DEPS_45 += src/paks/pcre/README.md
DEPS_45 += src/paks/sqlite
DEPS_45 += src/paks/sqlite/LICENSE.md
DEPS_45 += src/paks/sqlite/package.json
DEPS_45 += src/paks/sqlite/README.md
DEPS_45 += src/paks/sqlite/sqlite.c
DEPS_45 += src/paks/sqlite/sqlite.me
DEPS_45 += src/paks/sqlite/sqlite3.c
DEPS_45 += src/paks/sqlite/sqlite3.h
DEPS_45 += src/paks/ssl
DEPS_45 += src/paks/ssl/LICENSE.md
DEPS_45 += src/paks/ssl/matrixssl.me
DEPS_45 += src/paks/ssl/nanossl.me
DEPS_45 += src/paks/ssl/openssl.me
DEPS_45 += src/paks/ssl/package.json
DEPS_45 += src/paks/ssl/README.md
DEPS_45 += src/paks/ssl/ssl.me
DEPS_45 += src/paks/zlib
DEPS_45 += src/paks/zlib/LICENSE.md
DEPS_45 += src/paks/zlib/package.json
DEPS_45 += src/paks/zlib/README.md
DEPS_45 += src/paks/zlib/zlib.c
DEPS_45 += src/paks/zlib/zlib.h
DEPS_45 += src/paks/zlib/zlib.me

$(CONFIG)/paks: $(DEPS_45)
	( \
	cd src/paks; \
	mkdir -p "../../$(CONFIG)/paks/esp-angular/4.5.2" ; \
	cp esp-angular/esp-click.js ../../$(CONFIG)/paks/esp-angular/4.5.2/esp-click.js ; \
	cp esp-angular/esp-edit.js ../../$(CONFIG)/paks/esp-angular/4.5.2/esp-edit.js ; \
	cp esp-angular/esp-field-errors.js ../../$(CONFIG)/paks/esp-angular/4.5.2/esp-field-errors.js ; \
	cp esp-angular/esp-fixnum.js ../../$(CONFIG)/paks/esp-angular/4.5.2/esp-fixnum.js ; \
	cp esp-angular/esp-format.js ../../$(CONFIG)/paks/esp-angular/4.5.2/esp-format.js ; \
	cp esp-angular/esp-input-group.js ../../$(CONFIG)/paks/esp-angular/4.5.2/esp-input-group.js ; \
	cp esp-angular/esp-input.js ../../$(CONFIG)/paks/esp-angular/4.5.2/esp-input.js ; \
	cp esp-angular/esp-resource.js ../../$(CONFIG)/paks/esp-angular/4.5.2/esp-resource.js ; \
	cp esp-angular/esp-session.js ../../$(CONFIG)/paks/esp-angular/4.5.2/esp-session.js ; \
	cp esp-angular/esp-titlecase.js ../../$(CONFIG)/paks/esp-angular/4.5.2/esp-titlecase.js ; \
	cp esp-angular/esp.js ../../$(CONFIG)/paks/esp-angular/4.5.2/esp.js ; \
	cp esp-angular/package.json ../../$(CONFIG)/paks/esp-angular/4.5.2/package.json ; \
	mkdir -p "../../$(CONFIG)/paks/esp-angular-mvc/4.5.2" ; \
	cp esp-angular-mvc/package.json ../../$(CONFIG)/paks/esp-angular-mvc/4.5.2/package.json ; \
	mkdir -p "../../$(CONFIG)/paks/esp-angular-mvc/4.5.2/templates" ; \
	mkdir -p "../../$(CONFIG)/paks/esp-angular-mvc/4.5.2/templates/esp-angular-mvc" ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/appweb.conf ../../$(CONFIG)/paks/esp-angular-mvc/4.5.2/templates/esp-angular-mvc/appweb.conf ; \
	mkdir -p "../../$(CONFIG)/paks/esp-angular-mvc/4.5.2/templates/esp-angular-mvc/client" ; \
	mkdir -p "../../$(CONFIG)/paks/esp-angular-mvc/4.5.2/templates/esp-angular-mvc/client/app" ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/client/app/main.js ../../$(CONFIG)/paks/esp-angular-mvc/4.5.2/templates/esp-angular-mvc/client/app/main.js ; \
	mkdir -p "../../$(CONFIG)/paks/esp-angular-mvc/4.5.2/templates/esp-angular-mvc/client/assets" ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/client/assets/favicon.ico ../../$(CONFIG)/paks/esp-angular-mvc/4.5.2/templates/esp-angular-mvc/client/assets/favicon.ico ; \
	mkdir -p "../../$(CONFIG)/paks/esp-angular-mvc/4.5.2/templates/esp-angular-mvc/client/css" ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/client/css/all.css ../../$(CONFIG)/paks/esp-angular-mvc/4.5.2/templates/esp-angular-mvc/client/css/all.css ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/client/css/all.less ../../$(CONFIG)/paks/esp-angular-mvc/4.5.2/templates/esp-angular-mvc/client/css/all.less ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/client/css/app.less ../../$(CONFIG)/paks/esp-angular-mvc/4.5.2/templates/esp-angular-mvc/client/css/app.less ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/client/css/fix.css ../../$(CONFIG)/paks/esp-angular-mvc/4.5.2/templates/esp-angular-mvc/client/css/fix.css ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/client/css/theme.less ../../$(CONFIG)/paks/esp-angular-mvc/4.5.2/templates/esp-angular-mvc/client/css/theme.less ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/client/index.esp ../../$(CONFIG)/paks/esp-angular-mvc/4.5.2/templates/esp-angular-mvc/client/index.esp ; \
	mkdir -p "../../$(CONFIG)/paks/esp-angular-mvc/4.5.2/templates/esp-angular-mvc/client/pages" ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/client/pages/splash.html ../../$(CONFIG)/paks/esp-angular-mvc/4.5.2/templates/esp-angular-mvc/client/pages/splash.html ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/controller-singleton.c ../../$(CONFIG)/paks/esp-angular-mvc/4.5.2/templates/esp-angular-mvc/controller-singleton.c ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/controller.c ../../$(CONFIG)/paks/esp-angular-mvc/4.5.2/templates/esp-angular-mvc/controller.c ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/controller.js ../../$(CONFIG)/paks/esp-angular-mvc/4.5.2/templates/esp-angular-mvc/controller.js ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/edit.html ../../$(CONFIG)/paks/esp-angular-mvc/4.5.2/templates/esp-angular-mvc/edit.html ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/list.html ../../$(CONFIG)/paks/esp-angular-mvc/4.5.2/templates/esp-angular-mvc/list.html ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/model.js ../../$(CONFIG)/paks/esp-angular-mvc/4.5.2/templates/esp-angular-mvc/model.js ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/start.bit ../../$(CONFIG)/paks/esp-angular-mvc/4.5.2/templates/esp-angular-mvc/start.bit ; \
	mkdir -p "../../$(CONFIG)/paks/esp-html-mvc/4.5.2" ; \
	cp esp-html-mvc/package.json ../../$(CONFIG)/paks/esp-html-mvc/4.5.2/package.json ; \
	mkdir -p "../../$(CONFIG)/paks/esp-html-mvc/4.5.2/templates" ; \
	mkdir -p "../../$(CONFIG)/paks/esp-html-mvc/4.5.2/templates/esp-html-mvc" ; \
	cp esp-html-mvc/templates/esp-html-mvc/appweb.conf ../../$(CONFIG)/paks/esp-html-mvc/4.5.2/templates/esp-html-mvc/appweb.conf ; \
	mkdir -p "../../$(CONFIG)/paks/esp-html-mvc/4.5.2/templates/esp-html-mvc/client" ; \
	mkdir -p "../../$(CONFIG)/paks/esp-html-mvc/4.5.2/templates/esp-html-mvc/client/assets" ; \
	cp esp-html-mvc/templates/esp-html-mvc/client/assets/favicon.ico ../../$(CONFIG)/paks/esp-html-mvc/4.5.2/templates/esp-html-mvc/client/assets/favicon.ico ; \
	mkdir -p "../../$(CONFIG)/paks/esp-html-mvc/4.5.2/templates/esp-html-mvc/client/css" ; \
	cp esp-html-mvc/templates/esp-html-mvc/client/css/all.css ../../$(CONFIG)/paks/esp-html-mvc/4.5.2/templates/esp-html-mvc/client/css/all.css ; \
	cp esp-html-mvc/templates/esp-html-mvc/client/css/all.less ../../$(CONFIG)/paks/esp-html-mvc/4.5.2/templates/esp-html-mvc/client/css/all.less ; \
	cp esp-html-mvc/templates/esp-html-mvc/client/css/app.less ../../$(CONFIG)/paks/esp-html-mvc/4.5.2/templates/esp-html-mvc/client/css/app.less ; \
	cp esp-html-mvc/templates/esp-html-mvc/client/css/theme.less ../../$(CONFIG)/paks/esp-html-mvc/4.5.2/templates/esp-html-mvc/client/css/theme.less ; \
	cp esp-html-mvc/templates/esp-html-mvc/client/index.esp ../../$(CONFIG)/paks/esp-html-mvc/4.5.2/templates/esp-html-mvc/client/index.esp ; \
	mkdir -p "../../$(CONFIG)/paks/esp-html-mvc/4.5.2/templates/esp-html-mvc/client/layouts" ; \
	cp esp-html-mvc/templates/esp-html-mvc/client/layouts/default.esp ../../$(CONFIG)/paks/esp-html-mvc/4.5.2/templates/esp-html-mvc/client/layouts/default.esp ; \
	cp esp-html-mvc/templates/esp-html-mvc/controller-singleton.c ../../$(CONFIG)/paks/esp-html-mvc/4.5.2/templates/esp-html-mvc/controller-singleton.c ; \
	cp esp-html-mvc/templates/esp-html-mvc/controller.c ../../$(CONFIG)/paks/esp-html-mvc/4.5.2/templates/esp-html-mvc/controller.c ; \
	cp esp-html-mvc/templates/esp-html-mvc/edit.esp ../../$(CONFIG)/paks/esp-html-mvc/4.5.2/templates/esp-html-mvc/edit.esp ; \
	cp esp-html-mvc/templates/esp-html-mvc/list.esp ../../$(CONFIG)/paks/esp-html-mvc/4.5.2/templates/esp-html-mvc/list.esp ; \
	cp esp-html-mvc/templates/esp-html-mvc/start.bit ../../$(CONFIG)/paks/esp-html-mvc/4.5.2/templates/esp-html-mvc/start.bit ; \
	mkdir -p "../../$(CONFIG)/paks/esp-legacy-mvc/4.5.2" ; \
	cp esp-legacy-mvc/package.json ../../$(CONFIG)/paks/esp-legacy-mvc/4.5.2/package.json ; \
	mkdir -p "../../$(CONFIG)/paks/esp-legacy-mvc/4.5.2/templates" ; \
	mkdir -p "../../$(CONFIG)/paks/esp-legacy-mvc/4.5.2/templates/esp-legacy-mvc" ; \
	cp esp-legacy-mvc/templates/esp-legacy-mvc/appweb.conf ../../$(CONFIG)/paks/esp-legacy-mvc/4.5.2/templates/esp-legacy-mvc/appweb.conf ; \
	cp esp-legacy-mvc/templates/esp-legacy-mvc/controller.c ../../$(CONFIG)/paks/esp-legacy-mvc/4.5.2/templates/esp-legacy-mvc/controller.c ; \
	cp esp-legacy-mvc/templates/esp-legacy-mvc/edit.esp ../../$(CONFIG)/paks/esp-legacy-mvc/4.5.2/templates/esp-legacy-mvc/edit.esp ; \
	mkdir -p "../../$(CONFIG)/paks/esp-legacy-mvc/4.5.2/templates/esp-legacy-mvc/layouts" ; \
	cp esp-legacy-mvc/templates/esp-legacy-mvc/layouts/default.esp ../../$(CONFIG)/paks/esp-legacy-mvc/4.5.2/templates/esp-legacy-mvc/layouts/default.esp ; \
	cp esp-legacy-mvc/templates/esp-legacy-mvc/list.esp ../../$(CONFIG)/paks/esp-legacy-mvc/4.5.2/templates/esp-legacy-mvc/list.esp ; \
	cp esp-legacy-mvc/templates/esp-legacy-mvc/migration.c ../../$(CONFIG)/paks/esp-legacy-mvc/4.5.2/templates/esp-legacy-mvc/migration.c ; \
	mkdir -p "../../$(CONFIG)/paks/esp-legacy-mvc/4.5.2/templates/esp-legacy-mvc/src" ; \
	cp esp-legacy-mvc/templates/esp-legacy-mvc/src/app.c ../../$(CONFIG)/paks/esp-legacy-mvc/4.5.2/templates/esp-legacy-mvc/src/app.c ; \
	mkdir -p "../../$(CONFIG)/paks/esp-legacy-mvc/4.5.2/templates/esp-legacy-mvc/static" ; \
	mkdir -p "../../$(CONFIG)/paks/esp-legacy-mvc/4.5.2/templates/esp-legacy-mvc/static/css" ; \
	cp esp-legacy-mvc/templates/esp-legacy-mvc/static/css/all.css ../../$(CONFIG)/paks/esp-legacy-mvc/4.5.2/templates/esp-legacy-mvc/static/css/all.css ; \
	mkdir -p "../../$(CONFIG)/paks/esp-legacy-mvc/4.5.2/templates/esp-legacy-mvc/static/images" ; \
	cp esp-legacy-mvc/templates/esp-legacy-mvc/static/images/banner.jpg ../../$(CONFIG)/paks/esp-legacy-mvc/4.5.2/templates/esp-legacy-mvc/static/images/banner.jpg ; \
	cp esp-legacy-mvc/templates/esp-legacy-mvc/static/images/favicon.ico ../../$(CONFIG)/paks/esp-legacy-mvc/4.5.2/templates/esp-legacy-mvc/static/images/favicon.ico ; \
	cp esp-legacy-mvc/templates/esp-legacy-mvc/static/images/splash.jpg ../../$(CONFIG)/paks/esp-legacy-mvc/4.5.2/templates/esp-legacy-mvc/static/images/splash.jpg ; \
	cp esp-legacy-mvc/templates/esp-legacy-mvc/static/index.esp ../../$(CONFIG)/paks/esp-legacy-mvc/4.5.2/templates/esp-legacy-mvc/static/index.esp ; \
	mkdir -p "../../$(CONFIG)/paks/esp-legacy-mvc/4.5.2/templates/esp-legacy-mvc/static/js" ; \
	cp esp-legacy-mvc/templates/esp-legacy-mvc/static/js/jquery.esp.js ../../$(CONFIG)/paks/esp-legacy-mvc/4.5.2/templates/esp-legacy-mvc/static/js/jquery.esp.js ; \
	cp esp-legacy-mvc/templates/esp-legacy-mvc/static/js/jquery.js ../../$(CONFIG)/paks/esp-legacy-mvc/4.5.2/templates/esp-legacy-mvc/static/js/jquery.js ; \
	mkdir -p "../../$(CONFIG)/paks/esp-server/4.5.2" ; \
	cp esp-server/package.json ../../$(CONFIG)/paks/esp-server/4.5.2/package.json ; \
	mkdir -p "../../$(CONFIG)/paks/esp-server/4.5.2/templates" ; \
	mkdir -p "../../$(CONFIG)/paks/esp-server/4.5.2/templates/esp-server" ; \
	cp esp-server/templates/esp-server/appweb.conf ../../$(CONFIG)/paks/esp-server/4.5.2/templates/esp-server/appweb.conf ; \
	cp esp-server/templates/esp-server/controller.c ../../$(CONFIG)/paks/esp-server/4.5.2/templates/esp-server/controller.c ; \
	cp esp-server/templates/esp-server/migration.c ../../$(CONFIG)/paks/esp-server/4.5.2/templates/esp-server/migration.c ; \
	mkdir -p "../../$(CONFIG)/paks/esp-server/4.5.2/templates/esp-server/src" ; \
	cp esp-server/templates/esp-server/src/app.c ../../$(CONFIG)/paks/esp-server/4.5.2/templates/esp-server/src/app.c ; \
	)
endif

ifeq ($(ME_COM_ESP),1)
#
#   esp.conf
#
DEPS_46 += src/paks/esp/esp.conf

$(CONFIG)/bin/esp.conf: $(DEPS_46)
	@echo '      [Copy] $(CONFIG)/bin/esp.conf'
	mkdir -p "$(CONFIG)/bin"
	cp src/paks/esp/esp.conf $(CONFIG)/bin/esp.conf
endif

#
#   espLib.o
#
DEPS_47 += $(CONFIG)/inc/me.h
DEPS_47 += $(CONFIG)/inc/esp.h
DEPS_47 += $(CONFIG)/inc/pcre.h
DEPS_47 += $(CONFIG)/inc/http.h

$(CONFIG)/obj/espLib.o: \
    src/paks/esp/espLib.c $(DEPS_47)
	@echo '   [Compile] $(CONFIG)/obj/espLib.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/espLib.o -arch $(CC_ARCH) $(IFLAGS) src/paks/esp/espLib.c

ifeq ($(ME_COM_ESP),1)
#
#   libmod_esp
#
DEPS_48 += $(CONFIG)/inc/mpr.h
DEPS_48 += $(CONFIG)/inc/me.h
DEPS_48 += $(CONFIG)/inc/osdep.h
DEPS_48 += $(CONFIG)/obj/mprLib.o
DEPS_48 += $(CONFIG)/bin/libmpr.dylib
DEPS_48 += $(CONFIG)/inc/pcre.h
DEPS_48 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_48 += $(CONFIG)/bin/libpcre.dylib
endif
DEPS_48 += $(CONFIG)/inc/http.h
DEPS_48 += $(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_48 += $(CONFIG)/bin/libhttp.dylib
endif
DEPS_48 += $(CONFIG)/inc/appweb.h
DEPS_48 += $(CONFIG)/inc/customize.h
DEPS_48 += $(CONFIG)/obj/config.o
DEPS_48 += $(CONFIG)/obj/convenience.o
DEPS_48 += $(CONFIG)/obj/dirHandler.o
DEPS_48 += $(CONFIG)/obj/fileHandler.o
DEPS_48 += $(CONFIG)/obj/log.o
DEPS_48 += $(CONFIG)/obj/server.o
DEPS_48 += $(CONFIG)/bin/libappweb.dylib
DEPS_48 += $(CONFIG)/inc/esp.h
DEPS_48 += $(CONFIG)/obj/espLib.o

LIBS_48 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_48 += -lhttp
endif
LIBS_48 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_48 += -lpcre
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_48 += -lsql
endif

$(CONFIG)/bin/libmod_esp.dylib: $(DEPS_48)
	@echo '      [Link] $(CONFIG)/bin/libmod_esp.dylib'
	$(CC) -dynamiclib -o $(CONFIG)/bin/libmod_esp.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libmod_esp.dylib -compatibility_version 5.0.0 -current_version 5.0.0 "$(CONFIG)/obj/espLib.o" $(LIBPATHS_48) $(LIBS_48) $(LIBS_48) $(LIBS) -lpam 
endif

#
#   esp.o
#
DEPS_49 += $(CONFIG)/inc/me.h
DEPS_49 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/esp.o: \
    src/paks/esp/esp.c $(DEPS_49)
	@echo '   [Compile] $(CONFIG)/obj/esp.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/esp.o -arch $(CC_ARCH) $(IFLAGS) src/paks/esp/esp.c

ifeq ($(ME_COM_ESP),1)
#
#   espcmd
#
DEPS_50 += $(CONFIG)/inc/mpr.h
DEPS_50 += $(CONFIG)/inc/me.h
DEPS_50 += $(CONFIG)/inc/osdep.h
DEPS_50 += $(CONFIG)/obj/mprLib.o
DEPS_50 += $(CONFIG)/bin/libmpr.dylib
DEPS_50 += $(CONFIG)/inc/pcre.h
DEPS_50 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_50 += $(CONFIG)/bin/libpcre.dylib
endif
DEPS_50 += $(CONFIG)/inc/http.h
DEPS_50 += $(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_50 += $(CONFIG)/bin/libhttp.dylib
endif
DEPS_50 += $(CONFIG)/inc/appweb.h
DEPS_50 += $(CONFIG)/inc/customize.h
DEPS_50 += $(CONFIG)/obj/config.o
DEPS_50 += $(CONFIG)/obj/convenience.o
DEPS_50 += $(CONFIG)/obj/dirHandler.o
DEPS_50 += $(CONFIG)/obj/fileHandler.o
DEPS_50 += $(CONFIG)/obj/log.o
DEPS_50 += $(CONFIG)/obj/server.o
DEPS_50 += $(CONFIG)/bin/libappweb.dylib
DEPS_50 += $(CONFIG)/inc/esp.h
DEPS_50 += $(CONFIG)/obj/espLib.o
DEPS_50 += $(CONFIG)/bin/libmod_esp.dylib
DEPS_50 += $(CONFIG)/obj/esp.o

LIBS_50 += -lmod_esp
LIBS_50 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_50 += -lhttp
endif
LIBS_50 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_50 += -lpcre
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_50 += -lsql
endif

$(CONFIG)/bin/esp: $(DEPS_50)
	@echo '      [Link] $(CONFIG)/bin/esp'
	$(CC) -o $(CONFIG)/bin/esp -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/esp.o" "$(CONFIG)/obj/espLib.o" $(LIBPATHS_50) $(LIBS_50) $(LIBS_50) $(LIBS) -lpam 
endif


#
#   http.o
#
DEPS_51 += $(CONFIG)/inc/me.h
DEPS_51 += $(CONFIG)/inc/http.h

$(CONFIG)/obj/http.o: \
    src/paks/http/http.c $(DEPS_51)
	@echo '   [Compile] $(CONFIG)/obj/http.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/http.o -arch $(CC_ARCH) $(IFLAGS) src/paks/http/http.c

ifeq ($(ME_COM_HTTP),1)
#
#   httpcmd
#
DEPS_52 += $(CONFIG)/inc/mpr.h
DEPS_52 += $(CONFIG)/inc/me.h
DEPS_52 += $(CONFIG)/inc/osdep.h
DEPS_52 += $(CONFIG)/obj/mprLib.o
DEPS_52 += $(CONFIG)/bin/libmpr.dylib
DEPS_52 += $(CONFIG)/inc/pcre.h
DEPS_52 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_52 += $(CONFIG)/bin/libpcre.dylib
endif
DEPS_52 += $(CONFIG)/inc/http.h
DEPS_52 += $(CONFIG)/obj/httpLib.o
DEPS_52 += $(CONFIG)/bin/libhttp.dylib
DEPS_52 += $(CONFIG)/obj/http.o

LIBS_52 += -lhttp
LIBS_52 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_52 += -lpcre
endif

$(CONFIG)/bin/http: $(DEPS_52)
	@echo '      [Link] $(CONFIG)/bin/http'
	$(CC) -o $(CONFIG)/bin/http -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/http.o" $(LIBPATHS_52) $(LIBS_52) $(LIBS_52) $(LIBS) -lpam 
endif

#
#   est.h
#
$(CONFIG)/inc/est.h: $(DEPS_53)
	@echo '      [Copy] $(CONFIG)/inc/est.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/est/est.h $(CONFIG)/inc/est.h

#
#   estLib.o
#
DEPS_54 += $(CONFIG)/inc/me.h
DEPS_54 += $(CONFIG)/inc/est.h
DEPS_54 += $(CONFIG)/inc/osdep.h

$(CONFIG)/obj/estLib.o: \
    src/paks/est/estLib.c $(DEPS_54)
	@echo '   [Compile] $(CONFIG)/obj/estLib.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/estLib.o -arch $(CC_ARCH) $(IFLAGS) src/paks/est/estLib.c

ifeq ($(ME_COM_EST),1)
#
#   libest
#
DEPS_55 += $(CONFIG)/inc/est.h
DEPS_55 += $(CONFIG)/inc/me.h
DEPS_55 += $(CONFIG)/inc/osdep.h
DEPS_55 += $(CONFIG)/obj/estLib.o

$(CONFIG)/bin/libest.dylib: $(DEPS_55)
	@echo '      [Link] $(CONFIG)/bin/libest.dylib'
	$(CC) -dynamiclib -o $(CONFIG)/bin/libest.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libest.dylib -compatibility_version 5.0.0 -current_version 5.0.0 "$(CONFIG)/obj/estLib.o" $(LIBS) 
endif

#
#   cgiHandler.o
#
DEPS_56 += $(CONFIG)/inc/me.h
DEPS_56 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/cgiHandler.o: \
    src/modules/cgiHandler.c $(DEPS_56)
	@echo '   [Compile] $(CONFIG)/obj/cgiHandler.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/cgiHandler.o -arch $(CC_ARCH) $(IFLAGS) src/modules/cgiHandler.c

ifeq ($(ME_COM_CGI),1)
#
#   libmod_cgi
#
DEPS_57 += $(CONFIG)/inc/mpr.h
DEPS_57 += $(CONFIG)/inc/me.h
DEPS_57 += $(CONFIG)/inc/osdep.h
DEPS_57 += $(CONFIG)/obj/mprLib.o
DEPS_57 += $(CONFIG)/bin/libmpr.dylib
DEPS_57 += $(CONFIG)/inc/pcre.h
DEPS_57 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_57 += $(CONFIG)/bin/libpcre.dylib
endif
DEPS_57 += $(CONFIG)/inc/http.h
DEPS_57 += $(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_57 += $(CONFIG)/bin/libhttp.dylib
endif
DEPS_57 += $(CONFIG)/inc/appweb.h
DEPS_57 += $(CONFIG)/inc/customize.h
DEPS_57 += $(CONFIG)/obj/config.o
DEPS_57 += $(CONFIG)/obj/convenience.o
DEPS_57 += $(CONFIG)/obj/dirHandler.o
DEPS_57 += $(CONFIG)/obj/fileHandler.o
DEPS_57 += $(CONFIG)/obj/log.o
DEPS_57 += $(CONFIG)/obj/server.o
DEPS_57 += $(CONFIG)/bin/libappweb.dylib
DEPS_57 += $(CONFIG)/obj/cgiHandler.o

LIBS_57 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_57 += -lhttp
endif
LIBS_57 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_57 += -lpcre
endif

$(CONFIG)/bin/libmod_cgi.dylib: $(DEPS_57)
	@echo '      [Link] $(CONFIG)/bin/libmod_cgi.dylib'
	$(CC) -dynamiclib -o $(CONFIG)/bin/libmod_cgi.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libmod_cgi.dylib -compatibility_version 5.0.0 -current_version 5.0.0 "$(CONFIG)/obj/cgiHandler.o" $(LIBPATHS_57) $(LIBS_57) $(LIBS_57) $(LIBS) -lpam 
endif

#
#   ejsHandler.o
#
DEPS_58 += $(CONFIG)/inc/me.h
DEPS_58 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/ejsHandler.o: \
    src/modules/ejsHandler.c $(DEPS_58)
	@echo '   [Compile] $(CONFIG)/obj/ejsHandler.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/ejsHandler.o -arch $(CC_ARCH) $(IFLAGS) src/modules/ejsHandler.c

ifeq ($(ME_COM_EJS),1)
#
#   libmod_ejs
#
DEPS_59 += $(CONFIG)/inc/mpr.h
DEPS_59 += $(CONFIG)/inc/me.h
DEPS_59 += $(CONFIG)/inc/osdep.h
DEPS_59 += $(CONFIG)/obj/mprLib.o
DEPS_59 += $(CONFIG)/bin/libmpr.dylib
DEPS_59 += $(CONFIG)/inc/pcre.h
DEPS_59 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_59 += $(CONFIG)/bin/libpcre.dylib
endif
DEPS_59 += $(CONFIG)/inc/http.h
DEPS_59 += $(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_59 += $(CONFIG)/bin/libhttp.dylib
endif
DEPS_59 += $(CONFIG)/inc/appweb.h
DEPS_59 += $(CONFIG)/inc/customize.h
DEPS_59 += $(CONFIG)/obj/config.o
DEPS_59 += $(CONFIG)/obj/convenience.o
DEPS_59 += $(CONFIG)/obj/dirHandler.o
DEPS_59 += $(CONFIG)/obj/fileHandler.o
DEPS_59 += $(CONFIG)/obj/log.o
DEPS_59 += $(CONFIG)/obj/server.o
DEPS_59 += $(CONFIG)/bin/libappweb.dylib
DEPS_59 += $(CONFIG)/inc/zlib.h
DEPS_59 += $(CONFIG)/obj/zlib.o
ifeq ($(ME_COM_ZLIB),1)
    DEPS_59 += $(CONFIG)/bin/libzlib.dylib
endif
DEPS_59 += $(CONFIG)/inc/ejs.h
DEPS_59 += $(CONFIG)/inc/ejs.slots.h
DEPS_59 += $(CONFIG)/inc/ejsByteGoto.h
DEPS_59 += $(CONFIG)/obj/ejsLib.o
DEPS_59 += $(CONFIG)/bin/libejs.dylib
DEPS_59 += $(CONFIG)/obj/ejsHandler.o

LIBS_59 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_59 += -lhttp
endif
LIBS_59 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_59 += -lpcre
endif
LIBS_59 += -lejs
ifeq ($(ME_COM_ZLIB),1)
    LIBS_59 += -lzlib
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_59 += -lsql
endif

$(CONFIG)/bin/libmod_ejs.dylib: $(DEPS_59)
	@echo '      [Link] $(CONFIG)/bin/libmod_ejs.dylib'
	$(CC) -dynamiclib -o $(CONFIG)/bin/libmod_ejs.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libmod_ejs.dylib -compatibility_version 5.0.0 -current_version 5.0.0 "$(CONFIG)/obj/ejsHandler.o" $(LIBPATHS_59) $(LIBS_59) $(LIBS_59) $(LIBS) -lpam 
endif

#
#   phpHandler.o
#
DEPS_60 += $(CONFIG)/inc/me.h
DEPS_60 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/phpHandler.o: \
    src/modules/phpHandler.c $(DEPS_60)
	@echo '   [Compile] $(CONFIG)/obj/phpHandler.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/phpHandler.o -arch $(CC_ARCH) $(IFLAGS) "-I$(BIT_PACK_PHP_PATH)" "-I$(BIT_PACK_PHP_PATH)/main" "-I$(BIT_PACK_PHP_PATH)/Zend" "-I$(BIT_PACK_PHP_PATH)/TSRM" src/modules/phpHandler.c

ifeq ($(ME_COM_PHP),1)
#
#   libmod_php
#
DEPS_61 += $(CONFIG)/inc/mpr.h
DEPS_61 += $(CONFIG)/inc/me.h
DEPS_61 += $(CONFIG)/inc/osdep.h
DEPS_61 += $(CONFIG)/obj/mprLib.o
DEPS_61 += $(CONFIG)/bin/libmpr.dylib
DEPS_61 += $(CONFIG)/inc/pcre.h
DEPS_61 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_61 += $(CONFIG)/bin/libpcre.dylib
endif
DEPS_61 += $(CONFIG)/inc/http.h
DEPS_61 += $(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_61 += $(CONFIG)/bin/libhttp.dylib
endif
DEPS_61 += $(CONFIG)/inc/appweb.h
DEPS_61 += $(CONFIG)/inc/customize.h
DEPS_61 += $(CONFIG)/obj/config.o
DEPS_61 += $(CONFIG)/obj/convenience.o
DEPS_61 += $(CONFIG)/obj/dirHandler.o
DEPS_61 += $(CONFIG)/obj/fileHandler.o
DEPS_61 += $(CONFIG)/obj/log.o
DEPS_61 += $(CONFIG)/obj/server.o
DEPS_61 += $(CONFIG)/bin/libappweb.dylib
DEPS_61 += $(CONFIG)/obj/phpHandler.o

LIBS_61 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_61 += -lhttp
endif
LIBS_61 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_61 += -lpcre
endif
LIBS_61 += -lphp5
LIBPATHS_61 += -L$(BIT_PACK_PHP_PATH)/libs

$(CONFIG)/bin/libmod_php.dylib: $(DEPS_61)
	@echo '      [Link] $(CONFIG)/bin/libmod_php.dylib'
	$(CC) -dynamiclib -o $(CONFIG)/bin/libmod_php.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS)  -install_name @rpath/libmod_php.dylib -compatibility_version 5.0.0 -current_version 5.0.0 "$(CONFIG)/obj/phpHandler.o" $(LIBPATHS_61) $(LIBS_61) $(LIBS_61) $(LIBS) -lpam 
endif

#
#   mprSsl.o
#
DEPS_62 += $(CONFIG)/inc/me.h
DEPS_62 += $(CONFIG)/inc/mpr.h
DEPS_62 += $(CONFIG)/inc/est.h

$(CONFIG)/obj/mprSsl.o: \
    src/paks/mpr/mprSsl.c $(DEPS_62)
	@echo '   [Compile] $(CONFIG)/obj/mprSsl.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/mprSsl.o -arch $(CC_ARCH) $(IFLAGS) "-I$(ME_COM_MATRIXSSL_PATH)" "-I$(ME_COM_MATRIXSSL_PATH)/matrixssl" "-I$(ME_COM_NANOSSL_PATH)/src" src/paks/mpr/mprSsl.c

#
#   libmprssl
#
DEPS_63 += $(CONFIG)/inc/mpr.h
DEPS_63 += $(CONFIG)/inc/me.h
DEPS_63 += $(CONFIG)/inc/osdep.h
DEPS_63 += $(CONFIG)/obj/mprLib.o
DEPS_63 += $(CONFIG)/bin/libmpr.dylib
DEPS_63 += $(CONFIG)/inc/est.h
DEPS_63 += $(CONFIG)/obj/estLib.o
ifeq ($(ME_COM_EST),1)
    DEPS_63 += $(CONFIG)/bin/libest.dylib
endif
DEPS_63 += $(CONFIG)/obj/mprSsl.o

LIBS_63 += -lmpr
ifeq ($(ME_COM_EST),1)
    LIBS_63 += -lest
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_63 += -lmatrixssl
    LIBPATHS_63 += -L$(ME_COM_MATRIXSSL_PATH)
endif
ifeq ($(ME_COM_NANOSSL),1)
    LIBS_63 += -lssls
    LIBPATHS_63 += -L$(ME_COM_NANOSSL_PATH)/bin
endif

$(CONFIG)/bin/libmprssl.dylib: $(DEPS_63)
	@echo '      [Link] $(CONFIG)/bin/libmprssl.dylib'
	$(CC) -dynamiclib -o $(CONFIG)/bin/libmprssl.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS)   -install_name @rpath/libmprssl.dylib -compatibility_version 5.0.0 -current_version 5.0.0 "$(CONFIG)/obj/mprSsl.o" $(LIBPATHS_63) $(LIBS_63) $(LIBS_63) $(LIBS) 

#
#   sslModule.o
#
DEPS_64 += $(CONFIG)/inc/me.h
DEPS_64 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/sslModule.o: \
    src/modules/sslModule.c $(DEPS_64)
	@echo '   [Compile] $(CONFIG)/obj/sslModule.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/sslModule.o -arch $(CC_ARCH) $(IFLAGS) "-I$(ME_COM_MATRIXSSL_PATH)" "-I$(ME_COM_MATRIXSSL_PATH)/matrixssl" "-I$(ME_COM_NANOSSL_PATH)/src" src/modules/sslModule.c

ifeq ($(ME_COM_SSL),1)
#
#   libmod_ssl
#
DEPS_65 += $(CONFIG)/inc/mpr.h
DEPS_65 += $(CONFIG)/inc/me.h
DEPS_65 += $(CONFIG)/inc/osdep.h
DEPS_65 += $(CONFIG)/obj/mprLib.o
DEPS_65 += $(CONFIG)/bin/libmpr.dylib
DEPS_65 += $(CONFIG)/inc/pcre.h
DEPS_65 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_65 += $(CONFIG)/bin/libpcre.dylib
endif
DEPS_65 += $(CONFIG)/inc/http.h
DEPS_65 += $(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_65 += $(CONFIG)/bin/libhttp.dylib
endif
DEPS_65 += $(CONFIG)/inc/appweb.h
DEPS_65 += $(CONFIG)/inc/customize.h
DEPS_65 += $(CONFIG)/obj/config.o
DEPS_65 += $(CONFIG)/obj/convenience.o
DEPS_65 += $(CONFIG)/obj/dirHandler.o
DEPS_65 += $(CONFIG)/obj/fileHandler.o
DEPS_65 += $(CONFIG)/obj/log.o
DEPS_65 += $(CONFIG)/obj/server.o
DEPS_65 += $(CONFIG)/bin/libappweb.dylib
DEPS_65 += $(CONFIG)/inc/est.h
DEPS_65 += $(CONFIG)/obj/estLib.o
ifeq ($(ME_COM_EST),1)
    DEPS_65 += $(CONFIG)/bin/libest.dylib
endif
DEPS_65 += $(CONFIG)/obj/mprSsl.o
DEPS_65 += $(CONFIG)/bin/libmprssl.dylib
DEPS_65 += $(CONFIG)/obj/sslModule.o

LIBS_65 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_65 += -lhttp
endif
LIBS_65 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_65 += -lpcre
endif
LIBS_65 += -lmprssl
ifeq ($(ME_COM_EST),1)
    LIBS_65 += -lest
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_65 += -lmatrixssl
    LIBPATHS_65 += -L$(ME_COM_MATRIXSSL_PATH)
endif
ifeq ($(ME_COM_NANOSSL),1)
    LIBS_65 += -lssls
    LIBPATHS_65 += -L$(ME_COM_NANOSSL_PATH)/bin
endif

$(CONFIG)/bin/libmod_ssl.dylib: $(DEPS_65)
	@echo '      [Link] $(CONFIG)/bin/libmod_ssl.dylib'
	$(CC) -dynamiclib -o $(CONFIG)/bin/libmod_ssl.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS)   -install_name @rpath/libmod_ssl.dylib -compatibility_version 5.0.0 -current_version 5.0.0 "$(CONFIG)/obj/sslModule.o" $(LIBPATHS_65) $(LIBS_65) $(LIBS_65) $(LIBS) -lpam 
endif

#
#   sqlite3.h
#
$(CONFIG)/inc/sqlite3.h: $(DEPS_66)
	@echo '      [Copy] $(CONFIG)/inc/sqlite3.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/sqlite/sqlite3.h $(CONFIG)/inc/sqlite3.h

#
#   sqlite3.o
#
DEPS_67 += $(CONFIG)/inc/me.h
DEPS_67 += $(CONFIG)/inc/sqlite3.h

$(CONFIG)/obj/sqlite3.o: \
    src/paks/sqlite/sqlite3.c $(DEPS_67)
	@echo '   [Compile] $(CONFIG)/obj/sqlite3.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/sqlite3.o -arch $(CC_ARCH) $(IFLAGS) src/paks/sqlite/sqlite3.c

ifeq ($(ME_COM_SQLITE),1)
#
#   libsql
#
DEPS_68 += $(CONFIG)/inc/sqlite3.h
DEPS_68 += $(CONFIG)/inc/me.h
DEPS_68 += $(CONFIG)/obj/sqlite3.o

$(CONFIG)/bin/libsql.dylib: $(DEPS_68)
	@echo '      [Link] $(CONFIG)/bin/libsql.dylib'
	$(CC) -dynamiclib -o $(CONFIG)/bin/libsql.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libsql.dylib -compatibility_version 5.0.0 -current_version 5.0.0 "$(CONFIG)/obj/sqlite3.o" $(LIBS) 
endif

#
#   manager.o
#
DEPS_69 += $(CONFIG)/inc/me.h
DEPS_69 += $(CONFIG)/inc/mpr.h

$(CONFIG)/obj/manager.o: \
    src/paks/mpr/manager.c $(DEPS_69)
	@echo '   [Compile] $(CONFIG)/obj/manager.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/manager.o -arch $(CC_ARCH) $(IFLAGS) src/paks/mpr/manager.c

#
#   manager
#
DEPS_70 += $(CONFIG)/inc/mpr.h
DEPS_70 += $(CONFIG)/inc/me.h
DEPS_70 += $(CONFIG)/inc/osdep.h
DEPS_70 += $(CONFIG)/obj/mprLib.o
DEPS_70 += $(CONFIG)/bin/libmpr.dylib
DEPS_70 += $(CONFIG)/obj/manager.o

LIBS_70 += -lmpr

$(CONFIG)/bin/appman: $(DEPS_70)
	@echo '      [Link] $(CONFIG)/bin/appman'
	$(CC) -o $(CONFIG)/bin/appman -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/manager.o" $(LIBPATHS_70) $(LIBS_70) $(LIBS_70) $(LIBS) 

#
#   server-cache
#
src/server/cache: $(DEPS_71)

#
#   sqlite.o
#
DEPS_72 += $(CONFIG)/inc/me.h
DEPS_72 += $(CONFIG)/inc/sqlite3.h

$(CONFIG)/obj/sqlite.o: \
    src/paks/sqlite/sqlite.c $(DEPS_72)
	@echo '   [Compile] $(CONFIG)/obj/sqlite.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/sqlite.o -arch $(CC_ARCH) $(IFLAGS) src/paks/sqlite/sqlite.c

ifeq ($(ME_COM_SQLITE),1)
#
#   sqliteshell
#
DEPS_73 += $(CONFIG)/inc/sqlite3.h
DEPS_73 += $(CONFIG)/inc/me.h
DEPS_73 += $(CONFIG)/obj/sqlite3.o
DEPS_73 += $(CONFIG)/bin/libsql.dylib
DEPS_73 += $(CONFIG)/obj/sqlite.o

LIBS_73 += -lsql

$(CONFIG)/bin/sqlite: $(DEPS_73)
	@echo '      [Link] $(CONFIG)/bin/sqlite'
	$(CC) -o $(CONFIG)/bin/sqlite -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/sqlite.o" $(LIBPATHS_73) $(LIBS_73) $(LIBS_73) $(LIBS) 
endif

#
#   testAppweb.h
#
$(CONFIG)/inc/testAppweb.h: $(DEPS_74)
	@echo '      [Copy] $(CONFIG)/inc/testAppweb.h'
	mkdir -p "$(CONFIG)/inc"
	cp test/src/testAppweb.h $(CONFIG)/inc/testAppweb.h

#
#   testAppweb.o
#
DEPS_75 += $(CONFIG)/inc/me.h
DEPS_75 += $(CONFIG)/inc/testAppweb.h
DEPS_75 += $(CONFIG)/inc/mpr.h
DEPS_75 += $(CONFIG)/inc/http.h

$(CONFIG)/obj/testAppweb.o: \
    test/src/testAppweb.c $(DEPS_75)
	@echo '   [Compile] $(CONFIG)/obj/testAppweb.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/testAppweb.o -arch $(CC_ARCH) $(IFLAGS) test/src/testAppweb.c

#
#   testHttp.o
#
DEPS_76 += $(CONFIG)/inc/me.h
DEPS_76 += $(CONFIG)/inc/testAppweb.h

$(CONFIG)/obj/testHttp.o: \
    test/src/testHttp.c $(DEPS_76)
	@echo '   [Compile] $(CONFIG)/obj/testHttp.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/testHttp.o -arch $(CC_ARCH) $(IFLAGS) test/src/testHttp.c

#
#   testAppweb
#
DEPS_77 += $(CONFIG)/inc/mpr.h
DEPS_77 += $(CONFIG)/inc/me.h
DEPS_77 += $(CONFIG)/inc/osdep.h
DEPS_77 += $(CONFIG)/obj/mprLib.o
DEPS_77 += $(CONFIG)/bin/libmpr.dylib
DEPS_77 += $(CONFIG)/inc/pcre.h
DEPS_77 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_77 += $(CONFIG)/bin/libpcre.dylib
endif
DEPS_77 += $(CONFIG)/inc/http.h
DEPS_77 += $(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_77 += $(CONFIG)/bin/libhttp.dylib
endif
DEPS_77 += $(CONFIG)/inc/appweb.h
DEPS_77 += $(CONFIG)/inc/customize.h
DEPS_77 += $(CONFIG)/obj/config.o
DEPS_77 += $(CONFIG)/obj/convenience.o
DEPS_77 += $(CONFIG)/obj/dirHandler.o
DEPS_77 += $(CONFIG)/obj/fileHandler.o
DEPS_77 += $(CONFIG)/obj/log.o
DEPS_77 += $(CONFIG)/obj/server.o
DEPS_77 += $(CONFIG)/bin/libappweb.dylib
DEPS_77 += $(CONFIG)/inc/testAppweb.h
DEPS_77 += $(CONFIG)/obj/testAppweb.o
DEPS_77 += $(CONFIG)/obj/testHttp.o

LIBS_77 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_77 += -lhttp
endif
LIBS_77 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_77 += -lpcre
endif

$(CONFIG)/bin/testAppweb: $(DEPS_77)
	@echo '      [Link] $(CONFIG)/bin/testAppweb'
	$(CC) -o $(CONFIG)/bin/testAppweb -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/testAppweb.o" "$(CONFIG)/obj/testHttp.o" $(LIBPATHS_77) $(LIBS_77) $(LIBS_77) $(LIBS) -lpam 

ifeq ($(ME_COM_CGI),1)
#
#   test-basic.cgi
#
DEPS_78 += $(CONFIG)/inc/mpr.h
DEPS_78 += $(CONFIG)/inc/me.h
DEPS_78 += $(CONFIG)/inc/osdep.h
DEPS_78 += $(CONFIG)/obj/mprLib.o
DEPS_78 += $(CONFIG)/bin/libmpr.dylib
DEPS_78 += $(CONFIG)/inc/pcre.h
DEPS_78 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_78 += $(CONFIG)/bin/libpcre.dylib
endif
DEPS_78 += $(CONFIG)/inc/http.h
DEPS_78 += $(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_78 += $(CONFIG)/bin/libhttp.dylib
endif
DEPS_78 += $(CONFIG)/inc/appweb.h
DEPS_78 += $(CONFIG)/inc/customize.h
DEPS_78 += $(CONFIG)/obj/config.o
DEPS_78 += $(CONFIG)/obj/convenience.o
DEPS_78 += $(CONFIG)/obj/dirHandler.o
DEPS_78 += $(CONFIG)/obj/fileHandler.o
DEPS_78 += $(CONFIG)/obj/log.o
DEPS_78 += $(CONFIG)/obj/server.o
DEPS_78 += $(CONFIG)/bin/libappweb.dylib
DEPS_78 += $(CONFIG)/inc/testAppweb.h
DEPS_78 += $(CONFIG)/obj/testAppweb.o
DEPS_78 += $(CONFIG)/obj/testHttp.o
DEPS_78 += $(CONFIG)/bin/testAppweb

test/web/auth/basic/basic.cgi: $(DEPS_78)
	( \
	cd test; \
	echo "#!`type -p ejs`" >web/auth/basic/basic.cgi ; \
	echo 'print("HTTP/1.0 200 OK\nContent-Type: text/plain\n\n" + serialize(App.env, {pretty: true}) + "\n")' >>web/auth/basic/basic.cgi ; \
	chmod +x web/auth/basic/basic.cgi ; \
	)
endif

ifeq ($(ME_COM_CGI),1)
#
#   test-cache.cgi
#
DEPS_79 += $(CONFIG)/inc/mpr.h
DEPS_79 += $(CONFIG)/inc/me.h
DEPS_79 += $(CONFIG)/inc/osdep.h
DEPS_79 += $(CONFIG)/obj/mprLib.o
DEPS_79 += $(CONFIG)/bin/libmpr.dylib
DEPS_79 += $(CONFIG)/inc/pcre.h
DEPS_79 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_79 += $(CONFIG)/bin/libpcre.dylib
endif
DEPS_79 += $(CONFIG)/inc/http.h
DEPS_79 += $(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_79 += $(CONFIG)/bin/libhttp.dylib
endif
DEPS_79 += $(CONFIG)/inc/appweb.h
DEPS_79 += $(CONFIG)/inc/customize.h
DEPS_79 += $(CONFIG)/obj/config.o
DEPS_79 += $(CONFIG)/obj/convenience.o
DEPS_79 += $(CONFIG)/obj/dirHandler.o
DEPS_79 += $(CONFIG)/obj/fileHandler.o
DEPS_79 += $(CONFIG)/obj/log.o
DEPS_79 += $(CONFIG)/obj/server.o
DEPS_79 += $(CONFIG)/bin/libappweb.dylib
DEPS_79 += $(CONFIG)/inc/testAppweb.h
DEPS_79 += $(CONFIG)/obj/testAppweb.o
DEPS_79 += $(CONFIG)/obj/testHttp.o
DEPS_79 += $(CONFIG)/bin/testAppweb

test/web/caching/cache.cgi: $(DEPS_79)
	( \
	cd test; \
	echo "#!`type -p ejs`" >web/caching/cache.cgi ; \
	echo 'print("HTTP/1.0 200 OK\nContent-Type: text/plain\n\n{number:" + Date().now() + "}\n")' >>web/caching/cache.cgi ; \
	chmod +x web/caching/cache.cgi ; \
	)
endif

ifeq ($(ME_COM_CGI),1)
#
#   test-cgiProgram
#
DEPS_80 += $(CONFIG)/inc/me.h
DEPS_80 += $(CONFIG)/obj/cgiProgram.o
DEPS_80 += $(CONFIG)/bin/cgiProgram

test/cgi-bin/cgiProgram: $(DEPS_80)
	( \
	cd test; \
	cp ../$(CONFIG)/bin/cgiProgram cgi-bin/cgiProgram ; \
	cp ../$(CONFIG)/bin/cgiProgram cgi-bin/nph-cgiProgram ; \
	cp ../$(CONFIG)/bin/cgiProgram 'cgi-bin/cgi Program' ; \
	cp ../$(CONFIG)/bin/cgiProgram web/cgiProgram.cgi ; \
	chmod +x cgi-bin/* web/cgiProgram.cgi ; \
	)
endif

ifeq ($(ME_COM_CGI),1)
#
#   test-testScript
#
DEPS_81 += $(CONFIG)/inc/mpr.h
DEPS_81 += $(CONFIG)/inc/me.h
DEPS_81 += $(CONFIG)/inc/osdep.h
DEPS_81 += $(CONFIG)/obj/mprLib.o
DEPS_81 += $(CONFIG)/bin/libmpr.dylib
DEPS_81 += $(CONFIG)/inc/pcre.h
DEPS_81 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_81 += $(CONFIG)/bin/libpcre.dylib
endif
DEPS_81 += $(CONFIG)/inc/http.h
DEPS_81 += $(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_81 += $(CONFIG)/bin/libhttp.dylib
endif
DEPS_81 += $(CONFIG)/inc/appweb.h
DEPS_81 += $(CONFIG)/inc/customize.h
DEPS_81 += $(CONFIG)/obj/config.o
DEPS_81 += $(CONFIG)/obj/convenience.o
DEPS_81 += $(CONFIG)/obj/dirHandler.o
DEPS_81 += $(CONFIG)/obj/fileHandler.o
DEPS_81 += $(CONFIG)/obj/log.o
DEPS_81 += $(CONFIG)/obj/server.o
DEPS_81 += $(CONFIG)/bin/libappweb.dylib
DEPS_81 += $(CONFIG)/inc/testAppweb.h
DEPS_81 += $(CONFIG)/obj/testAppweb.o
DEPS_81 += $(CONFIG)/obj/testHttp.o
DEPS_81 += $(CONFIG)/bin/testAppweb

test/cgi-bin/testScript: $(DEPS_81)
	( \
	cd test; \
	echo '#!../$(CONFIG)/bin/cgiProgram' >cgi-bin/testScript ; chmod +x cgi-bin/testScript ; \
	)
endif

#
#   installBinary
#
installBinary: $(DEPS_82)
	( \
	cd .; \
	mkdir -p "$(ME_APP_PREFIX)" ; \
	rm -f "$(ME_APP_PREFIX)/latest" ; \
	ln -s "5.0.0-rc0" "$(ME_APP_PREFIX)/latest" ; \
	mkdir -p "$(ME_LOG_PREFIX)" ; \
	chmod 755 "$(ME_LOG_PREFIX)" ; \
	[ `id -u` = 0 ] && chown $(WEB_USER):$(WEB_GROUP) "$(ME_LOG_PREFIX)"; true ; \
	mkdir -p "$(ME_CACHE_PREFIX)" ; \
	chmod 755 "$(ME_CACHE_PREFIX)" ; \
	[ `id -u` = 0 ] && chown $(WEB_USER):$(WEB_GROUP) "$(ME_CACHE_PREFIX)"; true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(CONFIG)/bin/appweb $(ME_VAPP_PREFIX)/bin/appweb ; \
	mkdir -p "$(ME_BIN_PREFIX)" ; \
	rm -f "$(ME_BIN_PREFIX)/appweb" ; \
	ln -s "$(ME_VAPP_PREFIX)/bin/appweb" "$(ME_BIN_PREFIX)/appweb" ; \
	cp $(CONFIG)/bin/appman $(ME_VAPP_PREFIX)/bin/appman ; \
	rm -f "$(ME_BIN_PREFIX)/appman" ; \
	ln -s "$(ME_VAPP_PREFIX)/bin/appman" "$(ME_BIN_PREFIX)/appman" ; \
	cp $(CONFIG)/bin/http $(ME_VAPP_PREFIX)/bin/http ; \
	rm -f "$(ME_BIN_PREFIX)/http" ; \
	ln -s "$(ME_VAPP_PREFIX)/bin/http" "$(ME_BIN_PREFIX)/http" ; \
	if [ "$(ME_COM_ESP)" = 1 ]; then true ; \
	cp $(CONFIG)/bin/esp $(ME_VAPP_PREFIX)/bin/esp ; \
	rm -f "$(ME_BIN_PREFIX)/esp" ; \
	ln -s "$(ME_VAPP_PREFIX)/bin/esp" "$(ME_BIN_PREFIX)/esp" ; \
	fi ; \
	cp $(CONFIG)/bin/libappweb.dylib $(ME_VAPP_PREFIX)/bin/libappweb.dylib ; \
	cp $(CONFIG)/bin/libhttp.dylib $(ME_VAPP_PREFIX)/bin/libhttp.dylib ; \
	cp $(CONFIG)/bin/libmpr.dylib $(ME_VAPP_PREFIX)/bin/libmpr.dylib ; \
	cp $(CONFIG)/bin/libpcre.dylib $(ME_VAPP_PREFIX)/bin/libpcre.dylib ; \
	cp $(CONFIG)/bin/libslink.dylib $(ME_VAPP_PREFIX)/bin/libslink.dylib ; \
	if [ "$(ME_COM_SSL)" = 1 ]; then true ; \
	cp $(CONFIG)/bin/libmprssl.dylib $(ME_VAPP_PREFIX)/bin/libmprssl.dylib ; \
	cp $(CONFIG)/bin/libmod_ssl.dylib $(ME_VAPP_PREFIX)/bin/libmod_ssl.dylib ; \
	fi ; \
	if [ "$(ME_COM_SSL)" = 1 ]; then true ; \
	cp $(CONFIG)/bin/ca.crt $(ME_VAPP_PREFIX)/bin/ca.crt ; \
	fi ; \
	if [ "$(ME_COM_OPENSSL)" = 1 ]; then true ; \
	cp $(CONFIG)/bin/libssl*.dylib* $(ME_VAPP_PREFIX)/bin/libssl*.dylib* ; \
	cp $(CONFIG)/bin/libcrypto*.dylib* $(ME_VAPP_PREFIX)/bin/libcrypto*.dylib* ; \
	fi ; \
	if [ "$(ME_COM_EST)" = 1 ]; then true ; \
	cp $(CONFIG)/bin/libest.dylib $(ME_VAPP_PREFIX)/bin/libest.dylib ; \
	fi ; \
	if [ "$(ME_COM_SQLITE)" = 1 ]; then true ; \
	cp $(CONFIG)/bin/libsql.dylib $(ME_VAPP_PREFIX)/bin/libsql.dylib ; \
	fi ; \
	if [ "$(ME_COM_ESP)" = 1 ]; then true ; \
	cp $(CONFIG)/bin/libmod_esp.dylib $(ME_VAPP_PREFIX)/bin/libmod_esp.dylib ; \
	fi ; \
	if [ "$(ME_COM_CGI)" = 1 ]; then true ; \
	cp $(CONFIG)/bin/libmod_cgi.dylib $(ME_VAPP_PREFIX)/bin/libmod_cgi.dylib ; \
	fi ; \
	if [ "$(ME_COM_EJS)" = 1 ]; then true ; \
	cp $(CONFIG)/bin/libejs.dylib $(ME_VAPP_PREFIX)/bin/libejs.dylib ; \
	cp $(CONFIG)/bin/libmod_ejs.dylib $(ME_VAPP_PREFIX)/bin/libmod_ejs.dylib ; \
	fi ; \
	if [ "$(ME_COM_PHP)" = 1 ]; then true ; \
	cp $(CONFIG)/bin/libmod_php.dylib $(ME_VAPP_PREFIX)/bin/libmod_php.dylib ; \
	fi ; \
	if [ "$(ME_COM_PHP)" = 1 ]; then true ; \
	cp $(CONFIG)/bin/libphp5.dylib $(ME_VAPP_PREFIX)/bin/libphp5.dylib ; \
	fi ; \
	if [ "$(ME_COM_ESP)" = 1 ]; then true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin/.." ; \
	cp $(CONFIG)/paks $(ME_VAPP_PREFIX)/bin/../esp ; \
	fi ; \
	if [ "$(ME_COM_ESP)" = 1 ]; then true ; \
	cp $(CONFIG)/bin/esp.conf $(ME_VAPP_PREFIX)/bin/esp.conf ; \
	fi ; \
	mkdir -p "$(ME_WEB_PREFIX)/bench" ; \
	cp src/server/web/bench/1b.html $(ME_WEB_PREFIX)/bench/1b.html ; \
	cp src/server/web/bench/4k.html $(ME_WEB_PREFIX)/bench/4k.html ; \
	cp src/server/web/bench/64k.html $(ME_WEB_PREFIX)/bench/64k.html ; \
	mkdir -p "$(ME_WEB_PREFIX)" ; \
	cp src/server/web/favicon.ico $(ME_WEB_PREFIX)/favicon.ico ; \
	mkdir -p "$(ME_WEB_PREFIX)/icons" ; \
	cp src/server/web/icons/back.gif $(ME_WEB_PREFIX)/icons/back.gif ; \
	cp src/server/web/icons/blank.gif $(ME_WEB_PREFIX)/icons/blank.gif ; \
	cp src/server/web/icons/compressed.gif $(ME_WEB_PREFIX)/icons/compressed.gif ; \
	cp src/server/web/icons/folder.gif $(ME_WEB_PREFIX)/icons/folder.gif ; \
	cp src/server/web/icons/parent.gif $(ME_WEB_PREFIX)/icons/parent.gif ; \
	cp src/server/web/icons/space.gif $(ME_WEB_PREFIX)/icons/space.gif ; \
	cp src/server/web/icons/text.gif $(ME_WEB_PREFIX)/icons/text.gif ; \
	cp src/server/web/iehacks.css $(ME_WEB_PREFIX)/iehacks.css ; \
	mkdir -p "$(ME_WEB_PREFIX)/images" ; \
	cp src/server/web/images/banner.jpg $(ME_WEB_PREFIX)/images/banner.jpg ; \
	cp src/server/web/images/bottomShadow.jpg $(ME_WEB_PREFIX)/images/bottomShadow.jpg ; \
	cp src/server/web/images/shadow.jpg $(ME_WEB_PREFIX)/images/shadow.jpg ; \
	cp src/server/web/index.html $(ME_WEB_PREFIX)/index.html ; \
	cp src/server/web/min-index.html $(ME_WEB_PREFIX)/min-index.html ; \
	cp src/server/web/print.css $(ME_WEB_PREFIX)/print.css ; \
	cp src/server/web/screen.css $(ME_WEB_PREFIX)/screen.css ; \
	mkdir -p "$(ME_WEB_PREFIX)/test" ; \
	cp src/server/web/test/bench.html $(ME_WEB_PREFIX)/test/bench.html ; \
	cp src/server/web/test/test.cgi $(ME_WEB_PREFIX)/test/test.cgi ; \
	cp src/server/web/test/test.ejs $(ME_WEB_PREFIX)/test/test.ejs ; \
	cp src/server/web/test/test.esp $(ME_WEB_PREFIX)/test/test.esp ; \
	cp src/server/web/test/test.html $(ME_WEB_PREFIX)/test/test.html ; \
	cp src/server/web/test/test.php $(ME_WEB_PREFIX)/test/test.php ; \
	cp src/server/web/test/test.pl $(ME_WEB_PREFIX)/test/test.pl ; \
	cp src/server/web/test/test.py $(ME_WEB_PREFIX)/test/test.py ; \
	mkdir -p "$(ME_WEB_PREFIX)/test" ; \
	cp src/server/web/test/test.cgi $(ME_WEB_PREFIX)/test/test.cgi ; \
	chmod 755 "$(ME_WEB_PREFIX)/test/test.cgi" ; \
	cp src/server/web/test/test.pl $(ME_WEB_PREFIX)/test/test.pl ; \
	chmod 755 "$(ME_WEB_PREFIX)/test/test.pl" ; \
	cp src/server/web/test/test.py $(ME_WEB_PREFIX)/test/test.py ; \
	chmod 755 "$(ME_WEB_PREFIX)/test/test.py" ; \
	mkdir -p "$(ME_ETC_PREFIX)" ; \
	cp src/server/mime.types $(ME_ETC_PREFIX)/mime.types ; \
	cp src/server/self.crt $(ME_ETC_PREFIX)/self.crt ; \
	cp src/server/self.key $(ME_ETC_PREFIX)/self.key ; \
	if [ "$(ME_COM_PHP)" = 1 ]; then true ; \
	cp src/server/php.ini $(ME_ETC_PREFIX)/php.ini ; \
	fi ; \
	cp src/server/appweb.conf $(ME_ETC_PREFIX)/appweb.conf ; \
	cp src/server/sample.conf $(ME_ETC_PREFIX)/sample.conf ; \
	cp src/server/self.crt $(ME_ETC_PREFIX)/self.crt ; \
	cp src/server/self.key $(ME_ETC_PREFIX)/self.key ; \
	echo 'set LOG_DIR "$(ME_LOG_PREFIX)"\nset CACHE_DIR "$(ME_CACHE_PREFIX)"\nDocuments "$(ME_WEB_PREFIX)\nListen 80\n<if SSL_MODULE>\nListenSecure 443\n</if>\n' >$(ME_ETC_PREFIX)/install.conf ; \
	mkdir -p "$(ME_VAPP_PREFIX)/inc" ; \
	cp $(CONFIG)/inc/me.h $(ME_VAPP_PREFIX)/inc/me.h ; \
	mkdir -p "$(ME_INC_PREFIX)/appweb" ; \
	rm -f "$(ME_INC_PREFIX)/appweb/me.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/me.h" "$(ME_INC_PREFIX)/appweb/me.h" ; \
	cp src/paks/osdep/osdep.h $(ME_VAPP_PREFIX)/inc/osdep.h ; \
	rm -f "$(ME_INC_PREFIX)/appweb/osdep.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/osdep.h" "$(ME_INC_PREFIX)/appweb/osdep.h" ; \
	cp src/appweb.h $(ME_VAPP_PREFIX)/inc/appweb.h ; \
	rm -f "$(ME_INC_PREFIX)/appweb/appweb.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/appweb.h" "$(ME_INC_PREFIX)/appweb/appweb.h" ; \
	cp src/customize.h $(ME_VAPP_PREFIX)/inc/customize.h ; \
	rm -f "$(ME_INC_PREFIX)/appweb/customize.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/customize.h" "$(ME_INC_PREFIX)/appweb/customize.h" ; \
	cp src/paks/est/est.h $(ME_VAPP_PREFIX)/inc/est.h ; \
	rm -f "$(ME_INC_PREFIX)/appweb/est.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/est.h" "$(ME_INC_PREFIX)/appweb/est.h" ; \
	cp src/paks/http/http.h $(ME_VAPP_PREFIX)/inc/http.h ; \
	rm -f "$(ME_INC_PREFIX)/appweb/http.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/http.h" "$(ME_INC_PREFIX)/appweb/http.h" ; \
	cp src/paks/mpr/mpr.h $(ME_VAPP_PREFIX)/inc/mpr.h ; \
	rm -f "$(ME_INC_PREFIX)/appweb/mpr.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/mpr.h" "$(ME_INC_PREFIX)/appweb/mpr.h" ; \
	cp src/paks/pcre/pcre.h $(ME_VAPP_PREFIX)/inc/pcre.h ; \
	rm -f "$(ME_INC_PREFIX)/appweb/pcre.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/pcre.h" "$(ME_INC_PREFIX)/appweb/pcre.h" ; \
	cp src/paks/sqlite/sqlite3.h $(ME_VAPP_PREFIX)/inc/sqlite3.h ; \
	rm -f "$(ME_INC_PREFIX)/appweb/sqlite3.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/sqlite3.h" "$(ME_INC_PREFIX)/appweb/sqlite3.h" ; \
	if [ "$(ME_COM_ESP)" = 1 ]; then true ; \
	cp src/paks/esp/esp.h $(ME_VAPP_PREFIX)/inc/esp.h ; \
	rm -f "$(ME_INC_PREFIX)/appweb/esp.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/esp.h" "$(ME_INC_PREFIX)/appweb/esp.h" ; \
	fi ; \
	if [ "$(ME_COM_EJS)" = 1 ]; then true ; \
	cp src/paks/ejs/ejs.h $(ME_VAPP_PREFIX)/inc/ejs.h ; \
	rm -f "$(ME_INC_PREFIX)/appweb/ejs.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/ejs.h" "$(ME_INC_PREFIX)/appweb/ejs.h" ; \
	cp src/paks/ejs/ejs.slots.h $(ME_VAPP_PREFIX)/inc/ejs.slots.h ; \
	rm -f "$(ME_INC_PREFIX)/appweb/ejs.slots.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/ejs.slots.h" "$(ME_INC_PREFIX)/appweb/ejs.slots.h" ; \
	cp src/paks/ejs/ejsByteGoto.h $(ME_VAPP_PREFIX)/inc/ejsByteGoto.h ; \
	rm -f "$(ME_INC_PREFIX)/appweb/ejsByteGoto.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/ejsByteGoto.h" "$(ME_INC_PREFIX)/appweb/ejsByteGoto.h" ; \
	fi ; \
	if [ "$(ME_COM_EJS)" = 1 ]; then true ; \
	cp $(CONFIG)/bin/ejs.mod $(ME_VAPP_PREFIX)/bin/ejs.mod ; \
	fi ; \
	mkdir -p "$(ME_VAPP_PREFIX)/doc/man1" ; \
	cp doc/man/appman.1 $(ME_VAPP_PREFIX)/doc/man1/appman.1 ; \
	mkdir -p "$(ME_MAN_PREFIX)/man1" ; \
	rm -f "$(ME_MAN_PREFIX)/man1/appman.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/appman.1" "$(ME_MAN_PREFIX)/man1/appman.1" ; \
	cp doc/man/appweb.1 $(ME_VAPP_PREFIX)/doc/man1/appweb.1 ; \
	rm -f "$(ME_MAN_PREFIX)/man1/appweb.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/appweb.1" "$(ME_MAN_PREFIX)/man1/appweb.1" ; \
	cp doc/man/appwebMonitor.1 $(ME_VAPP_PREFIX)/doc/man1/appwebMonitor.1 ; \
	rm -f "$(ME_MAN_PREFIX)/man1/appwebMonitor.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/appwebMonitor.1" "$(ME_MAN_PREFIX)/man1/appwebMonitor.1" ; \
	cp doc/man/authpass.1 $(ME_VAPP_PREFIX)/doc/man1/authpass.1 ; \
	rm -f "$(ME_MAN_PREFIX)/man1/authpass.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/authpass.1" "$(ME_MAN_PREFIX)/man1/authpass.1" ; \
	cp doc/man/esp.1 $(ME_VAPP_PREFIX)/doc/man1/esp.1 ; \
	rm -f "$(ME_MAN_PREFIX)/man1/esp.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/esp.1" "$(ME_MAN_PREFIX)/man1/esp.1" ; \
	cp doc/man/http.1 $(ME_VAPP_PREFIX)/doc/man1/http.1 ; \
	rm -f "$(ME_MAN_PREFIX)/man1/http.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/http.1" "$(ME_MAN_PREFIX)/man1/http.1" ; \
	cp doc/man/makerom.1 $(ME_VAPP_PREFIX)/doc/man1/makerom.1 ; \
	rm -f "$(ME_MAN_PREFIX)/man1/makerom.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/makerom.1" "$(ME_MAN_PREFIX)/man1/makerom.1" ; \
	cp doc/man/manager.1 $(ME_VAPP_PREFIX)/doc/man1/manager.1 ; \
	rm -f "$(ME_MAN_PREFIX)/man1/manager.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/manager.1" "$(ME_MAN_PREFIX)/man1/manager.1" ; \
	mkdir -p "$(ME_ROOT_PREFIX)/Library/LaunchDaemons" ; \
	cp package/macosx/com.embedthis.appweb.plist $(ME_ROOT_PREFIX)/Library/LaunchDaemons/com.embedthis.appweb.plist ; \
	[ `id -u` = 0 ] && chown root:wheel "$(ME_ROOT_PREFIX)/Library/LaunchDaemons/com.embedthis.appweb.plist"; true ; \
	chmod 644 "$(ME_ROOT_PREFIX)/Library/LaunchDaemons/com.embedthis.appweb.plist" ; \
	)



#
#   stop
#
DEPS_83 += compile

stop: $(DEPS_83)

#
#   uninstall
#
DEPS_84 += build
DEPS_84 += compile
DEPS_84 += stop

uninstall: $(DEPS_84)
	( \
	cd package; \
	rm -f "$(ME_ETC_PREFIX)/appweb.conf" ; \
	rm -f "$(ME_ETC_PREFIX)/esp.conf" ; \
	rm -f "$(ME_ETC_PREFIX)/mine.types" ; \
	rm -f "$(ME_ETC_PREFIX)/install.conf" ; \
	rm -fr "$(ME_INC_PREFIX)/appweb" ; \
	rm -fr "$(ME_WEB_PREFIX)" ; \
	rm -fr "$(ME_SPOOL_PREFIX)" ; \
	rm -fr "$(ME_CACHE_PREFIX)" ; \
	rm -fr "$(ME_LOG_PREFIX)" ; \
	rm -fr "$(ME_VAPP_PREFIX)" ; \
	rmdir -p "$(ME_ETC_PREFIX)" 2>/dev/null ; true ; \
	rmdir -p "$(ME_WEB_PREFIX)" 2>/dev/null ; true ; \
	rmdir -p "$(ME_LOG_PREFIX)" 2>/dev/null ; true ; \
	rmdir -p "$(ME_SPOOL_PREFIX)" 2>/dev/null ; true ; \
	rmdir -p "$(ME_CACHE_PREFIX)" 2>/dev/null ; true ; \
	rm -f "$(ME_APP_PREFIX)/latest" ; \
	rmdir -p "$(ME_APP_PREFIX)" 2>/dev/null ; true ; \
	)

