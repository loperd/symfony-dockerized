#!/bin/bash
set -xe

composer config --global --auth http-basic.$COMPOSER_AUTH_REPO \
      $COMPOSER_AUTH_USER \
      $COMPOSER_AUTH_PASSWORD \
  && cd /app \
  && composer install -vvv \
      --no-interaction \
      --no-autoloader \
      --prefer-dist  \
      --no-ansi \
      --no-scripts \
  && composer dump-autoload

/usr/bin/rr -h
exec /usr/local/bin/gosu backend "$@"

