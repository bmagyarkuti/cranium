#!/usr/bin/env bash

echo "greenplum $(cat ~/orig_hostname)" >> /etc/hosts

service sshd start

su - gpadmin -c /usr/local/bin/run.sh
su - gpadmin -c 'cat /db/setup.sql | psql -e'
su - gpadmin -c 'gpfdist -d /home/gpadmin/gpfdist-data -p 8123'
