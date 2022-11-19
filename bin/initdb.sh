#!/bin/bash

##
# WinStrom database script initializer.
# If system support clusters (Ubuntu/Debian specific), it uses cluster winstrom (if exists, it should be created during installation).
# If not it uses first cluster with the oldest supported PostgreSQL version.
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

FLEXIBEE_CFG=local

if [ -f /etc/default/flexibee ]; then
    . /etc/default/flexibee
fi

DIR=$(dirname "$0")


if [ -f "$DIR"/functions ]; then
    . "$DIR"/functions
else
    if [ -f /usr/share/flexibee/bin/functions ]; then
        . /usr/share/flexibee/bin/functions
    fi
fi

_debug "Current dir is $DIR"
cd /

_debug "FLEXIBEE_CFG=$FLEXIBEE_CFG"

if [ "x$FLEXIBEE_CFG" = "xclient" ]; then
    _debug "Using client only configuration"
    exit 0
fi

# create user WinStrom
if [ -f /etc/debian_version ] && [ -x /usr/sbin/adduser ]; then
    id winstrom >/dev/null 2>&1 || /usr/sbin/adduser --quiet --system --home /tmp --no-create-home --disabled-login --disabled-password winstrom
else
    id winstrom >/dev/null 2>&1 || /usr/sbin/useradd -r --home /tmp winstrom
fi

# in some cases (cloud) we want to disable creation of PostgreSQL
if [ x"$DISABLE_DB" = x"1" ]; then
  exit 0
fi

MYLANG=$(echo "$LANG" | cut -c 1-2)

PERMISSION_PROBLEM=0

WinStrom_detectPostgresql
OLD_PORT=5435

test -f "$CONFIGFILE" || _quit "Can't find $CONFIGFILE"
test -f "$PG_HBA_FILE" || _quit "Can't find $PG_HBA_FILE"
_debug "Using $CONFIGFILE"
_debug "Using $PG_HBA_FILE"

# Is WinStrom running on on Debian/Ubuntu on port 5434?
if [ "x$HAS_CLUSTERS" = "x1" ]; then

    if [ "x$PG_PORT" = "x5434" ]; then
        _debug "Found ABRA Flexi PostgreSQL on wrong port (5434). Moving to 5435"
        OLD_PORT=5434
        sed -i -e 's/\(port[[:blank:]]*=[[:blank:]]*\)5434/\15435/g' "$CONFIGFILE"
        $PG_SERVICE stop
        $PG_SERVICE start
    fi
fi

# we initialized the database, so we need to reconfigure it to use password (md5) authentication
LEFT="\(host[[:space:]]*all[[:space:]]*all[[:space:]]*\)"
MID4_LOCAL="127.0.0.1\/32"
MID6_LOCAL="::1\/128"
MID4_ANY="0.0.0.0\/0"
MID6_ANY="::\/0"
AUTH_IDENT="ident"
AUTH_MD5="md5"
AUTH_SCRAM="scram-sha-256"
RIGHT1="\([[:space:]]*\)\($AUTH_SCRAM\|$AUTH_IDENT\)"
RIGHT2="\([[:space:]]*\)\($AUTH_SCRAM\|$AUTH_MD5\)"
IP4="$MID4_LOCAL"
IP6="$MID6_LOCAL"
OIP4="$MID4_ANY"
OIP6="$MID6_ANY"

_debug "Using $IP4 and $IP6"
sed -e "s/$LEFT\($IP4\)$RIGHT1/\\1$IP4\\3$AUTH_MD5/g"  \
    -e "s/$LEFT\($IP6\)$RIGHT1/\\1$IP6\\3$AUTH_MD5/g"  \
    -e "s/$LEFT\($OIP4\)$RIGHT2/\\1$IP4\\3$AUTH_MD5/g"  \
    -e "s/$LEFT\($OIP6\)$RIGHT2/\\1$IP6\\3$AUTH_MD5/g"  \
    "$PG_HBA_FILE" > "$PG_HBA_FILE.new"

if ! /usr/bin/diff -q --ignore-space-change "$PG_HBA_FILE" "$PG_HBA_FILE.new" > /dev/null; then
    _debug "Fixing permission settings"
    mv "$PG_HBA_FILE" "$PG_HBA_FILE".old
    mv "$PG_HBA_FILE".new "$PG_HBA_FILE" && chown "$PG_USER" "$PG_HBA_FILE"
    NEED_RESTART=1
