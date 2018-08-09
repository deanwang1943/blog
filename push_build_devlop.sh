#!/usr/bin/env bash

# git commit and push
COMMIT_MSG=$1

git commit -m "${COMMIT_MSG}"

git push origin master

sudo docker start dean-hexo

sudo docker exec -it dean-hexo hexo clean && hexo g

sudo docker exec -it dean-hexo hexo d
