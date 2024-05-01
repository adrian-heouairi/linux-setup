#!/bin/bash

target=$(realpath -- "$1")
shift

for i in proc sys dev; do # Maybe add run
    mountpoint "$target"/"$i" || sudo mount --rbind /"$i" "$target"/"$i"
done

sudo chroot "$target" /usr/bin/env -i HOME=/root TERM="$TERM" PATH="$PATH" "$@"

for i in proc sys dev; do
    if mountpoint "$target"/"$i"; then
        sudo mount --make-rslave "$target"/"$i"
        sudo umount -R "$target"/"$i"
    fi
done
