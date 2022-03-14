FROM ubuntu:20.04 as base

SHELL ["/bin/bash", "-exo", "pipefail", "-c"]


FROM base as cert

RUN apt-get update ;\
	apt-get install --no-install-{recommends,suggests} -y openssl ;\
	apt-get clean ;\
	rm -vrf /var/lib/apt/lists/*

RUN openssl req -x509 -newkey rsa:1024 -subj /CN=example.com \
	-md5 -nodes -keyout /server.key -out /server.crt


FROM base

RUN apt-get update ;\
	apt-get install --no-install-{recommends,suggests} -y ngircd libpam-pwdfile ;\
	apt-get clean ;\
	rm -vrf /var/lib/apt/lists/*

COPY --from=cert --chown=irc /server.crt /etc/ssl/certs/
COPY --from=cert --chown=irc /server.key /etc/ssl/private/

COPY ngircd.passwd /etc/ngircd/passwd
COPY ngircd.pam /etc/pam.d/ngircd
RUN perl -pi -e 's/no/yes/ if /PAM/; s/;// if /CertFile|KeyFile|Ports/' /etc/ngircd/ngircd.conf

USER irc
EXPOSE 6667 6697
CMD ["/usr/sbin/ngircd", "-n"]
