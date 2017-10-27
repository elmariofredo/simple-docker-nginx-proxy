#!/bin/sh
set -e

# Generate haproxy config using command arguments
/nginx-proxy-gen.sh ${service_host} ${service_id} ${service_location} > /etc/nginx/nginx.conf

echo "=== GENERATED NGINX PROXY CONFIG ===>"
cat /etc/nginx/nginx.conf
echo "=== GENERATED NGINX PROXY CONFIG ===<"

exec nginx -g 'daemon off;'
