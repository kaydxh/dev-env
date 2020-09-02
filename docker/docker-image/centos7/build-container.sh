# Created by kayxhding on 2020-09-02 10:09:59
#!/usr/bin/env bash

#build image
docker build -t kayxhding/centos7 .

#build container
docker run --privileged --security-opt seccomp=unconfined  -it --name dev-centos7  -v ~/workspace:/Users/dingxiaohua/workspace -v ~/Enviroment/gopath:/Users/dingxiaohua/workspace/gopath -v ~/Enviroment/lib:/usr/local -v ~/Downloads:/Users/dingxiaohua/Downloads kayxhding/centos7 /bin/bash
