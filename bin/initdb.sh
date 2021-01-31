#!/bin/bash

##
# WinStrom database script initializer.
# If system support clusters (Ubuntu/Debian specific), it uses cluster winstrom (if exists, it should be created during installation).
# If not it uses first cluster with PostgreSQL 8.3.
#
# On other systems it uses normal PostgreSQL.
# If PostgreSQL is using other port than 5434 it fixes /etc/winstrom/ws.cenServer.xml
# It configure password authentication for PostgreSQL (changes pg_hba.conf)
#
# Then it creates user 'dba'.
#
#
##

set -e

# enable for DEBUG info
# DEBUG=1

ABRAFLEXI_CFG=local

if [ -f /etc/default/abraflexi ]; then
    . /etc/default/abraflexi
fi

DIR=`dirname $0`


if [ -f $DIR/functions ]; then
    . $DIR/functions
else
    if [ -f /usr/share/abraflexi/bin/functions ]; then
        . /usr/share/abraflexi/bin/functions
    fi
fi

_debug "Current dir is $DIR"
cd /

_debug "ABRAFLEXI_CFG=$ABRAFLEXI_CFG"

if [ "x$ABRAFLEXI_CFG" = "xclient" ]; then
    _debug "Using client only configuration"
    exit 0
fi

# create user WinStrom
if [ -f /etc/debian_version -a -x /usr/sbin/adduser ]; then
    id winstrom >/dev/null 2>/dev/null || /usr/sbin/adduser --quiet --system --home /tmp  --no-create-home --disabled-login --disabled-password winstrom
else
    id winstrom >/dev/null 2>/dev/null || /usr/sbin/useradd -r --home /tmp winstrom
fi

# in some cases (cloud) we want to disable creation of PostgreSQL
if [ x"$DISABLE_DB" = x"1" ]; then
  exit 0
fi

MYLANG=`echo $LANG | cut -c 1-2`

PERMISSION_PROBLEM=0

WinStrom_detectPostgresql
OLD_PORT=5435

# Is WinStrom running on on Debian/Ubuntu on port 5434?
if [ x$HAS_CLUSTERS = x1 ]; then

    if [ x$PG_PORT = x"5434" ]; then
        _debug "Found ABRA Flexi PostgreSQL on wrong port (5434). Moving to 5435"
        OLD_PORT=5434
        cat $CONFIGFILE | cat $CONFIGFILE | sed -e 's/\(port[[:blank:]]*=[[:blank:]]*\)5434/\15435/g' > $CONFIGFILE.new
        mv $CONFIGFILE.new $CONFIGFILE
        $PG_SERVICE stop
        $PG_SERVICE start
    fi
fi

test -f $CONFIGFILE || _quit "Can't find $CONFIGFILE"
test -f $PG_HBA_FILE || _quit "Can't find $PG_HBA_FILE"
_debug "Using $CONFIGFILE"
_debug "Using $PG_HBA_FILE"

# we initialized the database, so we need to reconfigure it to use password (md5) authentication
LEFT="\(host[[:space:]]*all[[:space:]]*all[[:space:]]*\)"
MID4_LOCAL="127.0.0.1\/32"
MID6_LOCAL="::1\/128"
MID4_ANY="0.0.0.0\/0"
MID6_ANY="::\/0"
if [ x"$DBVERSION" = x"8.2" -o  x"$DBVERSION" = x"8.3" ]; then
    # PostgreSQL 8.3 and 8.2
    AUTH_IDENT="ident sameuser"
else
    # PostgreSQL 8.4 and higher
    AUTH_IDENT="ident"
fi
AUTH_MD5="md5"
RIGHT1="\([[:space:]]*\)$AUTH_IDENT"
RIGHT2="\([[:space:]]*\)$AUTH_MD5"
IP4="$MID4_LOCAL"
IP6="$MID6_LOCAL"
OIP4="$MID4_ANY"
OIP6="$MID6_ANY"

