FROM debian:jessie

ENV DEBIAN_SEED 2c9fc241-6fe4-41d8-a560-9a58b841d088

RUN apt-key update

RUN apt-get update && apt-get install -y vim curl htop strace build-essential git apt-transport-https && rm -rf /var/lib/apt/lists/* &&\
    curl -sL https://github.com/tianon/gosu/releases/download/1.9/gosu-amd64 -o /usr/bin/gosu && chmod 755 /usr/bin/gosu &&\
    echo 'Europe/Moscow' > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata

RUN BUILD_SEED=02d6c23b-d54b-4c6f-801e-da31e7b60fa6 &&\
    BUILD_PACKAGES="libreadline-dev libncurses5-dev libpcre3-dev libssl-dev libatomic-ops-dev" &&\

    apt-get update &&\
    apt-get install -y ${BUILD_PACKAGES} &&\
    rm -rf /var/lib/apt/lists/* &&\

    OPENRESTY_VERSION=1.11.2.2 &&\
    curl -sLO https://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz &&\
    tar xzvf openresty-${OPENRESTY_VERSION}.tar.gz &&\
    rm openresty-${OPENRESTY_VERSION}.tar.gz &&\
    mv openresty-${OPENRESTY_VERSION} /openresty &&\

    PUSH_STREAM_VERSION=0.4.0 &&\
    curl -sLO https://github.com/wandenberg/nginx-push-stream-module/archive/${PUSH_STREAM_VERSION}.tar.gz &&\
    tar xzvf ${PUSH_STREAM_VERSION}.tar.gz &&\
    rm ${PUSH_STREAM_VERSION}.tar.gz &&\
    mv nginx-push-stream-module-${PUSH_STREAM_VERSION} /openresty/nginx-push-stream-module &&\

    cd /openresty &&\

    ./configure -j2 \
        --with-debug \
        --with-luajit \
        --with-pcre-jit \
        --prefix=/usr/share \
        --sbin-path=/usr/sbin/nginx \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --pid-path=/run/nginx.pid \
        --lock-path=/var/lock/nginx.lock \
        --with-threads \
        --with-file-aio \
        --with-ipv6 \
        --with-http_v2_module \
        --with-http_ssl_module \
        --without-http_ssi_module \
        --without-http_userid_module \
        --without-http_autoindex_module \
        --without-http_geo_module \
        --without-http_split_clients_module \
        --without-http_referer_module \
        --without-http_uwsgi_module \
        --without-http_scgi_module \
        --without-http_memcached_module \
        --without-http_browser_module \
        --http-log-path=/var/log/nginx/access.log \
        --http-client-body-temp-path=/var/lib/nginx/body \
        --http-proxy-temp-path=/var/lib/nginx/proxy \
        --http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
        --add-module=/openresty/nginx-push-stream-module \
        --with-libatomic &&\

    make -j4 &&\
    make install &&\

    mkdir -p /var/lib/nginx &&\
    ln -sf /usr/share/bin/opm /usr/bin/opm &&\
    ln -sf /usr/share/bin/resty /usr/bin/resty &&\

    cd / &&\

    apt-get purge -y ${BUILD_PACKAGES} &&\
    apt-get autoremove -y &&\
    find /openresty -delete

RUN apt-get update &&\
    apt-get install -y luarocks &&\
    rm -rf /var/lib/apt/lists/*

VOLUME [ "/var/lib/nginx" ]

ENV NGINX_SEED 966edddc-7b50-4363-9e75-a077df7b9454

RUN useradd -mU nginx

COPY files/https /etc/letsencrypt/live

COPY files/errors /etc/nginx/errors

COPY files/config.sh /config.sh

COPY files/start.sh /start.sh

ENTRYPOINT [ "/config.sh" ]

CMD [ "/start.sh" ]

EXPOSE 80 443 8893 8894

ARG CI_JOB_ID

LABEL CI_JOB_ID ${CI_JOB_ID}
