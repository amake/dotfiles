# MacPorts
export PATH=/opt/local/bin:/opt/local/sbin:$PATH

# Local scripts
export PATH=~/Library/Scripts:$PATH

export LANG=${LANG:-en_US.UTF-8}
export LC_ALL=${LC_ALL:-en_US.UTF-8}

export ANDROID_HOME=~/Library/Android/sdk
export OKAPI_HOME=/Applications/Okapi_0.32
export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
export ECLIPSE_HOME=/Applications/Eclipse.app/Contents/MacOS
export EMACS_HOME=/Applications/MacPorts/EmacsMac.app/Contents/MacOS
export GEM_HOME=$HOME/.gem
export PATH=$ECLIPSE_HOME:$OKAPI_HOME:$GEM_HOME/bin:$PATH

export EDITOR=$EMACS_HOME/bin/emacsclient
alias ec=$EMACS_HOME/bin/emacsclient

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

function activate-java-7() {
    export JAVA_HOME=$(/usr/libexec/java_home -v 1.7)
    echo "JAVA_HOME=$JAVA_HOME"
}

function adb-screencap() {
    OUTFILE=android-$(date +%s).png
    SDK_VER=$(adb shell getprop ro.build.version.sdk | tr -d '\n\r')
    if (( "$SDK_VER" >= 24 )); then
        adb shell screencap -p > $OUTFILE
    else
        # Prior to Android 7.0 the shell corrupted PNG output
        # with EOL conversion. See:
        # http://blog.shvetsov.com/2013/02/grab-android-screenshot-to-computer-via.html
        adb shell screencap -p | perl -pe 's/\x0D\x0A/\x0A/g' > $OUTFILE
    fi
}

function qrcode() {
    qrencode -o - "$*" | open -f -a Preview
}

alias c="peco-cd ~/Code"
alias mysql-start="sudo port load mysql56-server"
alias mysql-stop="sudo port unload mysql56-server"
alias http-server="twistd -no web --path=."
alias handbrake="/Applications/HandBrake.app/Contents/MacOS/HandBrake"
