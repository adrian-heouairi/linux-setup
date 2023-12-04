# This script will press Ctrl+C, store the contents, then restore the previous clipboard

# system.exec_command removes \n at the end if present

CTRL_C_clipboard_backup_file = '/dev/shm/autokey-ctrl-c-clipboard-save.txt'
CTRL_C_new_clipboard_file = '/dev/shm/autokey-ctrl-c-new-clipboard.txt'

# These two will be empty if the Ctrl+C doesn't return fullpaths or file:// URLs
CTRL_C_file_urls_file = '/dev/shm/autokey-ctrl-c-file-urls.txt'
CTRL_C_file_fullpaths_file = '/dev/shm/autokey-ctrl-c-fullpaths.txt'

window_class = system.exec_command('echo a; get-current-window-class.sh')[2:]

import re
if re.search("^jetbrains", window_class):
    CTRL_C_clipboard_acquisition_command = 'qdbus org.kde.klipper /klipper getClipboardContents'
else:
    CTRL_C_clipboard_acquisition_command = 'xsel -o -b'

system.exec_command( "echo a; {} > '{}'".format(CTRL_C_clipboard_acquisition_command, CTRL_C_clipboard_backup_file) )

if window_class == 'konsole.konsole':
    keyboard.send_keys("<ctrl>+<shift>+c")
elif window_class == 'vscodium.VSCodium' or window_class == 'code.Code':
    #keyboard.send_keys("<ctrl>+c")
    keyboard.send_keys("<ctrl>+<alt>+c")
else:
    keyboard.send_keys("<ctrl>+c")

#time.sleep(.5)

system.exec_command("""echo a

clipboard_backup_file='{}'
new_clipboard_file='{}'
file_urls_file='{}'
file_fullpaths_file='{}'
window_class='{}'
clipboard_acquisition_command='{}'

old_clipboard=$(cat -- "$clipboard_backup_file")
for i in $(seq 1 50); do
    clipboard=$($clipboard_acquisition_command)
    [ "$clipboard" != "$old_clipboard" ] && break
    sleep .01
done

printf %s "$clipboard" > "$new_clipboard_file"

echo -n > "$file_urls_file"
echo -n > "$file_fullpaths_file"

HOME=~
if printf %s "$clipboard" | grep -E '^~(/|$)' > /dev/null; then
    clipboard=$(printf %s "$clipboard" | sed "s|^~|$HOME|")
fi

if printf %s "$clipboard" | grep '^file://' > /dev/null; then
    clipboard=$(file-url-to-fullpath.sh "$clipboard")
fi

if printf %s "$clipboard" | grep '^/' > /dev/null; then
    echo "$clipboard" > "$file_fullpaths_file"

    echo "$clipboard" | sed 's|^|file://|' > "$file_urls_file"
fi

xsel -b < "$clipboard_backup_file"

true""".format(CTRL_C_clipboard_backup_file, CTRL_C_new_clipboard_file, CTRL_C_file_urls_file, CTRL_C_file_fullpaths_file, window_class, CTRL_C_clipboard_acquisition_command))
