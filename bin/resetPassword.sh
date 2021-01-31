#!/bin/bash
export PGHOST=localhost
export PGDATABASE=centralServer
export PGUSER=dba
export PGPASSWORD=7971
export PGPORT=5435
echo -e "\nReset hesla uživatele v ABRA Flexi"
echo -e "***************************************\n"
echo -e "Seznam uživatelů v databázi:"
psql -t -A -R ", " -c "select jmeno from csuzivatel order by jmeno"

echo -e "\n"

while [[ -z "$FB_USERNAME" ]]
do
  read -rp "Resetovat heslo pro uživatele: " FB_USERNAME
done


TEST=$(psql -A -t -c "select jmeno from csuzivatel where jmeno = '${FB_USERNAME}'")

if [ "$TEST" != "$FB_USERNAME" ]; then
  echo -e "\nUživatel '${FB_USERNAME}' neexistuje.\n"
  exit 1;
fi

NEW_PW="sha256:d0a3e07164:a7bd05fbd67d76466272738db8cdf6abc14e54d5b4040af641ad2dae1c91d4f8"
if psql -c "update csuzivatel set heslo = '${NEW_PW}' where jmeno = '${FB_USERNAME}'"; then
  echo -e "\nNové heslo pro uživatele '${FB_USERNAME}': UiGi7uhi\n"
else
  echo -e "\nHeslo uživatele '${FB_USERNAME}' se nepodařilo změnit.\n"
fi
