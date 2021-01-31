all:

dimage: deb
	docker build -t vitexsoftware/abraflexi-server .

drun: dimage
	docker run  -dit --name AbraFlexiServer -p 8080:80 vitexsoftware/abraflexi-server
	sensible-browser https://127.0.0.1:5434/login-logout/first-user-form


vagrant: deb
	vagrant destroy -f
	vagrant up
	sensible-browser https://127.0.0.1:5434/login-logout/first-user-form

deb:
	debuild -i -us -uc -b
	mv ../abraflexi-server_*_all.deb .

