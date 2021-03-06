# flexibee-server - deb balíček

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

Pro Debian či Ubuntu prosím použijte [repozitář](http://vitexsoftware.cz/repos.php):

```shell
sudo apt install lsb-release wget
echo "deb http://repo.vitexsoftware.cz $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/vitexsoftware.list
sudo wget -O /etc/apt/trusted.gpg.d/vitexsoftware.gpg http://repo.vitexsoftware.cz/keyring.gpg
sudo apt update
sudo apt install flexibee-server-backup flexibee-server
```

Přihlášení
----------

Po dokončení instalace je možné se k serveru přihlásit protokolem https na portu 
5434 - např.: https://192.168.1.32:5434/



Problémy při instalaci
----------------------

Pokud se při po aktualizaci z Jessie na Stretch objeví při pokusu o instalací balíku 
flexibee-server hláška: 

**Není nainstována správná verze pltcl. Nainstalujte prosím balík postgresql-pltcl-9.4 resp. postgresql-pltcl
dpkg: chyba při zpracovávání balíku flexibee-server (--configure):**

bude pořeba stahnout tyto dva blaíky:

    wget http://security.debian.org/debian-security/pool/updates/main/p/postgresql-9.4/postgresql-9.4_9.4.12-0+deb8u1_amd64.deb
    wget http://security.debian.org/debian-security/pool/updates/main/p/postgresql-9.4/postgresql-pltcl-9.4_9.4.12-0+deb8u1_amd64.deb

a nainstalovat je příkazem dpkg a následně dokončit instalaci FlexiBee serveru:

    dpkg -i postgresql-9.4_9.4.12-0+deb8u1_amd64.deb postgresql-pltcl-9.4_9.4.12-0+deb8u1_amd64.deb
    apt-get -f install


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
