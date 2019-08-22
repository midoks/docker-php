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
ADD openresty.repo /etc/yum.repos.d/openresty.repo


RUN rpm --rebuilddb && yum install -y deltarpm && yum -y makecache fast

RUN rpm --rebuilddb && yum install -y curl wget tar bzip2 unzip vim-enhanced passwd sudo yum-utils hostname net-tools rsync man && yum install -y gcc gcc-c++ git make automake cmake patch logrotate python-devel libpng-devel libjpeg-devel


RUN yum -y install epel-release
RUN rpm --rebuilddb && yum install -y python-pip
RUN pip install --upgrade pip

RUN pip install supervisor
ADD supervisord.conf /etc/supervisord.conf

RUN mkdir -p /etc/supervisor.conf.d && \
    mkdir -p /var/log/supervisor

EXPOSE 22

ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]