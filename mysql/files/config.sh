#!/bin/bash -e

cat <<CONFIG > /etc/mysql/my.cnf
[mysql]
no_auto_rehash

[mysqldump]
quick
max_allowed_packet = 512M

[client]
user = root
password = root

[mysqld]
skip_name_resolve
skip_character_set_client_handshake
bulk_insert_buffer_size = 2M
character_set_server = utf8
collation_server = utf8_unicode_ci
datadir = /var/lib/mysql
default_storage_engine = InnoDB
default_time_zone = +03:00
init_connect = "SET NAMES utf8 COLLATE utf8_unicode_ci"
innodb = FORCE
innodb_buffer_pool_instances = ${MYSQL_INNODB_BUFFER_POOL_INSTANCES:=1}
innodb_buffer_pool_size = ${MYSQL_INNODB_BUFFER_POOL_SIZE:=50M}
innodb_file_per_table = 1
innodb_flush_log_at_trx_commit = 2
innodb_flush_method = O_DIRECT
innodb_ft_cache_size = 1600000
innodb_ft_total_cache_size = 32000000
innodb_log_buffer_size = ${MYSQL_INNODB_LOG_BUFFER_SIZE:=256K}
innodb_log_file_size = ${MYSQL_INNODB_LOG_FILE_SIZE:=64M}
innodb_log_files_in_group = 2
innodb_sort_buffer_size = 64K
innodb_strict_mode = 1
interactive_timeout = 300
join_buffer_size = ${MYSQL_JOIN_BUFFER_SIZE:=512K}
key_buffer_size = ${MYSQL_KEY_BUFFER_SIZE:=512K}
log_error = /var/log/mysql.err
log_queries_not_using_indexes = 0
long_query_time = 2
max_allowed_packet = 16M
max_connect_errors = 1000000
max_connections = ${MYSQL_MAX_CONNECTIONS:=10}
max_heap_table_size = ${MYSQL_MAX_HEAP_TABLE_SIZE:=512K}
net_buffer_length = 1K
open_files_limit = 65535
pid_file = /var/run/mysqld/mysqld.pid
query_cache_limit = ${MYSQL_QUERY_CACHE_LIMIT:=128K}
query_cache_size = ${MYSQL_QUERY_CACHE_SIZE:=5M}
query_cache_type = ${MYSQL_QUERY_CACHE_TYPE:=1}
read_buffer_size = ${MYSQL_READ_BUFFER_SIZE:=8200}
read_rnd_buffer_size = 8200
slow_query_log = 0
sort_buffer_size = ${MYSQL_SORT_BUFFER_SIZE:=512K}
sql_mode =
sysdate_is_now = 1
table_definition_cache = 4096
table_open_cache = 5120
thread_cache_size = ${MYSQL_THREAD_CACHE_SIZE:=5}
thread_pool_size = 26
thread_stack = 256K
tmp_table_size = ${MYSQL_TMP_TABLE_SIZE:=512K}
transaction_isolation = READ-COMMITTED
user = mysql
wait_timeout = 300
pxc_strict_mode = DISABLED
CONFIG

exec "$@"
