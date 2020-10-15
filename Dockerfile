# vim:set ft=dockerfile:

FROM debian:buster-slim

LABEL maintainer="Alvaro Barcellos <alvaro.barcellos@cprm.gov.br>"
LABEL maintainer="NDS/CPRM <alvaro.barcellos@cprm.gov.br>"

ENV VSFTPD_VERSION 3.0.3

RUN set -x ; \
# create ftponly group first, for ftp users
    addgroup --system --gid 906 ftponly ; \
    mkdir -p /data ; \
    chown root.ftponly /data ; \
    chmod 1775 /data ; \
    echo "/usr/sbin/nologin" >> /etc/shells ; \
# create vsftpd user/group first, 
    addgroup --system --gid 200 vsftpd ; \
    adduser --system --uid 200 vsftpd \
       --disabled-login --ingroup vsftpd --no-create-home \
       --home /nonexistent --gecos "vsftpd user" --shell /bin/false ; \
    mkdir -p /etc/vsftpd /var/run/vsftpd/empty ; \
    touch /var/log/vsftpd.log /var/log/xferlog ; \
# install packages,
    apt-get update ; \
    apt-get install --no-install-recommends --no-install-suggests -y vsftpd ; \
    apt-get remove --purge --auto-remove -y ; \
    rm -rf /var/lib/apt/lists/* /etc/apt/sources.list.d/vsftpd.list  

# create a docker-entrypoint.d directory

RUN mkdir /docker-entrypoint.d

COPY docker-entrypoint.sh /

COPY ./etc /etc/

COPY ./ftpuser /bin

ENTRYPOINT ["/docker-entrypoint.sh"]

STOPSIGNAL SIGTERM

CMD ["/usr/sbin/vsftpd", "/etc/vsftpd/vsftpd.conf"]

