#!/bin/bash

PACKAGE="flexibee-server"
LATESTURL=`curl -s -q https://www.flexibee.eu/podpora/stazeni-flexibee/stazeni-ekonomickeho-systemu-flexibee-linux/ | grep _all.deb | awk -F'"' '{print $2}' | head -n 1`
echo Current Upstream: $LATESTURL

LATESTPKG=`basename $LATESTURL`


LATESTPKG=`basename ${LATESTURL}`
VERSION=`echo $LATESTPKG | awk -F_ '{print $2}'`


if [ -f $LATESTPKG ]; 
then
    echo use existing $LATESTPKG
else
    wget -c $LATESTURL
#    CHANGES=`git log -n 1 | tail -n+5`
#    dch --newversion $VERSION  $CHANGES
fi

rm -rf tmp debian/data data

mkdir tmp
cd tmp
ar -x ../flexibee_${VERSION}_all.deb
cd ..
#cd debian
#tar xzvf ../tmp/control.tar.gz
#cd ..
mkdir data
cd data
tar xzvf ../tmp/data.tar.gz
cd ..



