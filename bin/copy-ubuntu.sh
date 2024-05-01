#!/bin/bash

# Copy a LUKS UEFI Ubuntu to another disk with LUKS (no LVM), changing all UUIDs
# Tested and working on Kubuntu 22.04

set -u -e

dst=$1 # Example: /dev/sdb
mode=$2 # Example: partition-disk
shift 2

# blkid is not reliable for freshly created filesystems so we use lsblk
get_fs_uuid_from_blk_or_mntpt() {
    lsblk -o UUID,MOUNTPOINT | awk "\$2 == \"$1\" { print \$1 }"
    lsblk -o UUID,PATH | awk "\$2 == \"$1\" { print \$1 }"
}

get_mapper_name() {
    luks_uuid=$(get_fs_uuid_from_blk_or_mntpt "$dst"3)
    echo "slash-$luks_uuid"
}

get_mnt_dir() {
    echo "/tmp/$(get_mapper_name)"
}

partition-disk() {
    ESP_SIZE=1G # Ubuntu default: 512M
    BOOT_SIZE=5G # Ubuntu default: 1.7G

    # Clear any existing partitions on the disk
    sudo sgdisk --zap-all "$dst"

    # Create ESP partition (EFI System Partition)
    # EFI system partition EF00 C12A7328-F81F-11D2-BA4B-00A0C93EC93B
    sudo sgdisk --new=0:0:+"$ESP_SIZE" --typecode=0:EF00 "$dst"

    # Create /boot partition
    # Default: Linux filesystem	8300 0FC63DAF-8483-4772-8E79-3D69D8477DE4
    sudo sgdisk --new=0:0:+"$BOOT_SIZE" "$dst"

    # Create remaining partition using all available space
    sudo sgdisk --largest-new=0 "$dst"

    # Print the partition table
    sudo sgdisk --print "$dst"

    sudo partprobe || sudo kpartx

    [ -e "$dst"3 ]
}

open-luks() {
    mapper_name=$(get_mapper_name)

    # Open the LUKS container
    sudo cryptsetup open "$dst"3 "$mapper_name" # Giving exactly the same /dev/mapper name as the LUKS UUID is not supported on Kubuntu 22.04
}

format-partitions() {
    sudo mkfs.fat -F 32 "$dst"1
    sudo mkfs.ext4 "$dst"2

    sudo cryptsetup luksFormat "$dst"3
    open-luks

    mapper_name=$(get_mapper_name)

    sudo mkfs.ext4 /dev/mapper/"$mapper_name"

    # Cancel auto-mounting
    sleep 2
    sudo umount "$dst"1 "$dst"2 /dev/mapper/"$mapper_name" || true
    sleep 2
}

mount-disk() {
    mapper_name=$(get_mapper_name)
    mnt_dir=$(get_mnt_dir)

    sudo mkdir -p -- "$mnt_dir"

    [ -e /dev/mapper/"$mapper_name" ] || open-luks

    sudo mount /dev/mapper/"$mapper_name" "$mnt_dir"

    sudo mkdir -p -- "$mnt_dir"/boot
    sudo mount "$dst"2 "$mnt_dir"/boot

    sudo mkdir -p -- "$mnt_dir"/boot/efi
    sudo mount "$dst"1 "$mnt_dir"/boot/efi
}

copy-files() {
    mnt_dir=$(get_mnt_dir)

    # Excludes are absolute starting in source
    sudo rsync -avx --exclude='/home/*/.cache/*' --exclude='/tmp/*' "$@" / "$mnt_dir" || true
    sudo rsync -av /boot "$mnt_dir" # TODO Check that /, /boot and /boot/efi dirs have the right permissions in dst
}

update_crypttab_fstab() {
    luks_uuid=$(get_fs_uuid_from_blk_or_mntpt "$dst"3)
    mapper_name=slash-$luks_uuid
    mnt_dir=$(get_mnt_dir)

    # Update crypttab: we put the LUKS UUID in crypttab
    (($(grep -c . /etc/crypttab) == 1)) # Check that there is only one line in /etc/crypttab
    echo "$mapper_name UUID=$luks_uuid none luks,discard" | sudo tee "$mnt_dir"/etc/crypttab

    # Update fstab
    previous_esp_uuid=$(get_fs_uuid_from_blk_or_mntpt /boot/efi)
    previous_boot_uuid=$(get_fs_uuid_from_blk_or_mntpt /boot)

    new_esp_uuid=$(get_fs_uuid_from_blk_or_mntpt "$dst"1)
    new_boot_uuid=$(get_fs_uuid_from_blk_or_mntpt "$dst"2)

    sudo sed -Ei "s/^UUID=$previous_esp_uuid[[:blank:]]/UUID=$new_esp_uuid /" "$mnt_dir"/etc/fstab
    sudo sed -Ei "s/^UUID=$previous_boot_uuid[[:blank:]]/UUID=$new_boot_uuid /" "$mnt_dir"/etc/fstab
    sudo sed -Ei "s|^/dev/mapper/[^[:blank:]]+([[:blank:]]+/[[:blank:]]+)|/dev/mapper/$mapper_name\1|" "$mnt_dir"/etc/fstab
    sudo sed -Ei '/swap/d' "$mnt_dir"/etc/fstab

    sudo sed -Ei "s/$previous_boot_uuid/$new_boot_uuid/" "$mnt_dir"/boot/efi/EFI/ubuntu/grub.cfg
}

run-in-chroot() {
    mnt_dir=$(get_mnt_dir)

    chroot.sh "$mnt_dir" bash -c 'update-initramfs -u; update-grub'
}

unmount-disk() {
    mapper_name=$(get_mapper_name)

    sudo umount "$dst"1
    sudo umount "$dst"2
    sudo umount /dev/mapper/"$mapper_name"
    sudo cryptsetup close "$mapper_name"
}

if [ "$mode" = all ]; then
    partition-disk
    format-partitions
    mount-disk
    copy-files "$@"
    update_crypttab_fstab
    run-in-chroot
    #unmount-disk
elif [ "$mode" = help ]; then
    echo "Usage: ${0##*/} /dev/sdX all"
    echo "       ${0##*/} /dev/sdX help"
    echo "       ${0##*/} /dev/sdX partition-disk"
    echo "       ${0##*/} /dev/sdX format-partitions"
    echo "       ${0##*/} /dev/sdX mount-disk"
    echo "       ${0##*/} /dev/sdX copy-files"
    echo "       ${0##*/} /dev/sdX update_crypttab_fstab"
    echo "       ${0##*/} /dev/sdX run-in-chroot"
    echo "       ${0##*/} /dev/sdX unmount-disk"
else
    "$mode" "$@"
fi
