import os; exec(open(os.getenv('HOME') + '/bin/autokey-ctrl-c.py').read())

system.exec_command('''echo a;
IFS='\n'
[ -f /tmp/autokey-ctrl-c-fullpaths ] || exit 0


#qdbus org.kde.kglobalaccel /component/mediacontrol org.kde.kglobalaccel.Component.invokeShortcut pausemedia
if [ "$(cat /tmp/autokey-ctrl-c-fullpaths)" = "$(file-url-to-fullpath.sh "$(qdbus org.atheme.audacious /org/atheme/audacious org.atheme.audacious.SongFilename "$(qdbus org.atheme.audacious /org/atheme/audacious org.atheme.audacious.Position)")")" ]; then
    mpv --loop-file --force-window --start="$(LC_ALL=C awk "BEGIN { print $(qdbus org.atheme.audacious /org/atheme/audacious org.atheme.audacious.Time) / 1000 }")" --pause=no -- $(cat /tmp/autokey-ctrl-c-fullpaths)
else
    mpv --loop-file --force-window --start=0 --pause=no -- $(cat /tmp/autokey-ctrl-c-fullpaths | sed -n '$p')
fi

''')

system.exec_command('echo a; xsel -b < /tmp/autokey-ctrl-c-clipboard-save')
