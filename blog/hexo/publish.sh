cd ./bugs
# sudo docker exec -it 86ca1a7ecf9b sh
docker run -it  -v ~/Documents/blog/blog/hexo/bugs:/bugs dean/bugs:v1 sh /bugs/run.sh
