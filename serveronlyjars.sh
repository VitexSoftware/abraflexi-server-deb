#!/bin/bash
BASEDIR="data/usr/share/flexibee/lib/"
SERVERFILES="${BASEDIR}server.txt"

for jarfile in ${BASEDIR}*.jar
do
    fbname=$(basename $jarfile .jar)
    if [ `cat $SERVERFILES | grep $fbname | wc -l` == '0' ];
    then
	rm -f $jarfile
	echo nonserver jar deleted  $jarfile
    fi

done
