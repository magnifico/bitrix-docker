#!/bin/bash -e

export NGINX_SERVER_NAME="${NGINX_SERVER_NAME:=dev.magnifico.pro}"

mkdir -p /etc/nginx

cat > /etc/nginx/nginx.conf <<CONFIG
daemon off;

user nginx nginx;

worker_processes auto;

worker_rlimit_nofile 8192;

events {
    worker_connections 8000;
}

http {
    server_tokens off;

    include "/etc/nginx/mime.conf";
    default_type application/octet-stream;
    charset_types text/xml text/plain text/vnd.wap.wml application/x-javascript application/rss+xml text/css application/javascript application/json;

    # Format to use in log files
    log_format main '[\$time_iso8601] \$request {"status": \$status, "request_time": \$request_time, "server_name": "\$server_name", "remote_addr": "\$remote_addr", "http_referer": "\$http_referer", "http_user_agent": "\$http_user_agent"}';
    error_log  /dev/stderr warn;
    access_log /dev/stdout main;

    keepalive_timeout 20;

    sendfile on;

    tcp_nopush on;

    client_max_body_size 30m;

    fastcgi_ignore_client_abort on;

    upstream phpfpm_upstream {
        server ${PHPFPM_HOST:=127.0.0.1}:4000;
    }

    include "/etc/nginx/gzip.conf";
    include "/etc/nginx/im_settings.conf";
    include "/etc/nginx/servers.conf";

}
CONFIG

cat > /etc/nginx/im_settings.conf <<CONFIG
push_stream_shared_memory_size 256M;
push_stream_max_messages_stored_per_channel 1000;
push_stream_max_channel_id_length 32;
push_stream_max_number_of_channels 100000;
push_stream_message_ttl 86400;
CONFIG

