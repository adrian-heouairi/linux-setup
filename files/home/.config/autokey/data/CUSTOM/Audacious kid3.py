import os; exec(open(os.getenv('HOME') + '/bin/autokey-ctrl-c.py').read())

system.exec_command('''echo a;
IFS='\n'
[ -f /tmp/autokey-ctrl-c-fullpaths ] || exit 0


kid3 -- $(cat /tmp/autokey-ctrl-c-fullpaths)


''')

system.exec_command('echo a; xsel -b < /tmp/autokey-ctrl-c-clipboard-save')
