ctrl_c_path = system.exec_command('which autokey-ctrl-c.py')
import os; exec(open(ctrl_c_path).read())

# TODO This one still has hardcoded values

system.exec_command('''echo a;
IFS='\n'
f='%s'


#qdbus org.kde.kglobalaccel /component/mediacontrol org.kde.kglobalaccel.Component.invokeShortcut pausemedia
if [ "$(cat "$f")" = "$(file-url-to-fullpath.sh "$(qdbus org.atheme.audacious /org/atheme/audacious org.atheme.audacious.SongFilename "$(qdbus org.atheme.audacious /org/atheme/audacious org.atheme.audacious.Position)")")" ]; then
    mpv --loop-file --force-window --start="$(LC_ALL=C awk "BEGIN { print $(qdbus org.atheme.audacious /org/atheme/audacious org.atheme.audacious.Time) / 1000 }")" --pause=no -- $(cat "$f")
else
    mpv --loop-file --force-window --start=0 --pause=no -- $(cat "$f" | sed -n '$p')
fi

''' % CTRL_C_file_fullpaths_file)
