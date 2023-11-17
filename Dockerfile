FROM alpine:latest

# Install required packages
RUN apk add --update mysql-client curl bash musl-dev mariadb-connector-c-dev gcc nano screen && rm -rf /var/cache/apk/*
RUN mkdir -p /sql

# Copy entrypoint.sh
COPY entrypoint.sh /

# Set execute permission for entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose ports
EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
