# -*- sh-shell: bash; -*-

# MacPorts
export PATH=/opt/local/bin:/opt/local/sbin:$PATH

# Local scripts
export PATH=~/bin:~/.local/bin:$PATH

export LANG=${LANG:-en_US.UTF-8}
export LC_ALL=${LC_ALL:-en_US.UTF-8}

export ANDROID_HOME=~/Library/Android/sdk
export OKAPI_HOME=/Applications/MacPorts/Okapi
JAVA_HOME=$(/usr/libexec/java_home -v 1.8) && export JAVA_HOME
export ECLIPSE_HOME=$HOME/eclipse/java-latest-released/Eclipse.app/Contents/MacOS
export EMACS_HOME=/Applications/MacPorts/Emacs.app/Contents/MacOS
export FONTFORGE_HOME=/Applications/FontForge.app/Contents/Resources/opt/local/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools:$ECLIPSE_HOME:$OKAPI_HOME:$FONTFORGE_HOME

export FLUTTER_HOME=/Applications/flutter
export PATH=$FLUTTER_HOME/bin:$HOME/.pub-cache/bin:$PATH

export EDITOR=$EMACS_HOME/bin/emacsclient
alias ec='$EMACS_HOME/bin/emacsclient'
alias e='$EMACS_HOME/bin/emacsclient -n'

export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

gem_home="$(ruby -r rubygems -e 'puts Gem.user_dir')"
export PATH="$gem_home/bin:$PATH"

eval "$(rbenv init -)"

if [ -n "$WINDOW" ]; then
    PS1="\h[$WINDOW]:\W \u\$ "
fi

useYubikey=false

[ -f ~/.profile_local ] && . ~/.profile_local

launch() {
    (
        cd ~ || exit
        nohup "$@" >/dev/null 2>&1 &
    )
}

port-edit() {
    if (($# < 1)); then
        return 1
    fi
    local portfile
    portfile="$(port file "$1")"
    local content
    content="$(cat "$portfile")"
    $EDITOR "$portfile"
    if diff <(echo "$content") "$portfile" | grep -qE 'version|revision|epoch|\.setup'; then
        echo "Version changed; bumping..."
        sudo port fetch --no-mirrors "$1"
        sudo port bump "$1"
    fi
}

port-my-livecheck() {
    port -q echo maintainer:amake | xargs -P 0 -n 1 port -q livecheck
}

peco-cd() {
    local trg="${1:-.}"
    local sel
    sel="$(find "$trg" -type d -maxdepth 1 -exec basename -a {} + | peco)"
    [ -n "$sel" ] && cd "$trg/$sel" || return
}

java-activate() {
    unset JAVA_HOME # Workaround for Big Sur weirdness
    JAVA_HOME=$(/usr/libexec/java_home -v "$1") && export JAVA_HOME
    echo "JAVA_HOME=$JAVA_HOME"
}

qrcode() {
    qrencode -o - "$*" | open -f -a Preview
}

git-diff-html() {
    # https://www.w3.org/International/questions/qa-forms-utf-8
    local regex='[\x0-\x7E]|[\xC2-\xDF][\x80-\xBF]|\xE0[\xA0-\xBF][\x80-\xBF]|[\xE1-\xEC\xEE\xEF][\x80-\xBF]{2}|\xED[\x80-\x9F][\x80-\xBF]|\xF0[\x90-\xBF][\x80-\xBF]{2}|[\xF1-\xF3][\x80-\xBF]{3}|\xF4[\x80-\x8F][\x80-\xBF]{2}'
    # ansi2html is in the `ansi2html-cli` npm package
    git diff --color --word-diff-regex="$regex" "$@" | ansi2html
}

unique-name() {
    local candidate="$1"
    local base="${candidate%%.*}"
    [ "$candidate" != "$base" ] && local ext=".${candidate##*.}"
    local suffix=1
    while [ -e "$candidate" ]; do
        candidate="$base$suffix$ext"
        ((suffix++))
    done
    echo "$candidate"
}

dl-m3u8() {
    (
        set -u
        local useragent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:59.0) Gecko/20100101 Firefox/59.0'
        local outfile="${2:-$(unique-name output.mp4)}"
        ffmpeg -user_agent "$useragent" -i "$1" -c copy -bsf:a aac_adtstoasc "$outfile"
    )
}

git-fetch-all() {
    for repo in "$CODE_HOME"/*/.git/..; do
        (
            cd "$repo" || return
            echo -n "$(basename "$PWD"): "
            git fetch --all
        )
    done
}

git-prune-merged-branches() {
    local branch=${1:-master}
    git branch --merged "$branch" | grep -Ev "^\*? *${branch}" | xargs -n 1 -r git branch -d
}

code-clean-all() {
    _clean-one() {
        for proj in "$CODE_HOME"/*/"$1"; do
            (
                cd "$(dirname "$proj")" || return
                eval "$2"
            )
        done
    }
    _clean-one build.xml "ant clean"
    _clean-one pom.xml "mvn clean"
    _clean-one gradlew "rm -rf build"
    _clean-one .dart_tool "flutter clean"
    unset -f _clean-one
}

uncroph() {
    local img="$1"
    local base="${img%%.*}"
    local ext=".${img##*.}"
    local out="$base-uncrop$ext"
    convert "$img" -blur 128x64 -resize 200% "$img" -gravity center -composite -crop 100x50% "$out"
}

beep() {
    local n=${1:-1}
    while ((n-- > 0)); do
        printf '\007'
    done
}

yubikey-activate() {
    GPG_TTY=$(tty) && export GPG_TTY
    SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket) && export SSH_AUTH_SOCK
}

fd() {
    local dir
    dir=$(find "${1:-.}" -type d 2>/dev/null | fzf +m) && cd "$dir" || return
}

alias c='peco-cd "$CODE_HOME"'
alias handbrake='DYLD_LIBRARY_PATH=/opt/local/lib:$DYLD_LIBRARY_PATH /Applications/HandBrake.app/Contents/MacOS/HandBrake'

alias be='bundle exec'

# SSH via Yubikey; enable by setting useYubikey=true in ~/.profile_local
[[ "$useYubikey" == "true" ]] && activate-yubikey