cat > /etc/nginx/mime.conf <<CONFIG
types {
    # Data interchange
    application/atom+xml                  atom;
    application/json                      json map topojson;
    application/ld+json                   jsonld;
    application/rss+xml                   rss;
    application/vnd.geo+json              geojson;
    application/xml                       rdf xml;

    # JavaScript
    # Normalize to standard type.
    # https://tools.ietf.org/html/rfc4329#section-7.2
    application/javascript                js;

    # Manifest files
    application/manifest+json             webmanifest;
    application/x-web-app-manifest+json   webapp;
    text/cache-manifest                   appcache;

    # Media files
    audio/midi                            mid midi kar;
    audio/mp4                             aac f4a f4b m4a;
    audio/mpeg                            mp3;
    audio/ogg                             oga ogg opus;
    audio/x-realaudio                     ra;
    audio/x-wav                           wav;
    image/bmp                             bmp;
    image/gif                             gif;
    image/jpeg                            jpeg jpg;
    image/png                             png;
    image/svg+xml                         svg svgz;
    image/tiff                            tif tiff;
    image/vnd.wap.wbmp                    wbmp;
    image/webp                            webp;
    image/x-jng                           jng;
    video/3gpp                            3gpp 3gp;
    video/mp4                             f4v f4p m4v mp4;
    video/mpeg                            mpeg mpg;
    video/ogg                             ogv;
    video/quicktime                       mov;
    video/webm                            webm;
    video/x-flv                           flv;
    video/x-mng                           mng;
    video/x-ms-asf                        asx asf;
    video/x-ms-wmv                        wmv;
    video/x-msvideo                       avi;

    # Serving .ico image files with a different media type
    # prevents Internet Explorer from displaying then as images:
    # https://github.com/h5bp/html5-boilerplate/commit/37b5fec090d00f38de64b591bcddcb205aadf8ee
    image/x-icon                          cur ico;

    # Microsoft Office
    application/msword                                                         doc;
    application/vnd.ms-excel                                                   xls;
    application/vnd.ms-powerpoint                                              ppt;
    application/vnd.openxmlformats-officedocument.wordprocessingml.document    docx;
    application/vnd.openxmlformats-officedocument.spreadsheetml.sheet          xlsx;
    application/vnd.openxmlformats-officedocument.presentationml.presentation  pptx;

    # Web fonts
    application/font-woff                 woff;
    application/font-woff2                woff2;
    application/vnd.ms-fontobject         eot;

    # Browsers usually ignore the font media types and simply sniff
    # the bytes to figure out the font type.
    # https://mimesniff.spec.whatwg.org/#matching-a-font-type-pattern
    # However, Blink and WebKit based browsers will show a warning
    # in the console if the following font types are served with any
    # other media types.
    application/x-font-ttf                ttc ttf;
    font/opentype                         otf;

    # Other
    application/java-archive              jar war ear;
    application/mac-binhex40              hqx;
    application/octet-stream              bin deb dll dmg exe img iso msi msm msp safariextz;
    application/pdf                       pdf;
    application/postscript                ps eps ai;
    application/rtf                       rtf;
    application/vnd.google-earth.kml+xml  kml;
    application/vnd.google-earth.kmz      kmz;
    application/vnd.wap.wmlc              wmlc;
    application/x-7z-compressed           7z;
    application/x-bb-appworld             bbaw;
    application/x-bittorrent              torrent;
    application/x-chrome-extension        crx;
    application/x-cocoa                   cco;
    application/x-java-archive-diff       jardiff;
    application/x-java-jnlp-file          jnlp;
    application/x-makeself                run;
    application/x-opera-extension         oex;
    application/x-perl                    pl pm;
    application/x-pilot                   prc pdb;
    application/x-rar-compressed          rar;
    application/x-redhat-package-manager  rpm;
    application/x-sea                     sea;
    application/x-shockwave-flash         swf;
    application/x-stuffit                 sit;
    application/x-tcl                     tcl tk;
    application/x-x509-ca-cert            der pem crt;
    application/x-xpinstall               xpi;
    application/xhtml+xml                 xhtml;
    application/xslt+xml                  xsl;
    application/zip                       zip;
    text/css                              css;
    text/html                             html htm shtml;
    text/mathml                           mml;
    text/plain                            txt;
    text/vcard                            vcard vcf;
    text/vnd.rim.location.xloc            xloc;
    text/vnd.sun.j2me.app-descriptor      jad;
    text/vnd.wap.wml                      wml;
    text/vtt                              vtt;
    text/x-component                      htc;
}
CONFIG

cat > /etc/nginx/gzip.conf <<CONFIG
gzip on;
gzip_comp_level 5;
gzip_min_length 256;
gzip_proxied any;
gzip_vary on;
gzip_types application/atom+xml
    application/javascript
    application/json
    application/ld+json
    application/manifest+json
    application/rdf+xml
    application/rss+xml
    application/schema+json
    application/vnd.geo+json
    application/vnd.ms-fontobject
    application/x-font-ttf
    application/x-javascript
    application/x-web-app-manifest+json
    application/xhtml+xml
    application/xml
    font/eot
    font/opentype
    image/bmp
    image/svg+xml
    image/vnd.microsoft.icon
    image/x-icon
    text/cache-manifest
    text/css
    text/javascript
    text/plain
    text/vcard
    text/vnd.rim.location.xloc
    text/vtt
    text/x-component
    text/x-cross-domain-policy
    text/xml;
CONFIG


cat > /etc/nginx/servers.conf <<CONFIG
server {
    server_name _;

    listen 80 default_server;
    listen [::]:80 default_server;

    return 444;
}

server {
    server_name _;

    listen 443 default_server http2 ssl;
    listen [::]:443 default_server http2 ssl;
    include /etc/nginx/https.conf;

    return 444;
}

server {
    server_name ${NGINX_SERVER_NAME};

    listen 80;
    listen [::]:80;

    location / {
        return 301 https://${NGINX_SERVER_NAME}\$request_uri;
    }
}

