FROM php:7.3.8-fpm-alpine

# PHP Composer
RUN wget https://mirrors.aliyun.com/composer/composer.phar -O /usr/local/bin/composer \
    && chmod a+x /usr/local/bin/composer \
    && composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/

RUN apk add --no-cache --virtual .build-deps \
       autoconf \
       g++ \
       libtool \
       make \
       pcre-dev \
    && apk add --no-cache\
       postgresql-dev \
       freetype-dev \
       libpng-dev \
       tzdata \
       unzip \
       git \
       libzip-dev \
       imagemagick-dev \
       libintl \
       icu \
       icu-dev \
       tidyhtml-dev \
       libxml2-dev \
       gettext-dev \
       freetype-dev \
       libjpeg-turbo-dev \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure opcache --enable-opcache \
    && docker-php-ext-install gd pdo_mysql mysqli pgsql pdo_pgsql opcache xmlrpc exif bcmath intl zip soap iconv gettext sockets tidy \
    && pecl install redis \
    && pecl install imagick \
    && docker-php-ext-enable redis imagick \
    && apk del .build-deps

COPY php.ini /usr/local/etc/php/php.ini

CMD ["php-fpm"]
