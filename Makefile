#export GOROOT := /opt/go
TAG    := 1.0.5



export GOPATH := $(shell pwd)/gopath
SRCDIR := $(shell pwd)/src
GO := go
ifdef GOROOT
GO := $(GOROOT)/bin/go
endif

all: build

.coreroller.cloned:
	git clone https://github.com/coreroller/coreroller $(SRCDIR)
	git -C $(SRCDIR) checkout tags/$(TAG)
	touch $@

build: build-backend build-frontend

build-backend: .coreroller.cloned
	mkdir -p $(GOPATH)
	$(GO) get -v -u github.com/constabulary/gb/...
	cd $(SRCDIR)/backend/ && $(GOPATH)/bin/gb build cmd/rollerd && $(GOPATH)/bin/gb build cmd/initdb
	mv $(SRCDIR)/backend/bin/initdb $(SRCDIR)/backend/bin/coreroller-initdb

build-frontend: .coreroller.cloned
	cd $(SRCDIR)/frontend && npm install && npm run build
	find $(SRCDIR)/frontend/built -type f -exec chmod -x {} \;

clean:
	rm -rf $(GOPATH)
	rm -rf $(SRCDIR)
	rm -f .coreroller.cloned

build-dep:
	apt-get update
	apt-get upgrade
	apt-get install eatmydata debhelper dh-systemd git nodejs-legacy npm

deb:
	eatmydata debuild -I -us -uc

.PHONY: all clean deb
