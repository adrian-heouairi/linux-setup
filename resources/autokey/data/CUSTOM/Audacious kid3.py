ctrl_c_path = system.exec_command('which autokey-ctrl-c.py')
import os; exec(open(ctrl_c_path).read())

system.exec_command('''echo a;
IFS='\n'
f='{}'


kid3 -- $(cat "$f")


'''.format(CTRL_C_file_fullpaths_file))
