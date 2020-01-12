#!/bin/bash
set -e

CURRENT_DIR=${CURRENT_DIR:-$(dirname "$0")}
DOCKERFILE="Dockerfile.dev"
POSITIONAL=()

while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
  -m | --mode)
    DOCKERFILE=$([[ "$2" == prod* ]] && echo "Dockerfile.prod" || echo "Dockerfile.dev")
    shift
    shift
    ;;
  *)
    POSITIONAL+=("$1")
    shift
    ;;
  esac
done

set -- "${POSITIONAL[@]}"

docker build ${POSITIONAL[@]} -f "$CURRENT_DIR/$DOCKERFILE" "$CURRENT_DIR/../.."
