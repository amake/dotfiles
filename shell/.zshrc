# Lines originally configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=$HISTSIZE
setopt appendhistory
setopt histignorealldups
setopt histfindnodups
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '$HOME/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

export PROMPT='%m:%1~ %n%% '

# Case-insensitive completion
# https://qiita.com/watertight/items/2454f3e9e43ef647eb6b
zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}' '+m:{[:upper:]}={[:lower:]}'

# Bash-style word navigation/editing
autoload -U select-word-style
select-word-style bash

# Search history with peco
function peco-history-selection() {
    BUFFER=$(history -n 1 | tail -r | awk '!a[$0]++' | peco)
    CURSOR=$#BUFFER
    zle reset-prompt
}
if command -v peco >/dev/null; then
    zle -N peco-history-selection
    bindkey '^R' peco-history-selection
fi

autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line
