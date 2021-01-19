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

# Emacs vterm

vterm_printf() {
    if [ -n "$TMUX" ]; then
        # Tell tmux to pass the escape sequences through
        printf "\ePtmux;\e\e]%s\007\e\\" "$1"
    elif [ "${TERM%%-*}" = "screen" ]; then
        # GNU screen (screen, screen-256color, screen-256color-bce)
        printf "\eP\e]%s\007\e\\" "$1"
    else
        printf "\e]%s\e\\" "$1"
    fi
}

if [[ "$INSIDE_EMACS" = 'vterm' ]]; then
    alias clear='vterm_printf "51;Evterm-clear-scrollback";tput clear'
fi

autoload -U add-zsh-hook
add-zsh-hook -Uz chpwd (){ print -Pn "\e]2;%m:%2~\a" }

vterm_prompt_end() {
    vterm_printf "51;A$(whoami)@$(hostname):$(pwd)"
}

setopt PROMPT_SUBST
PROMPT=$PROMPT'%{$(vterm_prompt_end)%}'
