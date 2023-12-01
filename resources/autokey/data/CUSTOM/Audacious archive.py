import os; exec(open(os.getenv('HOME') + '/bin/autokey-ctrl-c.py').read())

system.exec_command('''echo a;
IFS='\n'
f='{}'


if kdialog --warningcontinuecancel "Archive files?\n$(cat "$f")"; then
    mkdir -p ~/D/Archive/Musique_souvenir/2023-06-19/
    mv -i -- $(cat "$f") ~/D/Archive/Musique_souvenir/2023-06-19/ &&
    notify-send -t 10000 -- mv "Archived\n$(cat "$f")"
fi


'''.format(CTRL_C_file_fullpaths_file))
