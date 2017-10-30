#!/bin/bash -e

cat <<CONFIG > /etc/sphinxsearch/sphinx.conf
common
{
    lemmatizer_base = /etc/sphinxsearch/dicts
}

indexer
{
    mem_limit = 128M
    lemmatizer_cache = 128M
}

searchd
{
    listen = 9312
    listen = 9306:mysql41
    read_timeout = 5
    max_children = 30
    pid_file = /var/run/sphinxsearch/searchd.pid
    seamless_rotate = 1
    preopen_indexes = 1
    unlink_old = 1
    workers = threads
    binlog_path = /var/lib/sphinxsearch/data/
    binlog_max_log_size = 512M
    binlog_flush = 2
    rt_flush_period = 3600
}

index bitrix
{
    type = rt
    path = /var/lib/sphinxsearch/data/bitrix
    ondisk_attrs = 1
    morphology = lemmatize_ru_all, stem_enru, soundex
    dict = keywords
    min_prefix_len = 2
    index_exact_words = 1
    rt_field = title
    rt_field = body
    rt_attr_uint = module_id
    rt_attr_string = module
    rt_attr_uint = item_id
    rt_attr_string = item
    rt_attr_uint = param1_id
    rt_attr_string = param1
    rt_attr_uint = param2_id
    rt_attr_string = param2
    rt_attr_timestamp = date_change
    rt_attr_timestamp = date_to
    rt_attr_timestamp = date_from
    rt_attr_uint = custom_rank
    rt_attr_multi = tags
    rt_attr_multi = right
    rt_attr_multi = site
    rt_attr_multi = param
}
CONFIG

exec "$@"
