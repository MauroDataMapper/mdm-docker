#!/usr/bin/env bash

# Wait for the postgres container to be ready before starting java process.

wait-for-it.sh postgres:5432 -t 0

>&2 echo "Verifying postgres DB"
until psql -h postgres -U "postgres" -c '\l'; do
  sleep 1
done

echo "Starting Application"
exec "$@"