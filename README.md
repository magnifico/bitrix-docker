[![Build Status](https://travis-ci.org/magnifico/bitrix-docker.svg?branch=master)](https://travis-ci.org/magnifico/bitrix-docker)

```yml
version: "2"

volumes:
  mysql_data: {}

services:
  phpfpm:
    image: "magnifico/bitrix:phpfpm7.0"
    network_mode: "host"
    volumes: [ "./www:/app/www" ]

  nginx:
    image: "magnifico/bitrix:nginx"
    network_mode: "host"
    volumes: [ "./www:/app/www" ]

  mysql:
    image: "magnifico/bitrix:mysql"
    network_mode: "host"
    volumes: [ "mysql_data:/var/lib/mysql" ]
```
