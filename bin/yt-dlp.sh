#!/bin/bash

# Get a file written by default in the current directory from a URL
# Usage: yt-dlp.sh [OPTION]... [--] [YT-DLP OPTION]... [--] [URL]...
# You can override the default behavior by providing yt-dlp options e.g. --yes-playlist
# Options:
# If a title is parsed with --metadata-from-title, it will be used for the filename (instead of the actual video title) (new behavior with yt-dlp).
# -m --metadata: Use a and t to specify how the video title should be parsed to get the ID3v2.3 artist and title tags. Examples: -m 't - a'; -m t. Default is 't'. Not used if YouTube provides song metadata (viewable in the video description). If title is 'x - y - z', then 't - a' will yield title = 'x - y' and artist = 'z' (greedy).
# -d --directory: Specify a directory to save the files in. Default is current directory. Can end by a slash or not.

mft="%(title)s"
out="%(title)s - %(uploader)s.%(ext)s"
dir=.
mp3='--embed-chapters --embed-info-json --embed-subs'
while true; do
	case "$1" in
		-u|--no-uploader) out="%(title)s.%(ext)s"; shift;;
		-m|--metadata) mft=$(sed 's/t/%(title)s/g; s/a/%(artist)s/g' <<< "$2"); shift 2;;
		-d|--directory) dir=$2; shift 2;;
		-x|--extract-audio) mp3='--extract-audio --audio-format mp3 --audio-quality 3'; shift;;
		-h|--help) cat -- "$0"; exit 0;;
		--) shift; break;;
		*) break;;
	esac
done

yt-dlp --no-overwrites --no-playlist $mp3 --add-metadata --metadata-from-title "$mft" --embed-thumbnail --output "${dir%/}/$out" "$@"
