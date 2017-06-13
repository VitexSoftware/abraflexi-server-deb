#!/bin/bash
rm ../flexibee-server.*
./build.sh
mv ../flexibee-server
vagrant up
