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
	rm -rf tmp/* *.deb
	rm -rf debian/*.substvars debian/*.log debian/*.debhelper debian/files debian/debhelper-build-stamp

deb:
	debuild -i -us -uc -b

.PHONY : install
	