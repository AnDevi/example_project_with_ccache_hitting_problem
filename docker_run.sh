#!/bin/bash
set -euo pipefail
docker run -it --rm --mount src=$PWD/project,target=/build,type=bind -v ee-ccache:/ccache --name docker_example docker_example bash