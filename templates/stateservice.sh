#!/usr/bin/env bash
cat <<EOF2
DEBUG=true
REDIS_URL=redis://redis:6379
RABBIT_URL=amqp://admin:${NINJA_RABBIT_SECRET}@rabbit:5672
EOF2
