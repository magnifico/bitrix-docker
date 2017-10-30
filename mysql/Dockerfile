FROM debian:jessie

ENV DEBIAN_SEED 2c9fc241-6fe4-41d8-a560-9a58b841d088

RUN apt-get update && apt-get install -y vim curl htop strace build-essential git apt-transport-https && rm -rf /var/lib/apt/lists/* &&\
    curl -sL https://github.com/tianon/gosu/releases/download/1.9/gosu-amd64 -o /usr/bin/gosu && chmod 755 /usr/bin/gosu &&\
    echo 'Europe/Moscow' > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata

ENV MYSQL_SEED 31575f80-a0a4-4d84-bbfc-e1c81990e40a

RUN echo "debconf percona-xtradb-cluster-server-5.7/root-pass select root" | debconf-set-selections &&\
    echo "debconf percona-xtradb-cluster-server-5.7/re-root-pass select root" | debconf-set-selections &&\
    echo "debconf percona-xtradb-cluster-server-5.7/remove-data-dir select false" | debconf-set-selections

ENV MYSQL_RELEASE_DEB percona-release_0.1-4.jessie_all.deb

RUN curl -sLO https://www.percona.com/redir/downloads/percona-release/debian/0.1-4/${MYSQL_RELEASE_DEB} &&\
    dpkg -i ${MYSQL_RELEASE_DEB} &&\
    rm ${MYSQL_RELEASE_DEB}

RUN apt-get update &&\
    apt-get install -y percona-xtradb-cluster-57 percona-xtrabackup-24 qpress percona-toolkit &&\
    rm -rf /var/lib/apt/lists/*

RUN curl -sLO https://raw.githubusercontent.com/major/MySQLTuner-perl/master/mysqltuner.pl &&\
    chmod 755 mysqltuner.pl &&\
    mv mysqltuner.pl /usr/local/bin/mysqltuner

COPY files/config.sh /config.sh

COPY files/start.sh /start.sh

RUN (/bin/bash /config.sh) &&\
    (/start.sh &) &&\
    (mysqladmin -uroot -proot --silent --wait=30 ping) &&\
    (mysql -uroot -proot -e "CREATE USER 'bitrix'@'%' IDENTIFIED BY 'bitrix'") &&\
    (mysql -uroot -proot -e "CREATE DATABASE bitrix") &&\
    (mysql -uroot -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'bitrix'@'%'") &&\
    (mysql -uroot -proot -e "FLUSH PRIVILEGES") &&\
    (mysql -uroot -proot -e "SHOW GRANTS FOR 'bitrix'@'%'") &&\
    (mysql -uroot -proot -e "CREATE FUNCTION fnv1a_64 RETURNS INTEGER SONAME 'libfnv1a_udf.so'") &&\
    (mysql -uroot -proot -e "CREATE FUNCTION fnv_64 RETURNS INTEGER SONAME 'libfnv_udf.so'") &&\
    (mysql -uroot -proot -e "CREATE FUNCTION murmur_hash RETURNS INTEGER SONAME 'libmurmur_udf.so'") &&\
    (mysqladmin -uroot -proot shutdown)

ENTRYPOINT [ "/config.sh" ]

CMD [ "/start.sh" ]

VOLUME [ "/var/lib/mysql" ]

EXPOSE 3306 4444 4567 4568

ARG CI_JOB_ID

LABEL CI_JOB_ID ${CI_JOB_ID}
