FROM postgres:12.0-alpine
COPY fixtures /docker-entrypoint-initdb.d

ENV POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
    DATABASE_HOST=$MDM_PG_HOST \
    DATABASE_PORT=$MDM_PG_PORT \
    DATABASE_NAME=maurodatamapper \
    DATABASE_USERNAME=$MDM_PG_USER_NAME \
    DATABASE_PASSWORD=$MDM_PG_USER_PASSWORD

COPY ./bin /usr/local/bin
RUN chmod +x /usr/local/bin/*
