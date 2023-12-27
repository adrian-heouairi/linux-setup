ctrl_c_path = system.exec_command('which autokey-ctrl-c.py')
import os; exec(open(ctrl_c_path).read())

system.exec_command('''echo a;
IFS='\n'
f='{}'


for i in $(cat "$f"); do
    current_title=$(ffprobe -loglevel quiet -of default=nk=1:nw=1 -show_entries format_tags=title -- "$i") || continue
    [ "$current_title" ] && default=$current_title || default=$(basename -- "$i")
    new_title=$(kdialog --inputbox "New title for '$i':"'\n'"(current title is '$current_title')" -- "$default") || continue
    set-video-title.sh "$i" "$new_title"
done


'''.format(CTRL_C_file_fullpaths_file))