server {
    server_name ${NGINX_SERVER_NAME};

    listen 443 http2 ssl;
    listen [::]:443 http2 ssl;

    include /etc/nginx/https.conf;
    include /etc/nginx/errors.conf;
    include /etc/nginx/im_subscrider.conf;
    include /etc/nginx/security.conf;

    root /app/www;
    index index.php;

    location ^~ /upload/support/not_image {
        internal;
    }

    location ~* ^/bitrix/components/bitrix/player/mediaplayer/player\$ {
        # we don't use add_header here because it will discard headers added in security.conf
        header_filter_by_lua_block {
            ngx.header["Access-Control-Allow-Origin"] = "*";
        }
    }

    location ~* ^/(upload|bitrix/images|bitrix/tmp) {
        expires 30d;
        access_log off;
        error_page 404 /404.html;
    }

    location  ~* \.(css|js|gif|png|jpg|jpeg|ico|ogg|ttf|woff|eot|otf)\$ {
        expires 30d;
        access_log off;
        error_page 404 /404.html;
    }

    location ~ \.php\$ {
        try_files \$uri @urlrewrite;
        include /etc/nginx/fastcgi.conf;
    }

    location / {
        try_files \$uri \$uri/ @urlrewrite;
    }
}

# Nonsecure server for reading personal channels. Use secure server instead.
server {
    listen 8893;
    listen [::]:8893;

    server_name ${NGINX_SERVER_NAME};

    include /etc/nginx/errors.conf;
    include /etc/nginx/im_subscrider.conf;

    location ^~ / {
        deny all;
    }
}

# SSL enabled server for reading personal channels
server {
    listen 8894 http2 ssl;
    listen [::]:8894 http2 ssl;

    server_name ${NGINX_SERVER_NAME};

    include /etc/nginx/https.conf;
    include /etc/nginx/errors.conf;
    include /etc/nginx/im_subscrider.conf;

    location ^~ / {
        deny all;
    }
}

# Server to push messages to user channels
server {
    listen 8895;
    listen [::]:8895;

    server_name ${NGINX_SERVER_NAME};

    location ^~ /bitrix/pub/ {
        push_stream_publisher admin;
        push_stream_channels_path \$arg_CHANNEL_ID;
        push_stream_store_messages on;
    }

    location ^~ / {
        deny all;
    }

    include /etc/nginx/errors.conf;
}
CONFIG

cat > /etc/nginx/errors.conf <<CONFIG
error_page 403 /403.html;
error_page 404 = @urlrewrite;
error_page 500 /500.html;
error_page 502 /502.html;
error_page 503 /503.html;
error_page 504 /504.html;

location ~* ^/(403|404|500|502|503|504).html\$ {
    root /etc/nginx/errors;
}

location @urlrewrite {
    internal;
    include /etc/nginx/fastcgi.conf;
    fastcgi_param SCRIPT_FILENAME \$document_root/bitrix/urlrewrite.php;
}
CONFIG

cat > /etc/nginx/security.conf <<CONFIG
header_filter_by_lua_block {
    if not string.match(ngx.var.request_uri, '^/pub/') and not string.match(ngx.var.request_uri, '^/online/') then
        ngx.header["X-Frame-Options"] = "SAMEORIGIN"
    end
}

# MIME type sniffing security protection. There are very few edge cases where you wouldn't want this enabled.
add_header "X-Content-Type-Options" "nosniff";

# The X-XSS-Protection header is used by Internet Explorer version 8+. The header instructs IE to enable its inbuilt anti-cross-site scripting filter.
add_header "X-XSS-Protection" "1; mode=block";

# Prevent mobile network providers from modifying your site
add_header "Cache-Control" "no-transform";

# Force the latest IE version
add_header "X-UA-Compatible" "IE=Edge";

# Prevent clients from accessing to backup/config/source files
location ~* (?:\.(?:bak|config|sql|fla|psd|ini|log|sh|inc|swp|dist)|~)\$ {
    deny all;
}

# Deny access to repositories/htpasswd/htaccess
location ~* /\.(svn|hg|git|ht) {
    deny all;
}

# Deny access to parent directory
location ~* /\.\./ {
    deny all;
}

# Deny access to bitrix internals
location ~* ^/bitrix/(msmtp\.conf|\.settings\.php|\.settings_extra\.php|modules|local_cache|stack_cache|managed_cache|php_interface|phinx\.yml) {
    deny all;
}

