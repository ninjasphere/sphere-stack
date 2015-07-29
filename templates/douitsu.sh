#!/usr/bin/env bash
cat <<EOF2
DEBUG=*
CACHE_URL=redis://redis
DB_URL=mysql://douitsu:douitsu@mysql:3306/douitsu
NODE_ENV=production
EOF2
