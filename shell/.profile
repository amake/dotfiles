# MacPorts
export PATH=/opt/local/bin:/opt/local/sbin:$PATH

# Local scripts
export PATH=~/bin:PATH:~/local/bin:$PATH

export LANG=${LANG:-en_US.UTF-8}
export LC_ALL=${LC_ALL:-en_US.UTF-8}

export ANDROID_HOME=~/Library/Android/sdk
export OKAPI_HOME=/Applications/MacPorts/Okapi
export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
export ECLIPSE_HOME=/Applications/Eclipse.app/Contents/MacOS
export EMACS_HOME=/Applications/MacPorts/EmacsMac.app/Contents/MacOS
export GEM_HOME=$HOME/.gem
export PATH=$ECLIPSE_HOME:$OKAPI_HOME:$GEM_HOME/bin:$PATH:$ANDROID_HOME/platform-tools

export EDITOR=$EMACS_HOME/bin/emacsclient
alias ec=$EMACS_HOME/bin/emacsclient
alias e="$EMACS_HOME/bin/emacsclient -n"

export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

export DYLD_FALLBACK_LIBRARY_PATH=/opt/local/lib:$DYLD_FALLBACK_LIBRARY_PATH

export TESSDATA_PREFIX=/opt/local/share

[ -f ~/.profile_local ] && . ~/.profile_local

function launch() {
    cd ~
    nohup "$@" 2>&1 >/dev/null &
    cd - >/dev/null
}

function docker-clean() {
    docker rm $(docker ps -a -q)
    docker rmi $(docker images | grep '^<none>' | awk '{print $3}')
}

function port-clean() {
    while sudo port uninstall leaves; do true; done
    sudo port reclaim
}

function peco-cd() {
    TRG="$1"
    [[ -z "$TRG" ]] && TRG=.
    cd "$TRG/$(ls "$TRG" | peco)"
}

function activate-java7() {
    activate-java 1.7
}

function activate-java() {
    export JAVA_HOME=$(/usr/libexec/java_home -v $1)
    echo "JAVA_HOME=$JAVA_HOME"
}

function qrcode() {
    qrencode -o - "$*" | open -f -a Preview
}

function git-diff-html() {
    # https://www.w3.org/International/questions/qa-forms-utf-8
    REGEX='[\x0-\x7E]|[\xC2-\xDF][\x80-\xBF]|\xE0[\xA0-\xBF][\x80-\xBF]|[\xE1-\xEC\xEE\xEF][\x80-\xBF]{2}|\xED[\x80-\x9F][\x80-\xBF]|\xF0[\x90-\xBF][\x80-\xBF]{2}|[\xF1-\xF3][\x80-\xBF]{3}|\xF4[\x80-\x8F][\x80-\xBF]{2}'
    # ansi2html is in the `ansi2html-cli` npm package
    git diff --color --word-diff-regex=$REGEX "$@" | ansi2html
}

alias c="peco-cd ~/Code"
alias mysql-start="sudo port load mysql56-server"
alias mysql-stop="sudo port unload mysql56-server"
alias http-server="twistd -no web --path=."
alias handbrake="/Applications/HandBrake.app/Contents/MacOS/HandBrake"
