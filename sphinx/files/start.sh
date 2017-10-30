#!/bin/bash -e

mkdir -p /var/lib/sphinxsearch /var/run/sphinxsearch
chown -R sphinxsearch:sphinxsearch /var/lib/sphinxsearch /var/run/sphinxsearch

gosu sphinxsearch /usr/bin/searchd --console
