FROM debian:jessie

ENV DEBIAN_SEED 2c9fc241-6fe4-41d8-a560-9a58b841d088

RUN apt-get update && apt-get install -y vim curl htop strace build-essential git apt-transport-https && rm -rf /var/lib/apt/lists/* &&\
    curl -sL https://github.com/tianon/gosu/releases/download/1.9/gosu-amd64 -o /usr/bin/gosu && chmod 755 /usr/bin/gosu &&\
    echo 'Europe/Moscow' > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata

ENV PHPFPM_SEED 76fa60b8-a617-46db-a19d-e167defcc49b

RUN useradd -mU phpfpm

RUN echo "deb http://packages.dotdeb.org jessie all" >> /etc/apt/sources.list &&\
    echo "deb-src http://packages.dotdeb.org jessie all" >> /etc/apt/sources.list &&\
    curl -sL https://www.dotdeb.org/dotdeb.gpg | apt-key add -

RUN apt-get update &&\
    apt-get install -y msmtp git php7.0-curl php7.0-fpm php7.0-gd php7.0-ldap php7.0-mbstring php7.0-mcrypt php7.0-mysql php7.0-opcache php7.0-xml php7.0-xml php7.0-zip php7.0-redis php7.0-pspell aspell-ru aspell-en &&\
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN apt-get update && apt-get install -y build-essential poppler-utils authbind &&\
    curl -sLO http://ftp.wagner.pp.ru/pub/catdoc/catdoc-0.95.tar.gz &&\
    tar xzvf catdoc-0.95.tar.gz && rm catdoc-0.95.tar.gz &&\
    cd catdoc-0.95 && ./configure && make && make install && rm -rf catdoc-0.95 &&\
    apt-get purge -y build-essential && rm -rf /var/lib/apt/lists/*

RUN curl -sLO https://getcomposer.org/download/1.5.2/composer.phar &&\
    mv composer.phar /usr/local/bin/composer &&\
    chmod 755 /usr/local/bin/composer

RUN composer global require 'hirak/prestissimo:^0.3' &&\
    composer clearcache

COPY files/config.sh /config.sh

COPY files/start.sh /start.sh

RUN chown -R phpfpm:phpfpm /app

ENTRYPOINT [ "/config.sh" ]

CMD [ "/start.sh" ]

EXPOSE 4000

VOLUME [ "/app/www", "/var/lib/php/sessions" ]

RUN curl -sLO http://www.1c-bitrix.ru/download/scripts/restore.php  && mv restore.php /app/www &&\
    curl -sLO http://www.1c-bitrix.ru/download/scripts/bitrixsetup.php && mv bitrixsetup.php /app/www

ARG CI_JOB_ID

LABEL CI_JOB_ID ${CI_JOB_ID}
