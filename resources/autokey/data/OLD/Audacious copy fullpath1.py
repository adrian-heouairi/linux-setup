ctrl_c_path = system.exec_command('which autokey-ctrl-c.py')
import os; exec(open(ctrl_c_path).read())

system.exec_command('''echo a;
IFS='\n'
[ -f /tmp/autokey-ctrl-c-fullpaths ] || exit 0


printf %s "$(cat /tmp/autokey-ctrl-c-fullpaths)" | xsel -b


''')

system.exec_command('echo a; wmctrl -k on; wmctrl -k off')
