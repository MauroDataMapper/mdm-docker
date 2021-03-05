#!/usr/bin/env bash
mkdir -p /database
chown postgres /database
su postgres
pg_dump -U postgres -s maurodatamapper > /database/maurodatamapper-ddl.sql
exit
exit
