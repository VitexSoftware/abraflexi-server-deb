#!/bin/bash
vagrant -f destroy
rm ../flexibee-server_*_all.deb
rm flexibee-server_*_all.deb

./build.sh
mv ../flexibee-server_*_all.deb .
vagrant up
