#!/bin/bash

sudo apt update -y
sudo apt install nginx -y
systemctl start nginx
systemctl enable nginx
echo "LUIT Rocks!" > /var/www/html/index.html