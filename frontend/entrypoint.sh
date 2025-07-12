#!/bin/sh

echo "Replacing BACKEND_IP with: ${BACKEND_IP}"

find /usr/share/nginx/html -type f \( -name '*.js' -o -name '*.html' -o -name '*.json' \) -exec \
    sed -i "s|BACKEND_IP|${BACKEND_IP}|g" {} +

exec "$@"