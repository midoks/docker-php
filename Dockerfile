#
# MAINTAINER		midoks <midoks@163.com>
# DOCKER-VERSION 	17.12.0-ce, build c97c6d6
#
# Dockerizing centos7: Dockerfile for building centos7 images

FROM		centos:centos7.1.1503
MAINTAINER  midoks <midoks@163.com>

ENV TZ "Asia/Shanghai"

ADD aliyun-mirror.repo /etc/yum.repos.d/CentOS-Base.repo
ADD aliyun-epel.repo /etc/yum.repos.d/epel.repo


RUN rpm --rebuilddb && yum install -y deltarpm && yum -y makecache fast

RUN rpm --rebuilddb && yum install -y curl wget tar bzip2 unzip vim-enhanced passwd sudo yum-utils hostname net-tools rsync man && yum install -y gcc gcc-c++ git make automake cmake patch logrotate python-devel libpng-devel libjpeg-devel


RUN rpm --rebuilddb && yum swap -y fakesystemd systemd && yum clean all
RUN rpm --rebuilddb && yum update -y  && yum clean all

RUN yum -y install epel-release
RUN rpm --rebuilddb && yum install -y python-pip
RUN pip install --upgrade pip

RUN pip install supervisor
ADD supervisord.conf /etc/supervisord.conf

RUN mkdir -p /etc/supervisor.conf.d && mkdir -p /var/log/supervisor


RUN rpm --rebuilddb && yum install -y pcre pcre-devel openssl openssl-devel
RUN mkdir -p /root/source
RUN wget -O /root/source/openresty-1.15.8.1.tar.gz https://openresty.org/download/openresty-1.15.8.1.tar.gz
RUN cd /root/source && tar -zxvf openresty-1.15.8.1.tar.gz
RUN cd /root/source/openresty-1.15.8.1 && ./configure --prefix=/usr/local/openresty \
	--with-http_v2_module \
	--with-http_stub_status_module \
	--with-ipv6 && make && make install


RUN wget -O /root/source/php-7.1.31.tar.bz2 https://www.php.net/distributions/php-7.1.31.tar.bz2
RUN cd /root/source && tar -xjf php-7.1.31.tar.bz2

RUN rpm --rebuilddb && yum install -y libxml2 libxml2-devel

RUN cd /root/source/php-7.1.31 && ./configure --prefix=/usr/local/php \
	--exec-prefix=/usr/local/php \
	--with-config-file-path=/usr/local/php/etc \
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
	&& make && make install


EXPOSE 22

ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]

