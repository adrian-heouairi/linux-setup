ctrl_c_path = system.exec_command('which autokey-ctrl-c.py')
import os; exec(open(ctrl_c_path).read())

system.exec_command("""echo a
firefox --private-window "https://www.google.com/search?q=$(cat -- '{}')"
""".format(CTRL_C_new_clipboard_file))
