FROM alpine:latest

# Instal paket yang diperlukan untuk MySQL dan lighttpd
RUN apk add --update mysql-client curl bash musl-dev mariadb-connector-c-dev gcc nano lighttpd && rm -rf /var/cache/apk/*

# Buat direktori untuk SQL dan konfigurasi lighttpd
RUN mkdir /sql /etc/lighttpd

# Salin file konfigurasi lighttpd ke dalam container
COPY lighttpd.conf /etc/lighttpd/

# Salin script entrypoint
COPY entrypoint.sh /

# Berikan izin eksekusi pada script entrypoint
RUN chmod +x /entrypoint.sh

# Buka port 8080 untuk lighttpd
EXPOSE 8080

# Tentukan entrypoint
ENTRYPOINT ["/entrypoint.sh"]
