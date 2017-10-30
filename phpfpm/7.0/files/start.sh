#!/bin/bash -e

mkdir -p /var/lib/php/sessions /var/log/phpfpm /tmp/phpfpm

chown -R phpfpm:phpfpm /app /var/lib/php/sessions /var/log/phpfpm /tmp/phpfpm

nohup authbind /usr/bin/php -c /etc/php/7.0/fpm/fpm.ini /app/www/bitrix/modules/mail/smtpd.php &> /dev/stdout &

/usr/sbin/php-fpm7.0 --nodaemonize --force-stderr --fpm-config /etc/php/7.0/fpm/fpm.ini -c /etc/php/7.0/fpm/php.ini
