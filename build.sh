#!/bin/bash

CHANGES=`git log -n 1 | tail -n+5`
dch -b -v $VERSION --package $PACKAGE $CHANGES

dpkg-buildpackage -i -us -uc -b

