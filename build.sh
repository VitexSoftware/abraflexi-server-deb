#!/bin/bash

PACKAGE="flexibee-server"
wget -c http://download.flexibee.eu.s3-website.eu-central-1.amazonaws.com/download/2017.1/2017.1.11/flexibee_2017.1.11_all.deb
VERSION=`ls flexibee*.deb | awk -F_ '{print $2}'`
REVISION=`cat debian/revision | perl -ne 'chomp; print join(".", splice(@{[split/\./,$_]}, 0, -1), map {++$_} pop @{[split/\./,$_]}), "\n";'`

echo $VERSION-$REVISION

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

cp -f debian/control.base debian/control


cp debian/control.base debian/control
cat debian/control.tmp >> debian/control
rm debian/control.tmp

CHANGES=`git log -n 1 | tail -n+5`
dch -b -v $VERSION-$REVISION --package $PACKAGE $CHANGES


debuild -i -us -uc -b

rc=$?;
if [[ $rc != 0 ]];
then
    echo Error: $rc
    exit $rc;
fi
rm -rf data

echo $VERSION > debian/lastversion
echo $REVISION > debian/revision
