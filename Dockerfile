FROM alpine:latest

RUN apk add --update mysql-client curl bash musl-dev mariadb-connector-c-dev gcc nano && rm -rf /var/cache/apk/*
RUN mkdir /sql

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
