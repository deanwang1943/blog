FROM node:9.5-alpine
MAINTAINER Dean <wangjingxin1986@gmail.com>
RUN apk add --update --no-cache git
RUN apk add --update --no-cache openssh
RUN npm config set unsafe-perm true
RUN npm install
# install hexo
RUN npm install hexo-cli -g
# install hexo server
RUN npm install hexo-server
RUN npm install hexo-deployer-git
# 挂载 volume
VOLUME ["/bugs"]
# set home dir
WORKDIR /bugs
EXPOSE 4000