_debug "Using $IP4 and $IP6"
cat $PG_HBA_FILE | sed "s/$LEFT\($IP4\)$RIGHT1/\\1$IP4\\3$AUTH_MD5/g"  \
     | sed "s/$LEFT\($IP6\)$RIGHT1/\\1$IP6\\3$AUTH_MD5/g"  \
     | sed "s/$LEFT\($OIP4\)$RIGHT2/\\1$IP4\\3$AUTH_MD5/g"  \
     | sed "s/$LEFT\($OIP6\)$RIGHT2/\\1$IP6\\3$AUTH_MD5/g"  \
    > $PG_HBA_FILE.new

CONFIG_CHANGED=0
/usr/bin/diff -q --ignore-space-change $PG_HBA_FILE $PG_HBA_FILE.new > /dev/null && 2> /dev/null || CONFIG_CHANGED=1

if [ "x$CONFIG_CHANGED" = "x1" ]; then
    _debug "Fixing permission settings"
    mv $PG_HBA_FILE $PG_HBA_FILE.old
    mv $PG_HBA_FILE.new $PG_HBA_FILE
    chown $PG_USER $PG_HBA_FILE
    NEED_RESTART=1
else
    rm "$PG_HBA_FILE.new"
fi


cat $CONFIGFILE | sed "s/#listen_addresses = '\\*'/listen_addresses = 'localhost'/g" > $CONFIGFILE.new
CONFIG_CHANGED=0
/usr/bin/diff -q --ignore-space-change $CONFIGFILE $CONFIGFILE.new > /dev/null && 2> /dev/null || CONFIG_CHANGED=1

if [ "x$CONFIG_CHANGED" = "x1" ]; then
    _debug "Changing listen address for PostgreSQL"
    mv $CONFIGFILE $CONFIGFILE.old
    mv $CONFIGFILE.new $CONFIGFILE
    chown $PG_USER $CONFIGFILE
    NEED_RESTART=1
else
    rm "$CONFIGFILE.new"
fi

# add custom_variable_class = 'afb' for postgresql older than 9.2
if [ "$DBVERSION" = "8.2" -o "$DBVERSION" = "8.3" -o "$DBVERSION" = "8.4" -o "$DBVERSION" = "9.0" -o "$DBVERSION" = "9.1" ]; then
    if OPTION=`grep -E "^\s*custom_variable_classes\s*=\s*'" $CONFIGFILE`; then
        if ! grep -q -E '\<afb\>' <<< "$OPTION"; then
            grep -q "''" <<< "$OPTION" && SEP="" || SEP=","
            sed -i -E "s/^(\s*custom_variable_classes\s*=\s*')(.*')/\1afb$SEP\2/" $CONFIGFILE
            NEED_RESTART=1
        fi
    else
        echo "custom_variable_classes = 'afb'" >> $CONFIGFILE
        NEED_RESTART=1
    fi
fi

# check that we can login to PostgreSQL as user postgres without password
PERMISSION_PROBLEM=1
if [ x"$DBVERSION" = x"8.2" -o  x"$DBVERSION" = x"8.3" ]; then
    # PostgreSQL 8.3 and 8.2
    SAMEUSER="sameuser"
else
    # PostgreSQL 8.4 and higher
    SAMEUSER=""
fi

cat $PG_HBA_FILE | grep -e "^[[:space:]]*local[[:space:]]*all[[:space:]]*postgres[[:space:]]*ident[[:space:]]*$SAMEUSER" >/dev/null 2>/dev/null && PERMISSION_PROBLEM=0
cat $PG_HBA_FILE | grep -e "^[[:space:]]*local[[:space:]]*all[[:space:]]*all[[:space:]]*ident[[:space:]]*$SAMEUSER" >/dev/null 2>/dev/null && PERMISSION_PROBLEM=0
if [ "x$PERMISSION_PROBLEM" = "x1" ]; then
    _debug "Fixing permission problem"
    mv $PG_HBA_FILE $PG_HBA_FILE.abraflexi-save
    echo "
