#!/bin/sh
set -e

service_host=$1
service_id=$2
service_location=$3

cat >/etc/nginx/nginx.conf <<EOL
user  nginx;
worker_processes  1;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;


events {
    worker_connections  4096;
}


http {
    include       /etc/nginx/mime.types;

    proxy_redirect          off;
    proxy_set_header        Host            \$host;
    proxy_set_header        X-Real-IP       \$remote_addr;
    proxy_set_header        X-Forwarded-For \$proxy_add_x_forwarded_for;
    client_max_body_size    10m;
    client_body_buffer_size 128k;
    proxy_connect_timeout   90;
    proxy_send_timeout      90;
    proxy_read_timeout      90;
    proxy_buffers           32 4k;

    default_type  application/octet-stream;

    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status $body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;

    keepalive_timeout  65;

    server { # simple reverse-proxy

        listen       80;
        server_name  ${service_host};

        location ${service_location}/ {
            rewrite ${service_location}/(.*) /\$1  break;
            proxy_pass http://${service_id};
        }

    }
}
EOL
