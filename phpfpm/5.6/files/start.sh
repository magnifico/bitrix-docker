#!/bin/bash -e

mkdir -p /var/lib/php/sessions /var/log/phpfpm /tmp/phpfpm

chown -R phpfpm:phpfpm /app /var/lib/php/sessions /var/log/phpfpm /tmp/phpfpm

nohup authbind /usr/bin/php -c /etc/php5/fpm/fpm.ini /app/www/bitrix/modules/mail/smtpd.php &> /dev/stdout &

/usr/sbin/php5-fpm --nodaemonize --force-stderr --fpm-config /etc/php5/fpm/fpm.ini -c /etc/php5/fpm/php.ini
