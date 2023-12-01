import os; exec(open(os.getenv('HOME') + '/bin/autokey-ctrl-c.py').read())

system.exec_command('''echo a

c=$(cat '{}')
printf %s "$c" | xsel -b
notify-send -- 'Copied fullpath(s) to clipboard' "$c"

'''.format(CTRL_C_file_fullpaths_file))

system.exec_command('echo a; wmctrl -k on; wmctrl -k off')