else
    rm "$PG_HBA_FILE.new"
fi


sed -E -e "s/^#(listen_addresses\s*=\s*)'\\*'/\1'localhost'/" \
    -e "s/^(password_encryption\s*=\s*)$AUTH_SCRAM/\1$AUTH_MD5/" "$CONFIGFILE" > "$CONFIGFILE.new"
if ! /usr/bin/diff -q "$CONFIGFILE" "$CONFIGFILE.new" > /dev/null; then
    _debug "Fixing database configuration"
    mv "$CONFIGFILE" "$CONFIGFILE".old
    mv "$CONFIGFILE".new "$CONFIGFILE" && chown "$PG_USER" "$CONFIGFILE"
    NEED_RESTART=1
else
    rm "$CONFIGFILE.new"
fi

# check that we can login to PostgreSQL as user postgres without password
PERMISSION_PROBLEM=1
grep -q -e "^[[:space:]]*local[[:space:]]*all[[:space:]]*\(postgres\|all\)[[:space:]]*\(peer\|$AUTH_IDENT\)" \
    "$PG_HBA_FILE" && PERMISSION_PROBLEM=0
if [ "x$PERMISSION_PROBLEM" = "x1" ]; then
    _debug "Fixing permission problem"
    mv "$PG_HBA_FILE" "$PG_HBA_FILE".flexibee-save
    echo "
# Added temporarily by ABRA Flexi installer (it is safe to remove)
local   all         postgres                          $AUTH_IDENT
# End
" > "$PG_HBA_FILE"

    cat "$PG_HBA_FILE".flexibee-save >> "$PG_HBA_FILE"
    chown "$PG_USER" "$PG_HBA_FILE"
    NEED_RESTART=1

    # cleanup on exit
   trap "[ -f $PG_HBA_FILE.flexibee-save ] && mv $PG_HBA_FILE.flexibee-save $PG_HBA_FILE && chown $PG_USER $PG_HBA_FILE" EXIT
fi

# Stop PostgreSQL if needed
if [ "x$NEED_RESTART" = "x1" ] && [ "x$RUNNING" = "x1" ]; then
    _debug "Stopping PostgreSQL for restart"
    $PG_SERVICE stop > /dev/null 2>&1 || _quit "Can't stop PostgreSQL"
    RUNNING=0
fi

# Start PostgreSQL
WinStrom_startIfNeeded $RUNNING

# Fix port in configuration file (it can be changed by user). localhost:5434 is the default. If user changed it, we will not overwrite it.
sed -i -r "s/(port\">)$OLD_PORT/\1$PG_PORT/g" /etc/flexibee/flexibee-server.xml

# check if user 'dba' exists.
DBEXIST=$(/bin/su - "$PG_USER" -c "/usr/bin/psql $CLUSTERARG -t -A --command \"select usename from pg_user where usename = 'dba'\" | grep dba > /dev/null 2>&1 && echo OK" || true)
if [ "x$DBEXIST" != "xOK" ]; then
  # if not, create it
  /bin/su - "$PG_USER" -c "echo \"CREATE ROLE dba PASSWORD '7971' CREATEDB SUPERUSER CREATEROLE INHERIT LOGIN;\" | /usr/bin/psql $CLUSTERARG -q --username=$PG_USER --port=$PG_PORT"
fi

# change owner to WinStrom user
chown winstrom /etc/flexibee/flexibee-server.xml

# in local mode we run winstrom server as part of winstrom client.
if [ x"$WINSTROM_CFG" = x"local" ]; then
    chmod 0666 /etc/flexibee/flexibee-server.xml
else
    chmod 0600 /etc/flexibee/flexibee-server.xml
fi


# revert "permission problem fix"
if [ "x$PERMISSION_PROBLEM" = "x1" ]; then
    mv "$PG_HBA_FILE".flexibee-save "$PG_HBA_FILE" && chown "$PG_USER" "$PG_HBA_FILE"
    _debug "Restarting PostgreSQL after removing temporary fix for permission problem"
    $PG_SERVICE restart > /dev/null 2>&1 || _quit "Can't restart PostgreSQL"
fi

exit 0
