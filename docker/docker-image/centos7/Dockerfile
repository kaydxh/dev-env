FROM centos:7.8.2003
MAINTAINER Kaydxh "xiao_hua_ding@sina.cn"
RUN yum -y update && yum -y install gcc && yum -y install gcc-c++ && yum -y install gdb && yum -y install git
RUN yum -y install cmake && yum -y install make
RUN yum -y install vim && yum -y install epel-release && yum -y install python-pip && pip install pip --upgrade
RUN pip install pyyaml && pip install requests
RUN yum -y net-tools && yum -y install openssl-devel

COPY profile /etc/profile
ADD default_config.yaml /root/.youtu_deps/default_config.yaml

RUN ln -s /Users/dingxiaohua /home/xhding

ENV  GOROOT=/usr/local/go  PATH=/usr/local/go/bin:$PATH GOPATH=/root/workspace/gopath
