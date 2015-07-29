#!/usr/bin/env bash
cat <<EOF2
DEBUG=*
USVC_CONFIG_ENV=docker
NODE_ENV=development
usvc_amqp_url=amqp://admin:${NINJA_RABBIT_SECRET}@rabbit:5672
usvc_modelStoreService_signing_secret=${NINJA_SIGNING_SECRET}
EOF2
