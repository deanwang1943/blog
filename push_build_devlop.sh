#!/usr/bin/env bash

# git commit and push
COMMIT_MSG=$1

git commit -am "${COMMIT_MSG}"

git push origin master

echo wjx123 | sudo -S docker start dean-hexo

echo wjx123 | sudo -S docker exec -it dean-hexo hexo clean && hexo g

echo wjx123 | sudo -S docker exec -it dean-hexo hexo d

echo wjx123 | sudo -S docker stop dean-hexo
