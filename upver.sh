#!/bin/bash

PACKAGE="flexibee-server"
LATESTURL=`curl -s -q https://www.flexibee.eu/podpora/stazeni-flexibee/stazeni-ekonomickeho-systemu-flexibee-linux/ | grep _all.deb | awk -F'"' '{print $2}' | head -n 1`
LATESTPKG=`basename $LATESTURL`


VERSION=`echo $LATESTPKG | awk -F_ '{print $2}'`
#REVISION=`cat debian/revision | perl -ne 'chomp; print join(".", splice(@{[split/\./,$_]}, 0, -1), map {++$_} pop @{[split/\./,$_]}), "\n";'`

echo XXXXXXXXXXXXXXXXXXXXXXXXXX Building $VERSION

wget -c $LATESTURL -O orig/flexibee_${VERSION}_all.deb


CHANGES=`git log -n 1 | tail -n+5`
dch --newversion $VERSION  $CHANGES


