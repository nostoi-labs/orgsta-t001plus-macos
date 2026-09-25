# ORGSTA T001Plus native arm64 CUPS driver for macOS
#   make            build build/rastertotspl (universal arm64 + x86_64) from upstream source
#   make pkg        build the .pkg installer (unsigned unless SIGN_ID/INSTALLER_ID are set)
#   make notarize   sign + notarize + staple (needs Developer ID certs + ASC API key)
#   make clean
VERSION ?= 1.0.0
CC      ?= cc
CFLAGS  ?= -O2 -Wall -Wextra -mmacosx-version-min=11.0
LDLIBS   = -lcups -lcupsimage
ARCHS    = -arch arm64 -arch x86_64
SIGN_ID       ?= $(shell security find-identity -v -p codesigning 2>/dev/null | awk -F'"' '/Developer ID Application/ {print $$2; exit}')
INSTALLER_ID  ?= $(shell security find-identity -v 2>/dev/null | awk -F'"' '/Developer ID Installer/ {print $$2; exit}')
BIN = build/rastertotspl
PKG = build/ORGSTA-T001Plus-macOS-$(VERSION).pkg

all: $(BIN)

$(BIN): upstream/src/rastertovevor.c
	mkdir -p build
	$(CC) $(ARCHS) $(CFLAGS) -o $@ $< $(LDLIBS)
ifneq ($(SIGN_ID),)
	codesign --force --options runtime --timestamp --sign "$(SIGN_ID)" $@
else
	codesign --force --sign - $@
endif
	lipo -archs $@

pkg: $(BIN)
	VERSION=$(VERSION) INSTALLER_ID="$(INSTALLER_ID)" scripts/build-pkg.sh

notarize: pkg
	scripts/notarize.sh "$(PKG)"

clean:
	rm -rf build

.PHONY: all pkg notarize clean
