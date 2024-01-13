[ "$PWD" = "$HOME" ] && cd /tmp

#PS1='$?|\[\e[1;35m\]\w\[\e[m\]\$ '
PS1='|$?|$(br=$(git branch --show-current 2>/dev/null) && printf %s "\[\e[1;31m\]br:$br\[\e[m\]|")\[\e[1;34m\]\w\[\e[m\]\$ \[\e[6 q\]'

bashrc_custom_pwd() { pwd=${PWD/#"$HOME"/'~'}; printf '%s\n' "${pwd//[[:cntrl:]]}"; }
bashrc_custom_title() { [[ $(HISTTIMEFORMAT= history 1) =~ ^' '*[0-9]+' '*(.*) ]]; printf '%s\n' "${BASH_REMATCH[1]//[[:cntrl:]]}"; } # ($(bashrc_custom_pwd))
PS0=$PS0'$(printf "\e]0;%s\a" "* $(bashrc_custom_title) *")'
PROMPT_COMMAND=$PROMPT_COMMAND$'\n''((BASHRC_CUSTOM_HISTORY)) && printf "\e]0;%s\a" "$ $(bashrc_custom_title) $" || printf "\e]0;%s\a" "$ ($(bashrc_custom_pwd)) $"; BASHRC_CUSTOM_HISTORY=1'

HISTSIZE=
HISTFILESIZE=

PROMPT_COMMAND=$PROMPT_COMMAND$'\n'"history -a" # ; history -n

#echo -ne "\e[6 q" # Change cursor to still I-beam, works with Konsole, gnome-terminal, JetBrains, VSCode
