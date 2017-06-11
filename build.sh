#!/bin/bash

wget -c http://download.flexibee.eu.s3-website.eu-central-1.amazonaws.com/download/2017.1/2017.1.11/flexibee_2017.1.11_all.deb
VERSION=`ls flexibee*.deb | awk -F_ '{print $2}'`
echo $VERSION

rm -rf tmp debian/data

mkdir tmp
cd tmp
ar -x ../flexibee_${VERSION}_all.deb
cd ..
cd debian
tar xzvf ../tmp/control.tar.gz
cd ..
mkdir data
cd data
tar xzvf ../tmp/data.tar.gz
cd ..

zcat data/usr/share/doc/flexibee/changelog.gz > debian/changelog
mv debian/control debian/control.tmp

sed -i '/Package:/c\Package: flexibee-server' debian/control.tmp
sed -i -e 's/flexibee-client,/flexibee-client,flexibee,/g' debian/control.tmp
sed -i '/Version/d' debian/control.tmp
sed -i '/Maintainer/d' debian/control.tmp
sed -i '/Installed-Size/d' debian/control.tmp

cp debian/control.base debian/control
cat debian/control.tmp >> debian/control
rm debian/control.tmp

rm -rf data/usr/bin


debuild -i -us -uc -b


