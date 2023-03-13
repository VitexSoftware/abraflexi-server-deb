# AbraFlexi Server - deb balíček

![FlexiBee Server logo](https://raw.githubusercontent.com/VitexSoftware/flexibee-server-deb/master/flexibee-server.png)

[EN] Debian Package for server-only deploy of czech accounting system FlexiBee

Balíček je uzpůsoben k běhu na serveru bez závislosti na grafickém prostředí.
Generován je z původního instalačního balíku poskytovaným společností Abra:
https://www.flexibee.eu/podpora/stazeni-flexibee/stazeni-ekonomickeho-systemu-flexibee-linux/

**Soubory .jar aplikace FlexiBee nejsou nijak modifikovány**

Kromě toho obsahuje jěště tyto dodatečné opravy a vylepšení.

  * doplněna podpora systemd
  * doplněna podpora pro službu Avahi
  * doplněn nástroj pro kontrolu licence
  * opravena chyba s java-8-openjdk-amd64 accessibility
  * speciální balík **flexibee-server-backup** pro denní zálohy do souboru
  * položka v menu a ikona pro webové rozhraní jako aplikaci

Instalace
---------

Pro Debian 10,11 či Ubuntu 20.04,22.04 prosím použijte [repozitář](http://vitexsoftware.com/repos.php):

    wget -O - http://repo.vitexsoftware.cz/info@vitexsoftware.cz.gpg.key|sudo apt-key add -
    echo deb http://repo.vitexsoftware.cz/ stable main > /etc/apt/sources.list.d/vitexsoftware.list
    apt update
    apt install flexibee-server flexibee-server-backup


Pravidelná aktualizace pak vypadá, takto:

```
vitex@flexibee-dev ~ % sudo apt upgrade   
Načítají se seznamy balíků… Hotovo
Vytváří se strom závislostí… Hotovo
Načítají se stavové informace… Hotovo
Propočítává se aktualizace… Hotovo
Následující balíky budou aktualizovány:
  abraflexi-server abraflexi-server-backup
2 aktualizováno, 0 nově instalováno, 0 k odstranění a 0 neaktualizováno.
Nutno stáhnout 176 MB archivů.
Po této operaci bude na disku použito dalších 226 kB.
Chcete pokračovat? [Y/n] 
Stahuje se:1 http://repo.vitexsoftware.com bullseye/main amd64 abraflexi-server-backup all 2023.2.1~bullseye~24 [2 476 B]
Stahuje se:2 http://repo.vitexsoftware.com bullseye/main amd64 abraflexi-server all 2023.2.1~bullseye~24 [176 MB]
Staženo 176 MB za 2s (92,8 MB/s)           
Načítám soubory se změnami... Hotovo
Přednastavují se balíky…
(Načítá se databáze … nyní je nainstalováno 84419 souborů a adresářů.)
Připravuje se nahrazení …/abraflexi-server-backup_2023.2.1~bullseye~24_all.deb …
Rozbaluje se abraflexi-server-backup (2023.2.1~bullseye~24) přes (2023.1.5~bullseye~23) …
Připravuje se nahrazení …/abraflexi-server_2023.2.1~bullseye~24_all.deb …
Rozbaluje se abraflexi-server (2023.2.1~bullseye~24) přes (2023.1.5~bullseye~23) …
Nastavuje se balík abraflexi-server (2023.2.1~bullseye~24) …
Připravuji databázi PostgreSQL pro systém AbraFlexi ...
  Použiji existující databázi ...
Nastavuje se balík abraflexi-server-backup (2023.2.1~bullseye~24) …
Zpracovávají se spouštěče pro balík mailcap (3.69) …
Zpracovávají se spouštěče pro balík ufw (0.36-7.1) …
vitex@flexibee-dev ~ % 

```



Přihlášení
----------

Po dokončení instalace je možné se k serveru přihlásit protokolem https na portu 
5434 - např.: https://192.168.1.32:5434/



Následující balíky již nejsou potřeba:


    * at-spi2-core
    * dconf-gsettings-backend
    * dconf-service
    * glib-networking
    * glib-networking-common
    * glib-networking-services
    * gsettings-desktop-schemas
    * libasyncns0
    * libatk-bridge2.0-0
    * libatk-wrapper-java
    * libatk-wrapper-java-jni
    * libatspi2.0-0
    * libcairo-gobject2
    * libcolord2
    * libdconf1
    * libdrm-amdgpu1
    * libdrm-intel1
    * libdrm-nouveau2
    * libdrm-radeon1
    * libdrm2
    * libegl1-mesa
    * libepoxy0
    * libflac8
    * libfontenc1
    * libgbm1
    * libgif7
    * libgl1-mesa-dri
    * libgl1-mesa-glx
    * libglapi-mesa
    * libgtk-3-0
    * libgtk-3-bin
    * libgtk-3-common
    * libice6
    * libjson-glib-1.0-0
    * libjson-glib-1.0-common
    * libllvm3.9
    * libpciaccess0
    * libproxy1v5
    * libpulse0
    * librest-0.7-0
    * libsm6
    * libsndfile1
    * libsoup-gnome2.4-1
    * libsoup2.4-1
    * libtxc-dxtn-s2tc
    * libvorbisenc2
    * libwayland-client0
    * libwayland-cursor0
    * libwayland-egl1-mesa
    * libwayland-server0
    * libx11-xcb1
    * libxaw7
    * libxcb-dri2-0
    * libxcb-dri3-0
    * libxcb-glx0
    * libxcb-present0
    * libxcb-shape0
    * libxcb-sync1
    * libxcb-xfixes0
    * libxft2
    * libxkbcommon0
    * libxmu6
    * libxpm4
    * libxshmfence1
    * libxt6
    * libxv1
    * libxxf86dga1
    * libxxf86vm1
    * openjdk-8-jre
    * x11-utils
