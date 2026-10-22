FROM php:8.5.12-fpm-alpine3.24

COPY --from=composer:2.10.3 /usr/bin/composer /usr/local/bin/composer

RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS linux-headers openssl-dev \
    && apk add --no-cache \
       postgresql-dev \
       freetype-dev \
       libpng-dev \
       tzdata \
       unzip \
       git \
       libzip-dev \
       imagemagick-dev \
       libintl \
       icu-dev \
       tidyhtml-dev \
       libxml2-dev \
       gettext-dev \
       libjpeg-turbo-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure ftp --with-ftp-ssl \
    && docker-php-ext-install -j"$(nproc)" gd pdo_mysql mysqli pgsql pdo_pgsql exif bcmath intl zip soap gettext sockets tidy ftp \
    && pecl install redis-6.3.0 imagick-3.8.1 \
    && docker-php-ext-enable redis imagick \
    && rm -rf /tmp/pear \
    && apk del .build-deps

COPY php.ini /usr/local/etc/php/php.ini

CMD ["php-fpm"]
