#!/bin/bash
set -e

INPUT=("$@")
if [ "${#INPUT[@]}" -gt "1" ]; then
  CMD=("$@")
else
  # shellcheck disable=SC2207
  CMD=($(echo "${INPUT[@]}" | tr ' ' " "))
fi

if [ ! -f "/usr/bin/rr" ]; then
  chmod +x ./vendor/bin/rr
  ./vendor/bin/rr get-binary --location /usr/bin
  chmod +x /usr/bin/rr
fi

mkdir -p /etc/secrets/

/usr/local/bin/gosu backend /app/bin/env-local-dumper -s "$SECRET_NAME"
/usr/local/bin/gosu backend composer dump-env prod
/usr/local/bin/gosu backend /app/bin/console cache:clear --env=prod || true
/usr/local/bin/gosu backend /usr/bin/rr -h

# shellcheck disable=SC2154
if [[ -n "$PRIVILEGED_USER" && "$PRIVILEGED_USER" -eq "true" ]]; then
  exec "${CMD[@]}"
else
  exec /usr/local/bin/gosu backend "${CMD[@]}"
fi
