FROM composer:2.0.2 AS composer
FROM php:7.4.1-alpine

ENV \
    COMPOSER_ALLOW_SUPERUSER="1" \
    COMPOSER_HOME="/tmp/composer"

# persistent / runtime deps
ENV PHPIZE_DEPS \
    postgresql-dev \
    build-base \
    autoconf \
    libc-dev \
    pcre-dev \
    pkgconf \
    cmake \
    file \
    re2c \
    g++ \
    gcc

# permanent deps
ENV PERMANENT_DEPS \
    postgresql-libs \
    oniguruma-dev \
    gettext-dev \
    icu-dev \
    libintl \
    bash \
    vim

COPY --from=composer /usr/bin/composer /usr/bin/composer

RUN set -xe \
    && apk add --no-cache ${PERMANENT_DEPS} \
    && apk add --no-cache --virtual .build-deps ${PHPIZE_DEPS} \
    # https://github.com/docker-library/php/issues/240
    && apk add --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/community gnu-libiconv \
    && docker-php-ext-configure mbstring --enable-mbstring \
    && docker-php-ext-configure opcache --enable-opcache \
    && docker-php-ext-configure bcmath --enable-bcmath \
    && docker-php-ext-configure pcntl --enable-pcntl \
    && docker-php-ext-configure intl --enable-intl \
    && docker-php-ext-configure pdo_pgsql \
    && docker-php-ext-install -j$(nproc) \
        pgsql pdo_pgsql \
        mbstring \
        sockets \
        gettext \
        opcache \
        bcmath \
        pcntl \
        intl \
    && apk del .build-deps \
    && rm -rf /app /home/user ${COMPOSER_HOME} /var/cache/apk/* \
    && mkdir /app /home/user ${COMPOSER_HOME} \
    && ln -s /usr/bin/composer /usr/bin/c

COPY ./php/conf.d/opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY ./php/conf.d/php.ini /usr/local/etc/php/php.ini
COPY ./shared/keep-alive.sh /app-entrypoint.sh

RUN set -xe \
    && chmod +x /app-entrypoint.sh \
    && composer --version \
    && php -v \
    && php -m

# DO NOT OVERRIDE ENTRYPOINT IF YOU CAN AVOID IT! @see <https://github.com/docker/docker.github.io/issues/6142>
ENTRYPOINT ["/app-entrypoint.sh"]
