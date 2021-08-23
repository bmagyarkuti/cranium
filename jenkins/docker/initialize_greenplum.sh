#!/usr/bin/env bash

echo "127.0.0.1 $(cat ~/orig_hostname)" >> /etc/hosts

service sshd start

su - gpadmin -c /usr/local/bin/run.sh
su - gpadmin -c 'cat /docker-entrypoint-initdb.d/create_databases.sql | psql -e'
su - gpadmin -c 'gpfdist -d /home/gpadmin/gpfdist-data -p 8123'
