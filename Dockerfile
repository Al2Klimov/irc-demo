FROM ubuntu:20.04 as base

SHELL ["/bin/bash", "-exo", "pipefail", "-c"]

RUN apt-get update ;\
	apt-get install --no-install-{recommends,suggests} -y ngircd libpam-pwdfile ;\
	apt-get clean ;\
	rm -vrf /var/lib/apt/lists/*

COPY ngircd.passwd /etc/ngircd/passwd
COPY ngircd.pam /etc/pam.d/ngircd
RUN perl -pi -e 's/no/yes/ if /PAM/' /etc/ngircd/ngircd.conf

USER irc
EXPOSE 6667
CMD ["/usr/sbin/ngircd", "-n"]
