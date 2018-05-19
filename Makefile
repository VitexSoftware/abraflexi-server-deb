all: fresh build install

fresh:
	git pull
	./fresh.sh

install: 
	echo install
	
build:
	echo build

clean:
	rm -rf debian/flexibee-server debian/flexibee-server-backup
	rm -rf debian/*.substvars debian/*.log debian/*.debhelper debian/files debian/debhelper-build-stamp debian/changelog.dch
	rm -rf tmp/* *.deb
	rm -f package.box

image:
	docker build -t vitexsoftware/flexibee-server .

deb:
	debuild -i -us -uc -b

.PHONY : install
	
