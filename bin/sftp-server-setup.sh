#!/bin/bash

{
sudo sed -Ezi 's/# acls-sftp start.*# acls-sftp end\n?//' /etc/fstab

# See sftp-server.conf example in resources
conf=$(grep -v '^#' ~/.config/linux-setup/sftp-server.conf) || exit 1

local_ip_last_byte=$(get-local-ip-last-byte.sh) || exit 1

port="$local_ip_last_byte"022
group=acls-sftp
roots_dir=/ACLS/sftp-roots

message_at_end=
fstab_lines=

sudo apt install -y openssh-server curl

sudo groupadd -- "$group"

users_to_remove=$(cut -d: -f1 /etc/passwd | grep '^acls-sftp-')
IFS=$'\n'
for i in $users_to_remove; do
    sudo userdel -- "$i"
done

public_ip=$(curl https://ipinfo.io/IP 2>/dev/null)

IFS=$'\n'
for line in $conf; do
    dir_to_share=$(cut -d$'\t' -f1 <<< "$line")
    username=acls-sftp-$(cut -d$'\t' -f2 <<< "$line")
    password=$(cut -d$'\t' -f3 <<< "$line")
    permissions=$(cut -d$'\t' -f4 <<< "$line")

    [[ $dir_to_share =~ ' ' ]] && {
        message_at_end+="Error: '$dir_to_share' contains spaces"$'\n'
        continue
    }

    [ -d "$dir_to_share" ] || {
        message_at_end+="Error: check that '$dir_to_share' is a directory"$'\n'
        continue
    }

    if [ "$permissions" != none ]; then
        sudo setfacl -R -d -m o::"$permissions" -- "$dir_to_share"
        sudo setfacl -R -m o::"$permissions" -- "$dir_to_share"
    fi

    # if [ "$permissions" = ro ]; then
    #     find "$dir_to_share" '(' '!' -type l ')' -exec sudo chmod o=rx {} ';'
    # elif [ "$permissions" = rw ]; then
    #     find "$dir_to_share" '(' '!' -type l ')' -exec sudo chmod o=rwx {} ';'
    # fi

    share_basename=$(basename -- "$dir_to_share")

    sudo useradd -g "$group" -d /"$share_basename" -s /sbin/nologin -- "$username"
    yes -- "$password" | sudo passwd -- "$username"

    bind_mount_dir=$roots_dir/$username/$share_basename

    sudo mkdir -p -- "$bind_mount_dir"
    sudo mount --bind -- "$dir_to_share" "$bind_mount_dir"
    fstab_lines+="$dir_to_share $bind_mount_dir none bind,nofail 0 0"$'\n'

    message_at_end+="Connect with command 'sftp sftp://$username@$public_ip:$port' or mount with command 'sshfs $username@$public_ip: <mount-dir> -p $port -o reconnect' with password $password"$'\n'
done

if [ "$fstab_lines" ]; then
    echo Adding to fstab:
    echo '# acls-sftp start' | sudo tee -a /etc/fstab
    printf %s "$fstab_lines" | sudo tee -a /etc/fstab
    echo '# acls-sftp end' | sudo tee -a /etc/fstab
fi

echo -n \
"Port $port
AllowTcpForwarding no
X11Forwarding no

AllowGroups $group

Match Group $group
ChrootDirectory $roots_dir/%u
ForceCommand internal-sftp
" | sudo tee /etc/ssh/sshd_config.d/CUSTOM-sftp.conf > /dev/null

sudo systemctl enable ssh.service
sudo systemctl restart ssh.service

echo ========================================
printf %s "$message_at_end"
} 2>&1 | tee ~/.config/linux-setup/sftp-server-output.txt
