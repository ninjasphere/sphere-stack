#!/usr/bin/env bash
cat <<EOF2
BACKEND_USER=admin
BACKEND_PASS=${NINJA_RABBIT_SECRET}
EOF2
