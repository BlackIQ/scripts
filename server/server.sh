#!/bin/bash

# Check that user is admin
if [ $(whoami) != "root" ]; then
  echo "This script must be run as root"
  exit 1
fi

# Update and Upgrade
apt update && apt upgrade -y

# Install required packages
apt install nginx tmux neofetch net-tools nmap mysql-server gnupg lsb-release gpg tree python3-pip -y

# Install GitHub CLI
type -p curl >/dev/null || (apt update && apt install curl  7 -y)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
&& chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& apt update \
&& apt install gh -y

# Install MongoDB
curl -fsSL https://pgp.mongodb.com/server-6.0.asc | \
   gpg -o /usr/share/keyrings/mongodb-server-6.0.gpg \
   --dearmor

echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list

apt-get update

apt-get install -y mongodb-org

# Install Redis
curl -fsSL https://packages.redis.io/gpg | gpg --dearmor -o 
/usr/share/keyrings/redis-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] 
https://packages.redis.io/deb $(lsb_release -cs) main" | tee 
/etc/apt/sources.list.d/redis.list

apt-get update
apt-get install redis

# Install NVM (Node Version Manager)
wget "https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh"

chmod +x install.sh

./install.sh

# Export NVM PATH
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Install LTS node version
nvm install --lts

# Install required npm packages
npm i -g pm2 serve create-next-app create-next-app nodemon

# Install required pip packages
pip3 install art

# Restart services
systemctl start mysql
systemctl start nginx
systemctl start mongod

# Welcome package
mkdir -p /apps/welcome
echo "import art; art.tprint('Welcome, Amir!')" > /apps/welcome/welcome.py
echo 'python3 /apps/welcome/welcome.py' >> ~/.bashrc