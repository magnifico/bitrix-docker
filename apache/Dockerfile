FROM php:7.0-apache

RUN a2enmod rewrite

RUN mkdir -p /app/public_html

ENV APACHE_DOCUMENT_ROOT /app/public_html

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf

RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

RUN docker-php-ext-install mysqli

RUN ln -s /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-enabled

RUN a2enmod ssl

COPY ./files/https/dev.magnifico.pro/privkey.pem /etc/ssl/private/ssl-cert-snakeoil.key

COPY ./files/https/dev.magnifico.pro/fullchain.pem /etc/ssl/certs/ssl-cert-snakeoil.pem

RUN curl -sLO https://getcomposer.org/download/1.5.2/composer.phar &&\
    mv composer.phar /usr/local/bin/composer &&\
    chmod 755 /usr/local/bin/composer

WORKDIR /app

RUN apt-get update &&\
    apt-get install -y subversion

RUN docker-php-ext-configure pdo &&\
    docker-php-ext-install pdo

RUN docker-php-ext-configure pdo_mysql &&\
    docker-php-ext-install pdo_mysql

RUN apt-get update &&\
    apt-get install -y zlib1g-dev &&\
    docker-php-ext-configure zip &&\
    docker-php-ext-install zip
