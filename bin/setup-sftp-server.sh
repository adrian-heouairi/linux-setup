#!/bin/bash

password=$1

[ "$password" ] || exit 1

user=sftpu
port=2022

sudo apt install -y openssh-server curl

sudo mkdir -p /A/sftp-root/sftp
sudo chmod 777 /A/sftp-root/sftp
sudo setfacl -R -d -m o::rwx /A/sftp-root/sftp
sudo setfacl -R -m o::rwx /A/sftp-root/sftp
sudo groupadd sftp_users
#sudo userdel -- "$user"
sudo useradd -g sftp_users -d /sftp -s /sbin/nologin -- "$user"
yes -- "$password" | sudo passwd -- "$user"

echo -n \
"Port $port
AllowTcpForwarding no

AllowUsers sftpu

Match Group sftp_users
ChrootDirectory /A/sftp-root
ForceCommand internal-sftp
" | sudo tee /etc/ssh/sshd_config.d/CUSTOM-sftp.conf > /dev/null

sudo systemctl enable ssh.service
sudo systemctl restart ssh.service

echo "Connect with 'sftp sftp://sftpu@$(curl https://ipinfo.io/IP):$port'"
