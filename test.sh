#!/bin/bash
vagrant -f destroy
rm ../flexibee-server_*_all.deb
rm flexibee-server_*_all.deb

./build.sh
mv ../flexibee-server*_all.deb .
vagrant up

#curl https://127.0.0.1:5434/status.json
