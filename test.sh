#!/bin/bash
vagrant -f destroy
rm ../abraflexi-server_*_all.deb
rm abraflexi-server_*_all.deb

./build.sh
mv ../abraflexi-server*_all.deb .
vagrant up

#curl https://127.0.0.1:5434/status.json
