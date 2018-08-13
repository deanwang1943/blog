# 初始化本地
sudo docker run -it -v /home/dean/Documents/blog/blog/hexo/bugs:/bugs dean/bugs:v1  sh -c 'hexo init . && npm install && npm install hexo-deployer-git --save'
# 编译
sudo docker run -it -v /home/dean/Documents/blog/blog/hexo/bugs:/bugs dean/bugs:v1 hexo g
# 运行在客户端查看
sudo docker run -it -p 4000:4000 -v /home/dean/Documents/blog/blog/hexo/bugs:/bugs dean/bugs:v1 hexo s

# 发布
# sudo docker exec -it d4975793ab43 sh
sudo docker run -it  -v /home/dean/Documents/blog/blog/hexo/bugs:/bugs dean/bugs:v1 hexo d



sudo docker run --name dean-hexo -it -p 4000:4000 -v /home/dean/Documents/blog/blog/hexo/bugs:/bugs dean/bugs:v1 hexo s
sudo docker exec -it e8ba42f47231 sh
sh run.sh
