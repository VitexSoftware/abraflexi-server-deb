#!/bin/bash

PACKAGE="flexibee-server"
LATESTURL=`curl -q https://www.flexibee.eu/podpora/stazeni-flexibee/stazeni-ekonomickeho-systemu-flexibee-linux/ | grep _all.deb | awk -F'"' '{print $6}' | head -n 1`
LATESTPKG=`basename $LATESTURL`


VERSION=`echo $LATESTPKG | awk -F_ '{print $2}'`
REVISION=`cat debian/revision | perl -ne 'chomp; print join(".", splice(@{[split/\./,$_]}, 0, -1), map {++$_} pop @{[split/\./,$_]}), "\n";'`

echo XXXXXXXXXXXXXXXXXXXXXXXXXX Building $VERSION

wget -c $LATESTURL -O orig/flexibee_${VERSION}_all.deb


rm -rf debian/tmp data

mkdir -p orig
cd orig
ar -x flexibee_${VERSION}_all.deb
cd ..
#cd debian
#tar xzvf ../orig/control.tar.gz
#cd ..
mkdir debian/tmp
cd debian/tmp
tar xzvf ../../orig/data.tar.gz
cd ../..

CHANGES=`git log -n 1 | tail -n+5`
dch --newversion $VERSION  $CHANGES


