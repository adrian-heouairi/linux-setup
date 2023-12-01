import os; exec(open(os.getenv('HOME') + '/bin/autokey-ctrl-c.py').read())

system.exec_command('''echo a

c=$(xsel -o -b)

HOME=~
c=$(printf %s "$c" | sed "s|^~|$HOME|")

printf %s "$c" | grep '^file://' > /dev/null || c=file://$c

printf %s "$c" | xsel -b
notify-send -- "Copied file URL to clipboard" "$c"

''')

system.exec_command('echo a; wmctrl -k on; wmctrl -k off')
