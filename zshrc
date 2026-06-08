HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000
setopt APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_SAVE_NO_DUPS HIST_IGNORE_SPACE

PS1='%B%n@%m%b %1~ %# '

autoload -Uz compinit && compinit

setopt NO_BEEP

alias ls='ls --color=auto -hv'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip -c=auto'

alias l='ls'
alias ll='ls -l'
alias la='ls -lA'

alias mv='mv -i'
