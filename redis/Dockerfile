FROM debian:jessie

ENV DEBIAN_SEED 2c9fc241-6fe4-41d8-a560-9a58b841d088

RUN apt-key update

RUN apt-get update && apt-get install -y vim curl htop strace build-essential git apt-transport-https && rm -rf /var/lib/apt/lists/* &&\
    curl -sL https://github.com/tianon/gosu/releases/download/1.9/gosu-amd64 -o /usr/bin/gosu && chmod 755 /usr/bin/gosu &&\
    echo 'Europe/Moscow' > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata

ENV REDIS_SEED 2e6cca99-6c20-4650-9f90-0d2d292935c6

RUN useradd -mU redis

RUN echo "deb http://packages.dotdeb.org jessie all" >> /etc/apt/sources.list &&\
    echo "deb-src http://packages.dotdeb.org jessie all" >> /etc/apt/sources.list &&\
    curl -sL https://www.dotdeb.org/dotdeb.gpg | apt-key add -

RUN apt-get update &&\
    apt-get install -y redis-server &&\
    rm -rf /var/lib/apt/lists/*

COPY ./files/config.sh /config.sh

COPY ./files/start.sh /start.sh

ENTRYPOINT [ "/config.sh" ]

CMD [ "/start.sh" ]

EXPOSE 6379

VOLUME [ "/var/lib/redis" ]

ARG CI_JOB_ID

LABEL CI_JOB_ID ${CI_JOB_ID}
