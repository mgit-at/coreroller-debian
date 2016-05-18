#export GOROOT := /opt/go
export GOPATH := $(shell pwd)/gopath
export SRCDIR := $(shell pwd)/src
export PATH   := $(GOROOT)/bin:$(PATH)
#export BRANCH := master

all: build

.coreroller.cloned:
	git clone https://github.com/coreroller/coreroller $(SRCDIR)
#	git -C $(SRCDIR) checkout -b $(BRANCH)
	touch $@

build: .coreroller.cloned
	mkdir -p $(GOPATH)
	go get -v -u github.com/constabulary/gb/...
	git -C 	$(SRCDIR) pull
	cd $(SRCDIR)/backend/ && $(GOPATH)/bin/gb build cmd/rollerd && $(GOPATH)/bin/gb build cmd/initdb
	mv $(SRCDIR)/backend/bin/initdb $(SRCDIR)/backend/bin/coreroller-initdb

clean:
	rm -rf $(SRCDIR)
	rm -f .coreroller.cloned

deb:
	eatmydata debuild -I -us -uc

.PHONY: all clean deb
