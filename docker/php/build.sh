#!/usr/bin/env sh
set -e

CURRENT_DIR=${CURRENT_DIR:-$(dirname "$0")};

docker build "$@" -f "$CURRENT_DIR/Dockerfile" "$CURRENT_DIR/.."
