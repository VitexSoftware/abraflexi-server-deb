FROM debian:latest
LABEL maintainer="Vítězslav Dvořák <info@vitexsoftware.cz>"
ENV DEBIAN_FRONTEND noninteractive 

RUN apt update && apt-get install -my wget gnupg lsb-release gdebi-core

RUN echo "deb http://repo.vitexsoftware.cz $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/vitexsoftware.list
RUN wget -O /etc/apt/trusted.gpg.d/vitexsoftware.gpg http://repo.vitexsoftware.cz/keyring.gpg
RUN apt update

ADD abraflexi-server_*_all.deb /tmp/abraflexi-server.deb

RUN gdebi -n /tmp/abraflexi-server.deb

# Expose abraflexi

EXPOSE 5434

CMD /etc/init.d/abraflexi start

ENTRYPOINT ["/bin/bash"]
