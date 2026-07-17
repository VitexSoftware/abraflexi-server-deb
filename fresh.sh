#!/bin/bash
set -e

PACKAGE="flexibee-server"
LATESTURL=`curl -s -q https://www.flexibee.eu/podpora/stazeni-flexibee/stazeni-ekonomickeho-systemu-flexibee-linux/ | grep _all.deb | awk -F'"' '{print $2}' | head -n 1`
LATESTPKG=`basename $LATESTURL`


VERSION=`echo $LATESTPKG | awk -F_ '{print $2}'`
REVISION=`cat debian/revision | perl -ne 'chomp; print join(".", splice(@{[split/\./,$_]}, 0, -1), map {++$_} pop @{[split/\./,$_]}), "\n";'`

echo XXXXXXXXXXXXXXXXXXXXXXXXXX Building $VERSION

mkdir -p orig

wget -c $LATESTURL -O orig/flexibee_${VERSION}_all.deb

rm -rf debian/tmp data

cd orig
ar -x flexibee_${VERSION}_all.deb
cd ..
#cd debian
#tar xzvf ../orig/control.tar.gz
#cd ..
mkdir debian/tmp
cd debian/tmp
# Vendor .deb's data archive compression has changed over time (gz -> xz);
# auto-detect it instead of hardcoding, and locate whichever member ar
# actually extracted rather than assuming a fixed filename.
data_archive=$(ls ../../orig/data.tar.* | head -n1)
tar xvf "$data_archive"
cd ../..

