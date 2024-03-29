#!/bin/bash

# Check that user is admin
if [ $(whoami) != "root" ]; then
  echo "This script must be run as root"
  exit 1
fi

apt update && apt upgrade -y

apt install nginx tmux neofetch net-tools nmap mysql-server gnupg lsb-release gpg -y

type -p curl >/dev/null || (apt update && apt install curl  7 -y)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
&& chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& apt update \
&& apt install gh -y

curl -fsSL https://pgp.mongodb.com/server-6.0.asc | \
   gpg -o /usr/share/keyrings/mongodb-server-6.0.gpg \
   --dearmor

echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list

apt-get update

apt-get install -y mongodb-org

curl -fsSL https://packages.redis.io/gpg | gpg --dearmor -o 
/usr/share/keyrings/redis-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] 
https://packages.redis.io/deb $(lsb_release -cs) main" | tee 
/etc/apt/sources.list.d/redis.list

apt-get update
apt-get install redis

wget "https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh"

chmod +x install.sh

./install.sh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

nvm install v18

npm i -g pm2 serve create-next-app create-next-app nodemon

systemctl start mysql
systemctl start nginx
systemctl start mongod
