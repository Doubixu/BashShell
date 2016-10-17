#!/bin/bash
# eastmoney public tools
# version: v1.0.1
# create by XuHoo, 2016-9-28
#

function environment() {
    yum -y install wget curl pcre pcre-devel zlib zlib-devel gcc gcc-c++ &> /tmp/nginx_install.log
    grep "nginx" /etc/passwd > /dev/null
    if [[ $? -ne 0 ]]; then  # check user and group
        groupadd nginx
        useradd -M -g nginx -s /sbin/nologin nginx
    fi
    cd /tmp; tar -zxf nginx.tar.gz; cd nginx
    return 0
}; environment; [ $? -ne 0 ] && exit 1

function install() {
    # Compile before installation configuration
    ./configure --prefix=/usr/local/nginx \
                --user=nginx --group=nginx \
                --with-http_stub_status_module \
                &> /tmp/nginx_install.log
    if [[ $? -ne 0 ]]; then
        return 1
    else
        # make && make install
        make &> /tmp/nginx_install.log
        make install &> /tmp/nginx_install.log
        if [[ $? -ne 0 ]]; then
            return 1
        fi
        return 0
    fi
}; install; [ $? -ne 0 ] && exit 1

function optimize() {
	ln -s /usr/local/nginx/sbin/* /usr/local/sbin/ > /dev/null
    cp -f /tmp/nginx_control.sh /etc/init.d/nginx
    cp -f /tmp/nginx.conf /usr/local/nginx/conf/nginx.conf
    # The number of CPU cores current server,
    # Amend the "worker_processes" field to the value of the processor
    processor=`cat /proc/cpuinfo | grep "processor" | wc -l`
    sed -i "s/^w.*;$/worker_processes  ${processor};/g" /usr/local/nginx/conf/nginx.conf
    chmod +x /etc/init.d/nginx
    chkconfig --add nginx
    retval=`chkconfig --level 3 nginx on`  # Configure nginx open start service
    return $retval
}; optimize; [ $? -ne 0 ] && exit 1

function run() {
    # Test nginx.conf file syntax is correct
    /etc/init.d/nginx test &> /tmp/nginx_run.log
    if [[ $? -ne 0 ]]; then
        retval=$?
    else  # Start nginx server
        /etc/init.d/nginx start &> /tmp/nginx_run.log
        if [[ $? -ne 0 ]]; then
            retval=$?
        fi
    fi
    return 0
}; run; [ $? -ne 0 ] && exit 1

function check() {
    # Modified index.html page content
    content=$"deployment on $(date "+%Y-%m-%d %H:%M:%S")"
    echo $content > /usr/local/nginx/html/index.html
    # View the index.html, and the output of the modified index.html page
    /etc/init.d/nginx status
    echo -n "Index.html: "; curl http://localhost
    rm -rf /tmp/nginx*
}; check
