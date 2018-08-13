#!/usr/bin/env bash

# git commit and push
COMMIT_MSG=$1

git commit -am "${COMMIT_MSG}"

git push origin master

sudo -S docker start dean-hexo
 
sudo -S docker exec -it dean-hexo hexo clean && hexo g

sudo -S docker exec -it dean-hexo hexo d

sudo -S docker stop dean-hexo
