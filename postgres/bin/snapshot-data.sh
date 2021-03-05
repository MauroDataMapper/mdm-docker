#!/usr/bin/env bash
mkdir -p /database
chown postgres /database
su postgres
pg_dump -U postgres -a maurodatamapper > /database/maurodatamapper-data.sql
exit
exit
