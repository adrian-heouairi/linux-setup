#!/bin/bash

# Get an mp3 file written by default in the current directory from a URL
# Usage: mp3-dl.sh [OPTION]... [YOUTUBE-DL OPTION]... [URL]...
# Options:
# -u --uploader: Add uploader name at the beginning of filename, default is video title only. If a title is parsed with --metadata-from-title, it will be used for the filename (instead of the video title) (new with yt-dlp).
# -m --metadata: Use a and t to specify how the video title should be parsed to get the ID3v2.3 artist and title tags. Examples: -m 't - a'; -m t. Default is 't'. Not used if YouTube provides song metadata (viewable in the video description).
# -d --directory: Specify a directory to save the files in. Default is current directory. Can end by a slash or not.

mft="%(title)s"
out="%(title)s.%(ext)s"
dir=.
while true; do
	case "$1" in
		-u|--uploader) out="%(uploader)s - "$out; shift;;
		-m|--metadata) mft=$(sed 's/t/%(title)s/g; s/a/%(artist)s/g' <<< "$2"); shift 2;;
		-d|--directory) dir=$2; shift 2;;
		-h|--help) cat -- "$0"; exit 0;;
		--) shift; break;;
		*) break;;
	esac
done

yt-dlp --no-overwrites --no-playlist -x --audio-format mp3 --audio-quality 3 --add-metadata --metadata-from-title "$mft" --embed-thumbnail --output "${dir%/}/$out" "$@"
