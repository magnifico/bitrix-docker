FROM debian:jessie

ENV DEBIAN_SEED 2c9fc241-6fe4-41d8-a560-9a58b841d088

RUN apt-key update

RUN apt-get update && apt-get install -y vim curl htop strace build-essential git apt-transport-https && rm -rf /var/lib/apt/lists/* &&\
    curl -sL https://github.com/tianon/gosu/releases/download/1.9/gosu-amd64 -o /usr/bin/gosu && chmod 755 /usr/bin/gosu &&\
    echo 'Europe/Moscow' > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata

ENV SPHINX_SEED 70fcbb5d-a20a-40a0-9a75-1236685082b3

RUN useradd -mU sphinxsearch

RUN apt-get update &&\
    apt-get install -y mysql-client unixodbc libpq5 libexpat1 &&\
    rm -rf /var/lib/apt/lists/*

RUN curl -sLO http://sphinxsearch.com/files/sphinxsearch_2.2.11-release-1~jessie_amd64.deb &&\
    dpkg -i sphinxsearch_2.2.11-release-1~jessie_amd64.deb &&\
    rm sphinxsearch_2.2.11-release-1~jessie_amd64.deb

RUN mkdir -p /etc/sphinxsearch/dicts &&\
    curl -sL http://sphinxsearch.com/files/dicts/ru.pak -o /etc/sphinxsearch/dicts/ru.pak &&\
    curl -sL http://sphinxsearch.com/files/dicts/en.pak -o /etc/sphinxsearch/dicts/en.pak

COPY files/config.sh /config.sh

COPY files/start.sh /start.sh

ENTRYPOINT [ "/config.sh" ]

CMD [ "/start.sh" ]

EXPOSE 9312 9306

VOLUME [ "/var/lib/sphinxsearch" ]

ARG CI_JOB_ID

LABEL CI_JOB_ID ${CI_JOB_ID}
