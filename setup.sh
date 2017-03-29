#!/bin/bash

# install dependencies
sudo yum -y update
sudo yum install epel-release -y
sudo yum install python -y
sudo yum install nginx -y

# stop nginx
sudo systemctl stop nginx

# install pip
sudo curl https://bootstrap.pypa.io/get-pip.py | sudo python -

# set up virtual env
sudo pip install virtualenv
mkdir ./sample-app
mkdir ./sample-app/app
virtualenv ./sample-app/sample-venv
source ./sample-app/sample-venv/bin/activate

# install gunicorn
sudo pip install gunicorn

# create wsgi.py script for gunicorn
sudo echo """def application(env, start_response):
    start_response('200 OK', [('Content-Type', 'text/html')])
    return ['Hello World!']""" > wsgi.py

# configure nginx
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

# need this for RHEL linux distros
sudo setsebool -P httpd_can_network_connect 1

# start nginx
sudo systemctl start nginx

# start gunicorn listening to local interface
sudo gunicorn -b 127.0.0.1:8080 wsgi &

