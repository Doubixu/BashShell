#!/bin/bash
# eastmoney public tools
# version: v1.0.0
# create by XuHoo, 2016-10-12
#

function main() {
    if [[ "$USER" != "root" ]]; then
        echo "Current user is not root"
        return 1
    fi
    # TEMP_URL: download source address
    # TEMP_URL='http://172.16.1.1/nginx-1.8.1.tar.gz'
    wget -P /tmp/ $TEMP_URL/nginx.tar.gz
    tar -zxf /tmp/nginx.tar.gz
    sh /tmp/nginx_install.sh
}; main
