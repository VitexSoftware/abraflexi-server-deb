FROM debian:latest

MAINTAINER Vitex <info@vitexsoftware.cz>

ENV DEBIAN_FRONTEND noninteractive

# Install basics

RUN apt update

RUN apt -y install wget gnupg

RUN wget -O - http://v.s.cz/info@vitexsoftware.cz.gpg.key | apt-key add -

RUN echo deb http://v.s.cz/ stable main | tee /etc/apt/sources.list.d/vitexsoftware.list 

RUN apt update

RUN apt -y install flexibee-server

# Expose FlexiBee

EXPOSE 5434

CMD /etc/init.d/flexibee start

ENTRYPOINT ["/bin/bash"]
