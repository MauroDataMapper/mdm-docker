FROM postgres:12.0-alpine
COPY fixtures /docker-entrypoint-initdb.d

COPY ./bin /usr/local/bin
RUN chmod +x /usr/local/bin/*
