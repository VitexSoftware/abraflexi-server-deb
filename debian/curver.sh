#!/bin/bash

PACKAGE="flexibee-server"
LATESTURL=`curl -s -q https://www.flexibee.eu/podpora/stazeni-flexibee/stazeni-ekonomickeho-systemu-flexibee-linux/ | grep _all.deb | awk -F'"' '{print $2}' | head -n 1`
LATESTPKG=`basename $LATESTURL`
VERSION=`echo $LATESTPKG | awk -F_ '{print $2}'`

echo $VERSION
