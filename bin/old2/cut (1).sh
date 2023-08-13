#!/bin/bash

# Writes a file in the current directory by default.
# Usage: cut.sh a.mp3 3 1:20.21
# Usage: cut.sh b.mkv 3.5 (to get between 3.5 s and the end)
# Usage: cut.sh c.mp4
# The timestamp format is [[hour:]minute:]second[.decimal_part_of_second].

script_name=cut.sh # Must not contain whitespace
[ "$script_name" ] || exit 1

tmpdir=/tmp/$script_name
mkdir -p -- "$tmpdir" || exit 1




audio_track= # Track index among tracks of all types
subtitle_track= # Same
subtitle_track_restricted= # Track index among only subtitle tracks

no_open=

extension=mp3
audio_codec=default # libmp3lame
video_codec=

dir=$(pwd) # Cannot be '.' because of a kdialog bug: kdialog --getsavefilename ./a doesn't work as expected
choose_fullpath=

title_override=
choose_title=

ffmpeg_options=

while :; do
	case "$1" in
		-d|--directory) dir=$2; shift 2;;
		-cf|--choose-fullpath) choose_fullpath=true; shift;;
		
		# The title tag of the output file is by default nothing if no title tag in source, and source title tag @ timestamps if there is a source title tag. Use --title to force a title, and --choose-title to get a GUI dialog to choose the title, containing either the argument of --title if present, or the automatically-determined title.
		-t|--title) title_override=$2; shift 2;;
		-ct|--choose-title) choose_title=true; shift;;
		
		-f|--format) IFS=, read -r extension audio_codec video_codec <<< "$2"; [ "$extension" ] || exit 1; [ "$audio_codec" ] || exit 1; shift 2;; # Argument of the form: file_extension_without_dot,audio_codec[,video_codec]. Video codec is necessary if the output has video, and must not be given if the output only has audio. For codecs, the special value 'default' is accepted (synonym 'd'). Examples: -f webm,opus,vp9 --format mp3,default
		#-v|--video) extension=mp4; audio_codec=aac; video_codec=h264; shift;;
		
		-a|--audio-track) [[ $2 =~ ^[0-9]+$ ]] && audio_track=$2; shift 2;; # All audio tracks are included if not given
		-s|--subtitle-track) [[ $2 =~ [0-9]+ ]] && subtitle_track=${2%,*}; subtitle_track_restricted=${2#*,}; shift 2;; # No subtitles are included if not given
		
		-n|--no-open) no_open=true; shift;;
		
		-o|--ffmpeg-options) ffmpeg_options=$2; shift 2;; # Example: -o '-q:a 3'
		
		-h|--help) cat -- "$0"; exit 0;;
		--) shift; break;;
		*) break;;
	esac
done

format-time() {
    IFS=: read -r s m h <<< "$(rev <<< "$1")"
    
    [ ! "$h" ] && h=0 || h=$(rev <<< "$h")
    [ ! "$m" ] && m=0 || m=$(rev <<< "$m")
    s=$(rev <<< "$s")
    
    LC_ALL=C awk "BEGIN { sum = $h * 3600 + $m * 60 + $s; printf(\"%d-%05.2f\", int(sum / 60), sum % 60) }"
}

[ "$2" ] || set -- "$1" 0

interval="@ $(format-time "$2")"
[ "$3" ] && interval=$interval" - $(format-time "$3")"

filename=$(basename -- "$1")
output_path=${dir%/}/$filename' '$interval.$extension

if [ "$choose_fullpath" ]; then
    output_path=$(kdialog --title="$script_name" --icon=mpv --getsavefilename -- "$output_path" 2> /dev/null) || exit
    [[ $output_path =~ ".$extension"$ ]] || exit 1
fi

[[ $(realpath -- "$output_path") == $(realpath -- "$1") ]] && exit 1

if [ "$title_override" ]; then
    title=$title_override
else
    title=$(ffprobe -loglevel quiet -of default=nk=1:nw=1 -show_entries format_tags=title -- "$1")
    [ "$title" ] && title="$title $interval"
fi

if [ "$choose_title" ]; then
    title=$(kdialog --title="$script_name" --icon=mpv --inputbox "Title tag of cut extract: $(printf =%.s {1..120})" -- "$title") || exit
fi

log_file=$tmpdir/$$_ffmpeg.log
progress_file=$tmpdir/$$_ffmpeg_progress.log

set -f # Disable globbing so the question mark in "-map 0:v?" is not interpreted
if [ "$video_codec" ]; then
    if [ "$subtitle_track" ]; then
        subtitle_codec=$(ffprobe -loglevel quiet -of default=nk=1:nw=1 -show_entries stream=codec_name -select_streams "$subtitle_track" -- "$1")
        picture_subtitles_to_burn=
        text_subtitles_to_burn=
        if [[ $subtitle_codec =~ ^(hdmv_pgs_subtitle|xsub|dvd_subtitle|dvb_subtitle)$ ]]; then
            picture_subtitles_to_burn=true
        else
            text_subtitles_to_burn=$tmpdir/$$_video
            ln -s -- "$1" "$text_subtitles_to_burn"
        fi
    fi
    ffmpeg_command=(ffmpeg -stats_period 3 -progress "$progress_file" -y -ss "$2" $([ "$3" ] && echo -to "$3") -copyts -i "$1" -ss "$2" $([ "$3" ] && echo -to "$3") $([[ $video_codec =~ ^(default|d)$ ]] || echo -vcodec $video_codec) $([[ $audio_codec =~ ^(default|d)$ ]] || echo -acodec $audio_codec) $([ "$picture_subtitles_to_burn" ] && echo -filter_complex [0:v][0:$subtitle_track]overlay[v] -map [v] || echo -map 0:v?) $([ "$audio_track" ] && echo -map 0:$audio_track || echo -map 0:a?) $([ "$text_subtitles_to_burn" ] && echo -vf subtitles=$text_subtitles_to_burn:stream_index=$subtitle_track_restricted) -metadata title="$title" $ffmpeg_options -- "$output_path")
else # Audio only
    ffmpeg_command=(ffmpeg -stats_period 3 -progress "$progress_file" -y -ss "$2" $([ "$3" ] && echo "-to $3") -copyts -i "$1" -ss "$2" $([ "$3" ] && echo "-to $3") -vcodec copy $([[ $audio_codec =~ ^(default|d)$ ]] || echo -acodec $audio_codec) $([ "$audio_track" ] && echo -map 0:v? -map -0:V? -map 0:$audio_track) -metadata title="$title" $ffmpeg_options -- "$output_path")
fi
set +f

echo "Running command: ${ffmpeg_command[*]}" &>> "$log_file"
"${ffmpeg_command[@]}" &>> "$log_file" &

tail -F --pid=$! -- "$progress_file" 2> /dev/null | grep -E --line-buffered '^speed=|^out_time=' 1>&2 &

wait -n %?ffmpeg_command || exit

printf '%s\n' "$output_path"

notify-send -i edit-cut -- "$script_name" "Cut finished for $output_path"

if ! [ "$no_open" ]; then
    cd -- "$(dirname -- "$output_path")"
    mpv --loop-file --pause --force-window --window-minimized -- "$output_path" &>/dev/null & disown
fi
