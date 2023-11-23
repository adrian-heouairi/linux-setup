import os; exec(open(os.getenv('HOME') + '/bin/autokey-ctrl-c.py').read())

system.exec_command('''echo a;
IFS='\n'
[ -f /tmp/autokey-ctrl-c-fullpaths ] || exit 0


for i in $(cat /tmp/autokey-ctrl-c-fullpaths); do
    current_title=$(ffprobe -loglevel quiet -of default=nk=1:nw=1 -show_entries format_tags=title -- "$i") || continue
    [ "$current_title" ] && default=$current_title || default=$(basename -- "$i")
    new_title=$(kdialog --inputbox "New title for '$i':"'\n'"(current title is '$current_title')" -- "$default") || continue
    set-video-title.sh "$i" "$new_title"
done


''')

system.exec_command('echo a; xsel -b < /tmp/autokey-ctrl-c-clipboard-save')
