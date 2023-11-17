FROM alpine:latest

WORKDIR /running

# Install required packages
RUN apk add --update mysql-client curl bash musl-dev mariadb-connector-c-dev gcc nano python3 screen && rm -rf /var/cache/apk/*
RUN mkdir /sql

# Copy entrypoint.sh
COPY entrypoint.sh /
COPY serv.py /running

# Set execute permission for entrypoint.sh
RUN chmod +x /entrypoint.sh
RUN chmod +x /serv.py

# Expose ports
EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
