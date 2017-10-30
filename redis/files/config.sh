#!/bin/bash -e

cat <<EOF > /etc/redis/redis.conf
dir /var/lib/redis

maxmemory ${REDIS_MAXMEMORY:=32mb}
maxmemory-policy allkeys-lru

save 900 1
save 300 10
save 60 10000

bind 0.0.0.0

protected-mode no
EOF

exec "$@"
