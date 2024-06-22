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
  -p | --parent)
    # shellcheck disable=SC2001
    PARENT_IMAGE=$(echo $2 | sed 's/["'"']*//g")
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

if [ -z "$PARENT_IMAGE" ]; then
  echo "Parent image name was not passed. Please pass with parameter --parent 'appname:tag'"
  exit 1
fi

export PARENT_IMAGE

SOURCE_DOCKERFILE="$CURRENT_DIR/$DOCKERFILE"

if [ ! -f "$SOURCE_DOCKERFILE" ]; then
  echo "Dockerfile by path " "$SOURCE_DOCKERFILE" " was not found."
  exit 1
fi

PREPARED_NAME=$(echo "$SOURCE_DOCKERFILE" | sed 's/^[./]*//g' | sed 's/\//./g')
TMP_DOCKERFILE="/tmp/$PREPARED_NAME"

if [ -f "$TMP_DOCKERFILE" ]; then
  rm -f "$TMP_DOCKERFILE"
fi

envsubst "\$PARENT_IMAGE" < "$SOURCE_DOCKERFILE" > "$TMP_DOCKERFILE"

docker build "${POSITIONAL[@]}" -f "$TMP_DOCKERFILE" "$CURRENT_DIR/../.."
