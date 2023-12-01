import os; exec(open(os.getenv('HOME') + '/bin/autokey-ctrl-c.py').read())

system.exec_command("""echo a
firefox --private-window "https://www.weblio.jp/content/$(cat -- '{}')"
""".format(CTRL_C_new_clipboard_file))
