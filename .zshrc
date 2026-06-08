HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000
setopt hist_ignore_dups append_history share_history

PS1='%B%n@%m%b %~ %# '

autoload -Uz compinit && compinit

setopt no_beep

alias ls='ls --color=auto'
alias ll='ls -lh'
alias la='ls -lha'
