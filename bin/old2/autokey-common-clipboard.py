system.exec_command('echo a; xsel -o -b > /tmp/autokey_clipboard_save') # Save clipboard

keyboard.send_keys("<ctrl>+c")
time.sleep(.5)

# new_clipboard_with_url never has \n at the end
new_clipboard_with_url = system.exec_command('xsel -o -b')

# new_clipboard_without_url never has \n at the end
new_clipboard_without_url = system.exec_command('''
IFS='\n'
for i in $(xsel -o -b); do
    printf '%s\n' "$(file-url-to-fullpath.sh "$i")"
done
''')

system.exec_command('echo a; xsel -b < /tmp/autokey_clipboard_save') # Restore clipboard

new_clipboard_with_url_splitted = new_clipboard_with_url.split('\n')
new_clipboard_without_url_splitted = new_clipboard_without_url.split('\n')

with open('/tmp/autokey_clipboard', "w") as f: f.write(new_clipboard_without_url)
