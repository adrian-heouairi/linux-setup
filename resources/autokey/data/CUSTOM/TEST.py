#exec(open('/home/abc/bin/autokey-common-clipboard.py').read())
system.exec_command('echo a; xsel -o -b > /tmp/autokey_clipboard_save')
system.exec_command("echo a; gnome-calculator")
