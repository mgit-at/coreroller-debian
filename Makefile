export GOROOT := /opt/go
export GOPATH := $(shell pwd)/gopath
export SRCDIR := $(shell pwd)/src
export PATH   := $(GOROOT)/bin:$(PATH)
export BRANCH := offline-sync

all: build

.coreroller.cloned:
	git clone https://github.com/mgit-at/coreroller $(SRCDIR)
	git -C $(SRCDIR) branch --track $(BRANCH) origin/$(BRANCH)
	git -C $(SRCDIR) checkout $(BRANCH)
	touch $@

build: .coreroller.cloned
	mkdir -p $(GOPATH)
	go get -v -u github.com/constabulary/gb/...
	git -C 	$(SRCDIR) pull
	cd $(SRCDIR)/backend/ && $(GOPATH)/bin/gb build cmd/rollerd && $(GOPATH)/bin/gb build cmd/initdb
	mv $(SRCDIR)/backend/bin/initdb $(SRCDIR)/backend/bin/coreroller-initdb
	cd $(SRCDIR)/frontend && npm install && npm run build
	find $(SRCDIR)/frontend/built -type f -exec chmod -x {} \;

clean:
	rm -rf $(SRCDIR)
	rm -f .coreroller.cloned

build-dep:
	apt-get update
	apt-get upgrade
	apt-get install eatmydata debhelper dh-systemd git nodejs-legacy npm

deb:
	eatmydata debuild -I -us -uc

.PHONY: all clean deb
