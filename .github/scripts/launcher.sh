#!/usr/bin/env bash

# -e: exit when any command fails
# -x: all executed commands are printed to the terminal
# -o pipefail: prevents errors in a pipeline from being masked
set -exo pipefail

export DOCKER_BUILD_DIR="/workspace/$PROJECT_NAME"

docker run --env-file .ci/docker.env \
           -v "$GITHUB_WORKSPACE:$DOCKER_BUILD_DIR" \
           "$DOCKER_IMAGE" \
           /bin/bash -c "$DOCKER_BUILD_DIR/.ci/docker.sh"

exit 0
