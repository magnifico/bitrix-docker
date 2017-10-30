#!/bin/bash -e

mkdir -p /app /var/lib/nginx /var/log/nginx

chown -R nginx:nginx /app /var/lib/nginx /var/log/nginx

/usr/sbin/nginx -c /etc/nginx/nginx.conf
