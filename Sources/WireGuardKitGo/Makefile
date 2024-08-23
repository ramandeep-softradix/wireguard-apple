# SPDX-License-Identifier: MIT
#
# Copyright (C) 2018-2019 Jason A. Donenfeld <Jason@zx2c4.com>. All Rights Reserved.

# These are generally passed to us by xcode, but we set working defaults for standalone compilation too.
ARCHS ?= x86_64 arm64
PLATFORM_NAME ?= macosx
SDKROOT ?= $(shell xcrun --sdk $(PLATFORM_NAME) --show-sdk-path)
CONFIGURATION_BUILD_DIR ?= $(CURDIR)/out
CONFIGURATION_TEMP_DIR ?= $(CURDIR)/.tmp

export PATH := $(PATH):/usr/local/bin:/opt/homebrew/bin
export CC ?= clang
LIPO ?= lipo
DESTDIR ?= $(CONFIGURATION_BUILD_DIR)
BUILDDIR ?= $(CONFIGURATION_TEMP_DIR)/wireguard-go-bridge

CFLAGS_PREFIX := $(if $(DEPLOYMENT_TARGET_CLANG_FLAG_NAME),-$(DEPLOYMENT_TARGET_CLANG_FLAG_NAME)=$($(DEPLOYMENT_TARGET_CLANG_ENV_NAME)),) -isysroot $(SDKROOT) -arch
GOARCH_arm64 := arm64
GOARCH_x86_64 := amd64
GOOS_macosx := darwin
GOOS_iphoneos := ios

build: $(DESTDIR)/libwg-go.a
	@echo "Building libwg-go.a"

version-header: $(DESTDIR)/wireguard-go-version.h
	@echo "Generating version header"
	@echo "Version header generated" # Added for additional feedback

#REAL_GOROOT := $(shell go env GOROOT>/dev/null)
#export GOROOT := $(BUILDDIR)/goroot

# Updated Makefile snippet
#REAL_GOROOT := /opt/homebrew/Cellar/go/1.22.6/libexec
#export GOROOT := $(BUILDDIR)/goroot

# Updated Makefile snippet
REAL_GOROOT := $(shell go env GOROOT>/dev/null)
export GOROOT := $(BUILDDIR)/goroot
	
#$(GOROOT)/.prepared:
#	[ -n "$(REAL_GOROOT)" ]
#	mkdir -p "$(GOROOT)"
#	rsync -a --delete --exclude=pkg/obj/go-build "$(REAL_GOROOT)/" "$(GOROOT)/"
#	cat goruntime-*.diff | patch -p1 -f -N -r- -d "$(GOROOT)"
#	touch "$@"
	
	
$(GOROOT)/.prepared:
	@echo "Preparing GOROOT"
	[ -n "$(REAL_GOROOT)" ] || (echo "REAL_GOROOT is not set"; exit 1)
	mkdir -p "$(GOROOT)"
	rsync -a --delete --exclude=pkg/obj/go-build "$(REAL_GOROOT)/" "$(GOROOT)/"
	cat goruntime-*.diff | patch -p1 -f -N -r- -d "$(GOROOT)"
	touch "$@"
	@echo "GOROOT prepared"

define libwg-go-a
$(BUILDDIR)/libwg-go-$(1).a: export CGO_ENABLED := 1
$(BUILDDIR)/libwg-go-$(1).a: export CGO_CFLAGS := $(CFLAGS_PREFIX) $(ARCH)
$(BUILDDIR)/libwg-go-$(1).a: export CGO_LDFLAGS := $(CFLAGS_PREFIX) $(ARCH)
$(BUILDDIR)/libwg-go-$(1).a: export GOOS := $(GOOS_$(PLATFORM_NAME))
$(BUILDDIR)/libwg-go-$(1).a: export GOARCH := $(GOARCH_$(1))
$(BUILDDIR)/libwg-go-$(1).a: $(GOROOT)/.prepared go.mod
	@echo "Building libwg-go-$(1).a for $(ARCH)"
	go build -ldflags=-w -trimpath -v -o "$(BUILDDIR)/libwg-go-$(1).a" -buildmode c-archive
	rm -f "$(BUILDDIR)/libwg-go-$(1).h"
	@echo "libwg-go-$(1).a built"
endef
$(foreach ARCH,$(ARCHS),$(eval $(call libwg-go-a,$(ARCH))))

$(DESTDIR)/wireguard-go-version.h: go.mod $(GOROOT)/.prepared
	@echo "Generating wireguard-go-version.h"
	sed -E -n 's/.*golang\.zx2c4\.com\/wireguard +v[0-9.]+-[0-9]+-([0-9a-f]{8})[0-9a-f]{4}.*/#define WIREGUARD_GO_VERSION "\1"/p' "$<" > "$@"
	@echo "wireguard-go-version.h generated"

$(DESTDIR)/libwg-go.a: $(foreach ARCH,$(ARCHS),$(BUILDDIR)/libwg-go-$(ARCH).a)
	@echo "Creating libwg-go.a"
	@mkdir -vp "$(DESTDIR)"
	$(LIPO) -create -output "$@" $^
	@echo "libwg-go.a created"

clean:
	@echo "Cleaning up"
	rm -rf "$(BUILDDIR)" "$(DESTDIR)/libwg-go.a" "$(DESTDIR)/wireguard-go-version.h"
	@echo "Cleaned up"

install: build
	@echo "Install step"

.PHONY: clean build version-header install
