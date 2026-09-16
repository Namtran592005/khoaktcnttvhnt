# OpenLiteSpeed latest + LSPHP 8.4 cho WordPress.
# Base chính chủ đã gồm OLS, listener 80/443 và vhost localhost với docroot /var/www/vhosts/localhost/html.
FROM litespeedtech/openlitespeed:latest

# LSPHP 8.4 (mới nhất mà repo LiteSpeed có đủ ext, gồm opcache). Không cài redis/memcached vì đã bỏ khỏi stack.
COPY uploads.ini /tmp/uploads.ini
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        lsphp84 \
        lsphp84-common \
        lsphp84-mysql \
        lsphp84-curl \
        lsphp84-imagick \
        lsphp84-intl \
        lsphp84-opcache \
        lsphp84-redis \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf /usr/local/lsws/lsphp84/bin/lsphp /usr/local/lsws/fcgi-bin/lsphp8 \
    && ln -sf /usr/local/lsws/fcgi-bin/lsphp8 /usr/local/lsws/fcgi-bin/lsphp \
    && mkdir -p /usr/local/lsws/lsphp84/etc/php/8.4/litespeed/conf.d \
    && cat /tmp/uploads.ini >> /usr/local/lsws/lsphp84/etc/php/8.4/litespeed/php.ini \
    && cp /tmp/uploads.ini /usr/local/lsws/lsphp84/etc/php/8.4/litespeed/conf.d/99-wordpress.ini \
    && rm /tmp/uploads.ini

# Fix quyền ghi cho bind mount ./wordpress (thay container fix-perms cũ, không cần service riêng).
COPY ols-entrypoint.sh /ols-entrypoint.sh
RUN chmod +x /ols-entrypoint.sh
ENTRYPOINT ["/ols-entrypoint.sh"]