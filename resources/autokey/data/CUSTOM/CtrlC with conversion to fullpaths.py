ctrl_c_path = system.exec_command('which autokey-ctrl-c.py')
import os; exec(open(ctrl_c_path).read())

system.exec_command('''echo a

c=$(cat -- '{}')
if [ "$c" ]; then
    printf %s "$c" | xsel -b
    notify-send -i clipboard -- 'Fullpath copy' "Copied fullpaths to clipboard:\n$c"
else
    notify-send -i clipboard -- 'Fullpath copy' "There were no paths in clipboard, restored previous clipboard"
fi

'''.format(CTRL_C_file_fullpaths_file))

system.exec_command('echo a; wmctrl -k on; wmctrl -k off')
