#!/bin/bash

# TODO Set volumes to 100
# TODO Audacious volume should be 70% for audio+mic but 100% for me

# You might need to unmute some things in pavucontrol

[ "$1" = test ] && {
    int=
    trap '[ "$int" ] && exit 0; int=int; mpv /tmp/1.mp3; exit 0' SIGINT
    parec -d als_mic_and_audio_source | lame -r -v - /tmp/1.mp3 # als_mic_and_audio_sink.monitor
    exit 0
}

[ "$1" = restart ] && systemctl --user restart pulseaudio.service

pactl list sinks | grep -Ei 'sink|name:'
read -rp "Enter the speaker number you want to use: " selection
HEADSET=$selection

pactl list sources | grep -Ei 'source|name:'
read -rp "Enter the microphone number you want to use: " selection
MICROPHONE=$selection

pactl load-module module-null-sink sink_name=als_audio_sink sink_properties=device.description=als_audio_sink
pactl load-module module-null-sink sink_name=als_mic_and_audio_sink sink_properties=device.description=als_mic_and_audio_sink

pactl load-module module-loopback source=$MICROPHONE sink=als_mic_and_audio_sink

pactl load-module module-loopback source=als_audio_sink.monitor sink=als_mic_and_audio_sink
pactl load-module module-loopback source=als_audio_sink.monitor sink=$HEADSET

# This should not be necessary, however some programs (Zoom, etc.) won't be able to see monitors
# module-virtual-source has a high latency of ~400 ms, so it is better to use module-remap-source
# Convert the sink monitor to a source
pactl load-module module-remap-source master=als_mic_and_audio_sink.monitor source_name=als_mic_and_audio_source source_properties=device.description=als_mic_and_audio_source

pactl set-source-volume $MICROPHONE 250%
#pactl set-sink-volume als_audio_sink 70%

pidof audacious || audacious & disown
sleep .5
audacious --stop
sleep .5
audacious --play
sleep .5
audacious_sink_input_index=$(pactl list sink-inputs | grep -B16 'media.name = "Audacious"' | sed -n '1s/.*#//p')
audacious --pause
[[ "$audacious_sink_input_index" =~ ^[0-9]+$ ]] || {
    echo "Couldn't redirect Audacious"
    exit 1
}
pactl move-sink-input "$audacious_sink_input_index" als_audio_sink
