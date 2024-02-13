FROM postgres:12.18-alpine
COPY fixtures /docker-entrypoint-initdb.d

ENV POSTGRES_PASSWORD=postgresisawesome \
    DATABASE_HOST=postgres \
    DATABASE_PORT=5432 \
    DATABASE_NAME=maurodatamapper \
    DATABASE_USERNAME=maurodatamapperuser \
    DATABASE_PASSWORD=jF80LQyP4BbH

COPY ./bin /usr/local/bin
RUN chmod +x /usr/local/bin/*
