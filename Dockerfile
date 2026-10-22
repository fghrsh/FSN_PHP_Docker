FROM php:7.4.33-fpm-alpine3.16

COPY --from=composer:2.10.3 /usr/bin/composer /usr/local/bin/composer

RUN apk add --no-cache --virtual .build-deps \
       $PHPIZE_DEPS \
       argon2-dev \
       coreutils \
       curl-dev \
       libsodium-dev \
       linux-headers \
       oniguruma-dev \
       openssl-dev \
       patch \
       readline-dev \
       sqlite-dev \
    && apk add --no-cache \
       postgresql-dev \
       freetype-dev \
       libpng-dev \
       tzdata \
       unzip \
       git \
       libzip-dev \
       gnu-libiconv-dev \
       imagemagick-dev \
       libintl \
       icu-dev \
       tidyhtml-dev \
       libxml2-dev \
       gettext-dev \
       libjpeg-turbo-dev \
    && docker-php-source extract \
    && curl -fsSL https://github.com/php/php-src/commit/712e60f9edfd03f0960fc4fc3c2c375f42b90aa2.patch -o /tmp/php-security.patch \
    && echo '5fe57ca6ee96d59b36c6e0ca842843c50884f177bef1e85234cf669b577f5e48  /tmp/php-security.patch' | sha256sum -c - \
    && patch --batch --fuzz=0 -d /usr/src/php -p1 < /tmp/php-security.patch \
    && tar -cJf /usr/src/php.tar.xz -C /usr/src php \
    && cd /usr/src/php \
    && rm -f /usr/include/iconv.h \
    && ln -s gnu-libiconv/iconv.h /usr/include/iconv.h \
    && export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS" \
    && ./configure $(php-config --configure-options) \
    && make -j"$(nproc)" \
    && make install \
    && make clean \
    && cd / \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" gd pdo_mysql mysqli pgsql pdo_pgsql opcache xmlrpc exif bcmath intl zip soap gettext sockets tidy \
    && pecl install redis-6.3.0 imagick-3.8.1 \
    && docker-php-ext-enable redis imagick \
    && docker-php-source delete \
    && rm -rf /tmp/pear /tmp/php-security.patch \
    && apk del .build-deps

RUN apk add --no-cache imagemagick

COPY php.ini /usr/local/etc/php/php.ini

CMD ["php-fpm"]