# Added temporarily by ABRA Flexi installer (it is safe to remove)
local   all         postgres                          ident $SAMEUSER
# End
" > $PG_HBA_FILE

    cat $PG_HBA_FILE.abraflexi-save >> $PG_HBA_FILE
    chown $PG_USER $PG_HBA_FILE
    NEED_RESTART=1

    # cleanup on exit
   trap "[ -f $PG_HBA_FILE.abraflexi-save ] && mv $PG_HBA_FILE.abraflexi-save $PG_HBA_FILE && chown $PG_USER $PG_HBA_FILE" EXIT
fi

# Stop PostgreSQL if needed
if [ "x$NEED_RESTART" = "x1" -a "x$RUNNING" = "x1" ]; then
    _debug "Stopping PostgreSQL for restart"
    $PG_SERVICE stop 2> /dev/null > /dev/null || _quit "Can't stop PostgreSQL"
    RUNNING=0
fi

# Start PostgreSQL
WinStrom_startIfNeeded $RUNNING

# Check if PL/Tcl is installed in correct version
# 1. (old way) by testing existency of pltcl_loadmod file
# 2. (new way) by create and call PL/Tcl procedure
if [ ! -f "/usr/lib/postgresql/$DBVERSION/bin/pltcl_loadmod" -a ! -f "/usr/bin/pltcl_loadmod" -a ! -f "/usr/pgsql-$DBVERSION/bin/pltcl_loadmod" ]; then
    PLTCLOK=`/bin/su - $PG_USER -c "/usr/bin/psql $CLUSTERARG -p $PG_PORT -U $PG_USER -q -t -A -f /usr/share/abraflexi/sql/pltcltest"`
    if [ "$PLTCLOK" != "OK" ]; then
        if [ "$MYLANG" = "cs" ]; then
            echo "Není nainstalována správná verze pltcl. Nainstalujte prosím balík postgresql-pltcl-$DBVERSION (resp. postgresql-pltcl)."
        else
            echo "Incorrect version of pltcl found. Please install postgresql-pltcl-$DBVERSION (resp. postgresql-pltcl)."
        fi
        exit 1
    fi
fi

# Fix port in configuration file (it can be changed by user). localhost:5434 is the default. If user changed it, we will not overwrite it.
cat /etc/abraflexi/abraflexi-server.xml | sed -r "s/(port\">)$OLD_PORT/\1$PG_PORT/g" > /etc/abraflexi/abraflexi-server.xml.new
mv /etc/abraflexi/abraflexi-server.xml.new /etc/abraflexi/abraflexi-server.xml

# check if user 'dba' exists.
DBEXIST=`/bin/su - $PG_USER -c "/usr/bin/psql $CLUSTERARG -t -A --command \"select usename from pg_user where usename = 'dba'\" | grep dba > /dev/null 2>/dev/null && echo OK" || true`
if [ "x$DBEXIST" != "xOK" ]; then
  # if not, create it
  /bin/su - $PG_USER -c "echo \"CREATE ROLE dba PASSWORD '7971' CREATEDB SUPERUSER CREATEROLE INHERIT LOGIN;\" | /usr/bin/psql $CLUSTERARG -q --username=$PG_USER --port=$PG_PORT"
fi

# change owner to WinStrom user
chown winstrom /etc/abraflexi/abraflexi-server.xml

# in local mode we run winstrom server as part of winstrom client.
if [ x"$WINSTROM_CFG" = x"local" ]; then
    chmod 0666 /etc/abraflexi/abraflexi-server.xml
else
    chmod 0600 /etc/abraflexi/abraflexi-server.xml
fi


# revert "permission problem fix"
if [ "x$PERMISSION_PROBLEM" = "x1" ]; then
    mv $PG_HBA_FILE.abraflexi-save $PG_HBA_FILE
    chown $PG_USER $PG_HBA_FILE
    _debug "Restarting PostgreSQL after removing temporary fix for permission problem"
    $PG_SERVICE restart 2> /dev/null > /dev/null  || _quit "Can't restart PostgreSQL"
fi

exit 0
