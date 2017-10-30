#!/bin/bash -e

rm -f /run/mysqld/mysqld.pid /run/mysqld/mysqld.sock /run/mysqld/mysqld.sock.lock

trap "{ killall -u mysql; pkill tail; }" INT TERM

DAEMON_OPTS=" --tc-heuristic-recover=COMMIT "

if [ "${CLUSTER_MODE:=false}" == "true" ]; then
    if [ "${BOOTSTRAP_CLUSTER:=false}" = "true" ]; then
        DAEMON_OPTS="${DAEMON_OPTS} --wsrep-new-cluster"
    fi
fi

touch /var/log/mysql.err

chown -R -L mysql:mysql /var/lib/mysql /etc/mysql /var/run/mysqld /var/log/mysql.err

mysqld_safe ${DAEMON_OPTS} &

tail -n0 -F /var/log/mysql.err &

wait
