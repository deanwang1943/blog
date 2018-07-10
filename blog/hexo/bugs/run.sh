apk add --update --no-cache openssh
mkdir ~/.ssh 
cp /bugs/id_rsa ~/.ssh
chmod 600 ~/.ssh/id_rsa

git config --global user.email "wangjingxin1943@163.com"
git config --global user.name "deanwang1943"

hexo clean
hexo g

echo 'wjx123' | hexo d