location ~* ^/bitrix/html_pages/\.(enabled|config\.php) {
    deny all;
}

location ~* ^/upload/1c_[^/]+/ {
    deny all;
}

location ~* ^/local/(modules|php_interface) {
    deny all;
}
CONFIG

cat > /etc/nginx/fastcgi.conf <<CONFIG
fastcgi_pass     phpfpm_upstream;
fastcgi_index    index.php;
fastcgi_param    CONTENT_LENGTH       \$content_length;
fastcgi_param    CONTENT_TYPE         \$content_type;
fastcgi_param    DOCUMENT_ROOT        \$document_root;
fastcgi_param    DOCUMENT_URI         \$document_uri;
fastcgi_param    GATEWAY_INTERFACE    CGI/1.1;
fastcgi_param    PATH_INFO            \$fastcgi_path_info;
fastcgi_param    PATH_TRANSLATED      \$document_root\$fastcgi_path_info;
fastcgi_param    QUERY_STRING         \$query_string;
fastcgi_param    REMOTE_ADDR          \$remote_addr;
fastcgi_param    REMOTE_PORT          \$remote_port;
fastcgi_param    REQUEST_METHOD       \$request_method;
fastcgi_param    REQUEST_URI          \$request_uri;
fastcgi_param    SCRIPT_FILENAME      \$document_root\$fastcgi_script_name;
fastcgi_param    SCRIPT_NAME          \$fastcgi_script_name;
fastcgi_param    SERVER_ADDR          \$server_addr;
fastcgi_param    SERVER_NAME          \$server_name;
fastcgi_param    SERVER_PORT          \$server_port;
fastcgi_param    SERVER_PROTOCOL      \$server_protocol;
fastcgi_param    SERVER_SOFTWARE      nginx/\$nginx_version;
fastcgi_param    HTTPS                \$https;
CONFIG

cat > /etc/nginx/im_subscrider.conf <<CONFIG
# Location for long-polling connections
location ^~ /bitrix/sub {
    if ( \$arg_callback ) {
        return 400;
    }
    push_stream_subscriber long-polling;
    push_stream_allowed_origins "*";
    push_stream_channels_path \$arg_CHANNEL_ID;
    push_stream_last_received_message_tag \$arg_tag;
    push_stream_longpolling_connection_ttl 40;
    push_stream_authorized_channels_only off;
    push_stream_message_template '#!NGINXNMS!#{"id":~id~,"channel":"~channel~","tag":"~tag~","time":"~time~","eventid":"~event-id~","text":~text~}#!NGINXNME!#';
}

# Location for websocet connections
location ^~ /bitrix/subws/ {
    push_stream_subscriber websocket;
    push_stream_channels_path \$arg_CHANNEL_ID;
    push_stream_websocket_allow_publish off;
    push_stream_ping_message_interval 40s;
    push_stream_authorized_channels_only off;
    push_stream_last_received_message_tag "\$arg_tag";
    push_stream_last_received_message_time "\$arg_time";
    push_stream_message_template '#!NGINXNMS!#{"id":~id~,"channel":"~channel~","tag":"~tag~","time":"~time~","eventid":"~event-id~","text":~text~}#!NGINXNME!#';
}
CONFIG

cat > /etc/nginx/https.conf <<CONFIG
error_page 497 https://\$host\$request_uri;
ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:ECDHE-RSA-DES-CBC3-SHA:ECDHE-ECDSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA;
ssl_prefer_server_ciphers on;
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 24h;
keepalive_timeout 300;
keepalive_requests 200;
ssl_certificate /etc/letsencrypt/live/${NGINX_SERVER_NAME}/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/${NGINX_SERVER_NAME}/privkey.pem;
ssl_stapling on;
ssl_stapling_verify on;
resolver 8.8.8.8 8.8.4.4 valid=60s;
resolver_timeout 2s;
add_header Strict-Transport-Security "max-age=31536000;";
CONFIG

exec "$@"
