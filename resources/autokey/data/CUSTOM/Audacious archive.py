ctrl_c_path = system.exec_command('which autokey-ctrl-c.py')
import os; exec(open(ctrl_c_path).read())

system.exec_command('''echo a;
IFS='\n'
f='{}'


if kdialog --warningcontinuecancel "Archive files?\n$(cat "$f")"; then
    mkdir -p ~/D/Archive/Musique_souvenir/2023-06-19/
    mv -i -- $(cat "$f") ~/D/Archive/Musique_souvenir/2023-06-19/ &&
    notify-send -t 10000 -- mv "Archived\n$(cat "$f")"
fi


'''.format(CTRL_C_file_fullpaths_file))
