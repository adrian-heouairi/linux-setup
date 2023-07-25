import os; exec(open(os.getenv('HOME') + '/bin/autokey-ctrl-c.py').read())

system.exec_command('''echo a;
IFS='\n'
[ -f /tmp/autokey-ctrl-c-fullpaths ] || exit 0


if kdialog --warningcontinuecancel "Archive files?\n$(cat /tmp/autokey-ctrl-c-fullpaths)"; then
    mkdir -p ~/D/Archive/Musique_souvenir/2023-06-19/
    mv -i -- $(cat /tmp/autokey-ctrl-c-fullpaths) ~/D/Archive/Musique_souvenir/2023-06-19/ &&
    notify-send -t 10000 -- mv "Archived\n$(cat /tmp/autokey-ctrl-c-fullpaths)"
fi


''')

system.exec_command('echo a; xsel -b < /tmp/autokey-ctrl-c-clipboard-save')
