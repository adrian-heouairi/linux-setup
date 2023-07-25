import os; exec(open(os.getenv('HOME') + '/bin/autokey-ctrl-c.py').read())

system.exec_command('''echo a;
IFS='\n'
[ -f /tmp/autokey-ctrl-c-fullpaths ] || exit 0


printf %s "$(cat /tmp/autokey-ctrl-c-fullpaths)" | xsel -b


''')

system.exec_command('echo a; wmctrl -k on; wmctrl -k off')
