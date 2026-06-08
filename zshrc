HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000
setopt APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_SAVE_NO_DUPS HIST_IGNORE_SPACE
setopt NO_BEEP

PS1='%B%n@%m%b%b %1~ %(?.%#.%F{red}%#%f) '

autoload -Uz compinit && compinit

autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

alias ls='ls --color=auto -hv'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip -c=auto'

alias l='ls'
alias ll='ls -l'
alias la='ls -lA'
