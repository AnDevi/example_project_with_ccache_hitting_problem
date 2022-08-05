#!/bin/bash
set -euo pipefail
docker build --build-arg USER_NAME=$(whoami) --build-arg USER_UID=$(id -u) --build-arg USER_GID=$(id -g) -t docker_example -f Dockerfile .