#keyboard.send_keys("<ctrl>+<shift>+<f1>") # Disable IME, set this shortcut in Fcitx 5

ctrl_c_path = system.exec_command('which autokey-ctrl-c.py')
import os; exec(open(ctrl_c_path).read())

system.exec_command("xsel -b < '{}'".format(CTRL_C_new_clipboard_file))

#system.exec_command('echo a; if ! pidof tagainijisho; then tagainijisho & sleep 1; fi') # Doesn't return
if system.exec_command('echo -n a; pidof tagainijisho || true') == 'a':
    import subprocess; subprocess.run("tagainijisho & sleep 1", shell=True)

system.exec_command("""echo a
xdotool windowactivate --sync $(wmctrl -lp|grep 'Tagaini Jisho$' |
awk '$3 > 100 { print $1 }') || exit 1; sleep .1
""")
# $3 < 100 for firejail instance, $3 > 100 for non-firejail instance

keyboard.send_keys("<ctrl>+l")
keyboard.send_keys("<ctrl>+r")
keyboard.send_keys("<ctrl>+v")
keyboard.send_keys("<ctrl>+o")
time.sleep(.2)

system.exec_command("xsel -b < '{}'".format(CTRL_C_clipboard_backup_file))

system.exec_command('echo a; wmctrl -k on; wmctrl -k off')
