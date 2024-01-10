#!/bin/bash

# Check that user is admin
if [ $(whoami) != "root" ]; then
  echo "This script must be run as root"
  exit 1
fi

apt update && apt upgrade -y

add-apt-repository ppa:openjdk-r/ppa

apt update

apt install openjdk-17-jre-headless

ufw allow 25565

wget https://launcher.mojang.com/v1/objects/c8f83c5655308435b3dcf03c06d9fe8740a77469/server.jar

mv server.jar minecraft_server_1.18.2.jar

java -Xms1024M -Xmx1024M -jar minecraft_server_1.18.2.jar nogui