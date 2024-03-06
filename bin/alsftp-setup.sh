#!/bin/bash

# This script is idempotent

{
sudo sed -Ezi 's/#alsftp-start.*#alsftp-end\n?//' /etc/fstab

# See alsftp.conf example in resources
conf=$(grep -v '^#' ~/.config/linux-setup/alsftp.conf) || exit 1

local_ip_last_byte=$(get-local-ip-last-byte.sh) || exit 1

port="$local_ip_last_byte"022
group=alsftp
roots_dir=/als/alsftp-chroots

message_at_end=
fstab_lines=

sudo apt install -y openssh-server curl

sudo groupadd -- "$group"

users_to_remove=$(cut -d: -f1 /etc/passwd | grep '^alsftp-')
IFS=$'\n'
for i in $users_to_remove; do
    sudo userdel -- "$i"
done

public_ip=$(curl https://ipinfo.io/IP)

IFS=$'\n'
for line in $conf; do
    dir_to_share=$(cut -d$'\t' -f1 <<< "$line")
    username=alsftp-$(cut -d$'\t' -f2 <<< "$line")
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
        sudo chown -R "$UID:$UID" -- "$dir_to_share"

        sudo setfacl -R -d -m o::"$permissions" -- "$dir_to_share"
        sudo setfacl -R -m o::"$permissions" -- "$dir_to_share"
    fi

    # if [ "$permissions" = ro ]; then
    #     find "$dir_to_share" '(' '!' -type l ')' -exec sudo chmod o=rx {} ';'
    # elif [ "$permissions" = rw ]; then
    #     find "$dir_to_share" '(' '!' -type l ')' -exec sudo chmod o=rwx {} ';'
    # fi

    sudo useradd -g "$group" -d /shared -s /sbin/nologin -- "$username"
    yes -- "$password" | sudo passwd -- "$username"

    bind_mount_dir=$roots_dir/$username/shared

    sudo mkdir -p -- "$bind_mount_dir"
    sudo mount --bind -- "$dir_to_share" "$bind_mount_dir"
    fstab_lines+="$dir_to_share $bind_mount_dir none bind,nofail 0 0"$'\n'

    message_at_end+="Connect with command 'sftp sftp://$username@$public_ip:$port' and password '$password' or mount with command 'printf %s '$password' | sshfs $username@$public_ip:/shared <mount-dir> -p $port -o reconnect,password_stdin,ServerAliveInterval=5'"$'\n'
done

if [ "$fstab_lines" ]; then
    echo Adding to fstab:
    echo '#alsftp-start' | sudo tee -a /etc/fstab
    printf %s "$fstab_lines" | sudo tee -a /etc/fstab
    echo '#alsftp-end' | sudo tee -a /etc/fstab
fi

echo -n \
"Port $port
AllowTcpForwarding no
X11Forwarding no

AllowGroups $group

Match Group $group
ChrootDirectory $roots_dir/%u
ForceCommand internal-sftp
" | sudo tee /etc/ssh/sshd_config.d/CUSTOM-alsftp.conf > /dev/null

sudo systemctl enable ssh.service
sudo systemctl restart ssh.service

echo ========================================
printf %s "$message_at_end"
} 2>&1 | tee ~/.config/linux-setup/alsftp-setup-output.txt
