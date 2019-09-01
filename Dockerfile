#
# MAINTAINER		midoks <midoks@163.com>
# DOCKER-VERSION 	17.12.0-ce, build c97c6d6
#
# Dockerizing centos7: Dockerfile for building centos7 images

FROM		centos:centos7.1.1503
MAINTAINER  midoks <midoks@163.com>

ENV TZ "Asia/Shanghai"

ADD repo/aliyun-mirror.repo /etc/yum.repos.d/CentOS-Base.repo
ADD repo/aliyun-epel.repo /etc/yum.repos.d/epel.repo

RUN groupadd www
RUN useradd -g www -s /sbin/nologin www

RUN rpm --rebuilddb && yum -y install epel-release
RUN rpm --rebuilddb && yum install -y deltarpm && yum -y makecache fast
RUN rpm --rebuilddb && yum swap -y fakesystemd systemd && yum clean all
RUN rpm --rebuilddb && yum update -y  && yum clean all

RUN rpm --rebuilddb && yum install -y python-pip
RUN pip install --upgrade pip && pip install supervisor

RUN rpm --rebuilddb && yum install -y curl wget tar bzip2 unzip vim-enhanced \
	passwd sudo yum-utils hostname net-tools rsync man gcc gcc-c++ git make \
	automake cmake patch logrotate python-devel libpng-devel libjpeg-devel \
	pcre pcre-devel openssl openssl-devel libxml2 libxml2-devel



ADD supervisord/supervisord.conf /etc/supervisord.conf

RUN mkdir -p /etc/supervisor.conf.d && mkdir -p /var/log/supervisor
RUN mkdir -p /root/source

RUN wget -O /root/source/openresty-1.15.8.1.tar.gz https://openresty.org/download/openresty-1.15.8.1.tar.gz

RUN wget -O /root/source/php-7.1.31.tar.bz2 https://www.php.net/distributions/php-7.1.31.tar.bz2
RUN cd /root/source && tar -xjf php-7.1.31.tar.bz2



RUN cd /root/source && tar -zxvf openresty-1.15.8.1.tar.gz
RUN cd /root/source/openresty-1.15.8.1 && ./configure --prefix=/usr/local/openresty \
	--with-luajit \
	--with-http_v2_module \
	--with-http_stub_status_module \
	--with-ipv6 && make && make install


RUN cd /root/source/php-7.1.31 && ./configure --prefix=/usr/local/php71 \
	--exec-prefix=/usr/local/php71 \
	--with-config-file-path=/usr/local/php71/etc \
	--enable-mysqlnd \
	--with-mysqli=mysqlnd \
	--with-pdo-mysql=mysqlnd \
	--without-iconv \
	--enable-zip \
	--enable-mbstring \
	--enable-opcache \
	--enable-ftp \
	--enable-wddx \
	--enable-soap \
	--enable-sockets \
	--enable-simplexml \
	--enable-posix \
	--enable-sysvmsg \
	--enable-sysvsem \
	--enable-sysvshm \
	--enable-fpm \
	--with-openssl-dir=/usr/lib64/openssl \
	--with-openssl \
	&& make && make install

RUN cd /usr/local/php71/bin && ./pecl install yaf
RUN cd /usr/local/php71/bin && ./pecl install swoole


RUN mkdir -p /usr/local/openresty/nginx/conf/vhost
RUN mkdir -p /www

ADD www/	/www/
ADD conf/nginx.conf  /usr/local/openresty/nginx/conf/nginx.conf
ADD vhost/   /usr/local/openresty/nginx/conf/vhost/
ADD supervisord/openresty.conf /etc/supervisor.conf.d/openresty.conf

ADD conf/php-fpm 	 /usr/local/php71/php-fpm
ADD conf/php-fpm.conf /usr/local/php71/etc/php-fpm.conf
ADD conf/www.conf /usr/local/php71/etc/php-fpm.d/www.conf
ADD supervisord/php-fpm.conf /etc/supervisor.conf.d/php71-fpm.conf

EXPOSE 22
ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]

