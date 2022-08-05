#!/bin/bash

set -euo pipefail
qbs install --jobs 8 --clean-install-root  config:debug profile:custom_clang