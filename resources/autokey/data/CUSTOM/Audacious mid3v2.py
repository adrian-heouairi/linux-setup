import os; exec(open(os.getenv('HOME') + '/bin/autokey-ctrl-c.py').read())

system.exec_command('''echo a;
IFS='\n'
f='{}'


konsole --new-tab --hold -e mid3v2 -- $(cat "$f")


'''.format(CTRL_C_file_fullpaths_file))
