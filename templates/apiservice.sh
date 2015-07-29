#!/usr/bin/env bash
cat <<EOF2
DEBUG=*
USVC_CONFIG_ENV=docker
NODE_ENV=development
usvc_amqp_url=amqp://admin:${NINJA_RABBIT_SECRET}@rabbit:5672
usvc_rpcService_signing_secret=${NINJA_SIGNING_SECRET}
usvc_activationService_signing_secret=${NINJA_SIGNING_SECRET}
usvc_modelStoreService_signing_secret=${NINJA_SIGNING_SECRET}
usvc_sessions_secret=${NINJA_SESSION_SECRET}
usvc_oauth_callbackURL=https://${NINJA_API_ENDPOINT}/auth/ninja/callback
usvc_oauth_authorizationURL=https://${NINJA_ID_ENDPOINT}/dialog/authorize
usvc_oauth_clientID=${NINJA_APP_TOKEN}
usvc_oauth_clientSecret=${NINJA_APP_KEY}
EOF2
