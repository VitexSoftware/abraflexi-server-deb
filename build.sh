#!/bin/bash

PACKAGE="flexibee-server"

LATESTURL=`curl -q https://www.flexibee.eu/podpora/stazeni-flexibee/stazeni-ekonomickeho-systemu-flexibee-linux/ | grep _all.deb | awk -F'"' '{print $6}' | head -n 1`
LATESTPKG=`basename $LATESTURL`

wget -c $LATESTURL

VERSION=`echo $LATESTPKG | awk -F_ '{print $2}'`
REVISION=`cat debian/revision | perl -ne 'chomp; print join(".", splice(@{[split/\./,$_]}, 0, -1), map {++$_} pop @{[split/\./,$_]}), "\n";'`

echo XXXXXXXXXXXXXXXXXXXXXXXXXX Building $VERSION-$REVISION 

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

CHANGES=`git log -n 1 | tail -n+5`
dch -b -v $VERSION-$REVISION --package $PACKAGE $CHANGES

dpkg-buildpackage -i -us -uc -b

rc=$?;
if [[ $rc != 0 ]];
then
    echo Error: $rc
    exit $rc;
fi
rm -rf data

echo $VERSION > debian/lastversion
echo $REVISION > debian/revision

echo XXXXXXXXXXXXXXXXXXXXXXXXXX Building $VERSION-$REVISION done

