import os; exec(open(os.getenv('HOME') + '/bin/autokey-ctrl-c.py').read())

system.exec_command("""echo a
firefox --private-window "https://www.google.com/search?q=$(xsel -o -b)"
""")

system.exec_command('echo a; xsel -b < /tmp/autokey-ctrl-c-clipboard-save')