#!/bin/bash

sudo yum -y update
sudo yum install epel-release -y
sudo yum install python -y
sudo yum install nginx -y
sudo systemctl stop nginx
sudo curl https://bootstrap.pypa.io/get-pip.py | sudo python -
sudo pip install virtualenv
mkdir ./sample-app
mkdir ./sample-app/app
virtualenv ./sample-app/sample-venv
source ./sample-app/sample-venv/bin/activate
sudo pip install gunicorn
sudo echo """def application(env, start_response):
    start_response('200 OK', [('Content-Type', 'text/html')])
    return ['Hello World!']""" > wsgi.py

sudo echo 'worker_processes 1;

events {
    worker_connections 1024;
}
http {
    sendfile on;
    gzip              on;
    gzip_http_version 1.0;
    gzip_proxied      any;
    gzip_min_length   500;
    gzip_disable      "MSIE [1-6]\.";
    gzip_types        text/plain text/xml text/css
                      text/comma-separated-values
                      text/javascript
                      application/x-javascript
                      application/atom+xml;
    upstream app_servers {
        server 127.0.0.1:8080;
    }
    server {
        listen 80;
        location ^~ /static/  {
            root /app/static/;

        }
        location = /favico.ico  {
            root /app/favico.ico;
        }
        location / {
            proxy_pass         http://app_servers;
            proxy_redirect     off;
            proxy_set_header   Host $host;
            proxy_set_header   X-Real-IP $remote_addr;
            proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header   X-Forwarded-Host $server_name;

        }
    }
}' | sudo tee /etc/nginx/nginx.conf
sudo setsebool -P httpd_can_network_connect 1
sudo systemctl start nginx
sudo gunicorn -b 127.0.0.1:8080 wsgi &

