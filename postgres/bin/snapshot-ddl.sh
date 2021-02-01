#!/usr/bin/env bash
mkdir /database
chown postgres /database
su postgres
pg_dump -s -U postgres -n public catalogue > /database/labkey-ddl.sql
exit