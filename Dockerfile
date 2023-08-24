FROM alpine:latest

RUN apk add --update mysql-client bash musl-dev mariadb-connector-c-dev gcc && rm -rf /var/cache/apk/*
RUN mkdir /sql

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]