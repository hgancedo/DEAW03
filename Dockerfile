# Creamos la imagen a partir de ubuntu versión 18.04
FROM ubuntu:18.04

# Damos información sobre la imagen que estamos creando
LABEL \
	version="1.0" \
	description="Ubuntu + Apache2 + virtual host" \
	creationDate="03-01-2022" \
	maintainer="Hector Gancedo Grade <hgancedo@birt.eus>"

ENV DEBIAN_FRONTEND=noninteractive


# Instalamos el editor nano
RUN \
	apt update \
	&& apt-get install -y nano \
	&& apt-get install -y apache2 \
	&& mkdir /etc/sshclavegit /repositorio \
	#/var/www/html/sitioweb1/ /var/www/html/sitioweb2/ 
	&& apt-get install -y proftpd \
	&& apt-get install -y ssh \
	&& apt-get install -y git 


# Copiamos el index al directorio por defecto del servidor Web
COPY /original/index1.html /var/www/html/sitioweb1/index.html
COPY /original/index2.html /var/www/html/sitioweb2/index.html
COPY /original/sitioweb1.conf /etc/apache2/sites-available    
COPY /original/sitioweb2.conf /etc/apache2/sites-available
COPY /original/sitioweb1.key /etc/ssl/private
COPY /original/sitioweb1.cer /etc/ssl/certs
COPY /anadidos/proftpd.key /etc/ssl/private 
COPY /anadidos/proftpd.crt /etc/ssl/certs
COPY /anadidos/proftpd.conf /etc/proftpd
COPY /anadidos/tls.conf /etc/proftpd
COPY /anadidos/clavegit.txt /etc/sshclavegit

# DEBEMOS COPIAR Y MOVER EL PROFTPD.CONF PQ HEMOS ACTIVADO TLS
# COPIAR Y MOVER TLS.CONF
# generar certificados /etc/ssl/private/proftpd.key y /etc/ssl/certs/proftpd.crt y no hace falta MOVERLOS
# ya se especifica el destino al generarlos
# ACTIVAR PROFTPD O AÑADIRLO A RC2.D PARA Q ARANQE AL INICIO
# CREAR USUARIO 

RUN \
	a2enmod ssl \
	&& a2dissite default-ssl.conf \
	&& a2ensite sitioweb1.conf \
	&& a2ensite sitioweb2.conf \ 
	&& useradd hgancedo1 -m -p "$(openssl passwd -1 "hgancedo1")" -s /sbin/nologin \
	&& chown hgancedo1 /var/www/html/sitioweb1/ \
	&& useradd hgancedo2 -m -p "$(openssl passwd -1 "hgancedo2")" -s /bin/bash \
	&& chown hgancedo2 /var/www/html/sitioweb2/ \
	&& echo hgancedo2 >> /etc/ftpusers \
	&& eval $(ssh-agent -s) \
	&& chmod 700 /etc/sshclavegit/clavegit.txt \
	&& ssh-add /etc/sshclavegit/clavegit.txt \
	&& ssh-keyscan -H github.com >> /etc/ssh/ssh_known_hosts \
	&& git clone git@github.com:deaw-birt/deaw03-te1-ftp-anonimo.git /repositorio \
	&& cp /repositorio/* -r /srv/ftp 


# Indicamos el puerto que utiliza la imagen
EXPOSE 80
EXPOSE 443
EXPOSE 20
EXPOSE 21
EXPOSE 22
EXPOSE 60001-60100
