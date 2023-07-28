# system.exec_command removes \n at the end if present

system.exec_command('echo a; rm -f /tmp/autokey-ctrl-c-file-urls /tmp/autokey-ctrl-c-fullpaths || true')
system.exec_command('echo a; xsel -o -b > /tmp/autokey-ctrl-c-clipboard-save')

if system.exec_command('xprop -id "$(xdotool getactivewindow)" WM_CLASS || true') == 'WM_CLASS(STRING) = "konsole", "konsole"':
    keyboard.send_keys("<ctrl>+<shift>+c")
else:
    keyboard.send_keys("<ctrl>+c")

time.sleep(.5)

clipboard = system.exec_command('xsel -o -b')

if clipboard.startswith('file://'):
    clipboard_fullpaths = system.exec_command('file-url-to-fullpath.sh "$(xsel -o -b)" || true')
    clipboard_urls_splitted = clipboard.split('\n')
    clipboard_fullpaths_splitted = clipboard_fullpaths.split('\n')
    
    # The existence of these files may prove the success of this script
    with open('/tmp/autokey-ctrl-c-fullpaths', "w") as f: f.write(clipboard_fullpaths)
    with open('/tmp/autokey-ctrl-c-file-urls', "w") as f: f.write(clipboard)

if clipboard.startswith('/'):
    clipboard_fullpaths_splitted = clipboard.split('\n')

#system.exec_command('echo a; xsel -b < /tmp/autokey-ctrl-c-clipboard-save')
