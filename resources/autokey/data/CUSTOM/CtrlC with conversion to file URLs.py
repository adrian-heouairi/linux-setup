import os; exec(open(os.getenv('HOME') + '/bin/autokey-ctrl-c.py').read())

system.exec_command('''echo a

c=$(cat -- '{}')
if [ "$c" ]; then
    printf %s "$c" | xsel -b
    notify-send -i clipboard -- 'URL copy' "Copied file URL(s) to clipboard:\n$c"
else
    notify-send -i clipboard -- 'URL copy' "There were no paths in clipboard, restored previous clipboard"
fi

'''.format(CTRL_C_file_urls_file))

system.exec_command('echo a; wmctrl -k on; wmctrl -k off')
