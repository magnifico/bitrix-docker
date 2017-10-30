#!/bin/bash -e

cat <<EOF > /etc/php/7.0/fpm/fpm.ini
[global]
daemonize = no
error_log = /proc/self/fd/2

[www]
user = phpfpm
group = phpfpm
chdir = /app/www
clear_env = no
catch_workers_output = yes

access.log = /proc/self/fd/2
security.limit_extensions = .php

listen = 0.0.0.0:4000
listen.backlog = 65535

pm = dynamic
pm.max_children = 10
pm.start_servers = 6
pm.min_spare_servers = 4
pm.max_spare_servers = 8
pm.max_requests = 500
EOF

cat <<CONFIG | tee /etc/php/7.0/cli/php.ini /etc/php/7.0/fpm/php.ini > /dev/null
; CORE
allow_url_fopen = 1
allow_url_include = 0
auto_globals_jit = 1
cgi.fix_pathinfo = 1
default_charset = utf-8
default_mimetype = text/html
default_socket_timeout = 60
disable_functions = pcntl_alarm,pcntl_fork,pcntl_waitpid,pcntl_wait,pcntl_wifexited,pcntl_wifstopped,pcntl_wifsignaled,pcntl_wexitstatus,pcntl_wtermsig,pcntl_wstopsig,pcntl_signal,pcntl_signal_dispatch,pcntl_get_last_error,pcntl_strerror,pcntl_sigprocmask,pcntl_sigwaitinfo,pcntl_sigtimedwait,pcntl_exec,pcntl_getpriority,pcntl_setpriority
display_errors = ${PHPFPM_DEBUG:=1}
display_startup_errors = ${PHPFPM_DEBUG:=1}
enable_dl = 0
error_reporting = ${PHPFPM_ERROR_REPORTING:="E_ALL & ~E_DEPRECATED & ~E_STRICT"}
expose_php = 0
file_uploads = 1
html_errors = 1
ignore_repeated_errors = 0
ignore_repeated_source = 0
implicit_flush = 0
log_errors = 1
log_errors_max_len = 1024
max_execution_time = 60
max_file_uploads = 20
max_input_time = 60
max_input_vars = 10000
memory_limit = ${PHPFPM_MEMORY_LIMIT:=512M}
output_buffering = 4096
post_max_size = 40M
precision = 10
realpath_cache_size = 4096K
register_argc_argv = 0
request_order = GP
serialize_precision = 10
short_open_tag = 1
upload_max_filesize = 30M
variables_order = GPCS
zend.enable_gc = 1
zlib.output_compression = 0

; CLI_SERVER
cli_server.color = 1

; DATETIME
date.timezone = Europe/Moscow

; MYSQLI
mysqli.allow_persistent = 1
mysqli.cache_size = 2000
mysqli.default_port = 3306
mysqli.max_links = -1
mysqli.max_persistent = -1
mysqli.reconnect = 0
sql.safe_mode = 0

; SESSION
session.auto_start = 0
session.cache_expire = 180
session.cache_limiter = nocache
session.gc_divisor = 1000
session.gc_maxlifetime = 86400
session.gc_probability = 1
session.hash_bits_per_character = 5
session.hash_function = 0
session.save_path = /var/lib/php/sessions
session.serialize_handler = php_serialize
session.upload_progress.cleanup = 1
session.upload_progress.enabled = 1
session.use_cookies = 1
session.use_only_cookies = 1
session.use_strict_mode = 1
session.use_trans_sid = 0

$(if [ "${UTF_MODE:=true}" == "true" ]; then
cat <<INNER_CONFIG >> /dev/stdout

; MBSTRING
mbstring.func_overload = 2
mbstring.internal_encoding = utf-8

INNER_CONFIG
fi)

; OPCACHE
opcache.enable = 1
opcache.fast_shutdown = 1
opcache.load_comments = 1
opcache.max_accelerated_files = 100000
opcache.memory_consumption = 64
opcache.save_comments = 1
opcache.revalidate_freq = 0

; MAIL
sendmail_path = /usr/bin/msmtp --file /app/www/bitrix/msmtp.conf -t -i

; PCRE
pcre.recursion_limit = 1000
CONFIG

if [ -d /app/www/bitrix ]; then
    if [ -d /app/vendor ]; then
cat <<CONFIG > /app/www/bitrix/.settings_extra.php
<?php

require_once '/app/vendor/autoload.php';

if (!defined('BX_CRONTAB_SUPPORT')) {
    define('BX_CRONTAB_SUPPORT', true);
}

if (!defined('BX_TEMPORARY_FILES_DIRECTORY')) {
    define('BX_TEMPORARY_FILES_DIRECTORY', '/tmp/phpfpm');
}

return [
    'cache' => [
        'value' => [
            'sid' => 'v2',
            'type' => [
                'class_name' => 'Magnifico\Cache\RedisEngine',
                'extension' => 'redis',
            ],
            'redis' => [
                'port' => '6379',
                'host' => '${REDIS_HOST:=127.0.0.1}',
            ],
        ],
    ],
];
CONFIG
    fi
fi

exec "$@"
