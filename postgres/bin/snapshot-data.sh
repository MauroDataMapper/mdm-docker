#!/usr/bin/env bash
mkdir /database
chown postgres /database
su postgres
pg_dump -a -U  -n public catalogue > /database/catalogue-data.sql
exit