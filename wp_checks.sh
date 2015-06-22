


function check_markdown() {
    if type -P markdown &>/dev/null; then 
        MARKDOWN="markdown"
    else
        MARKDOWN=""
    fi
}

function check_browser() {
    if type -P gnome-open &>/dev/null; then 
        OPENBROWSER="gnome-open";
    elif type -P firefox &>/dev/null; then
        OPENBROWSER="firefox";
    elif type -P google-chrome &>/dev/null; then
        OPENBROWSER="google-chrome";
    elif type -P chromium-browser &>/dev/null; then
        OPENBROWSER="chromium-browser";
    elif type -P opera &>/dev/null; then
        OPENBROWSER="opera";
    else
        OPENBROWSER="";
    fi
}
function check_requirements() {
    type -P curl &>/dev/null || die "I require 'curl' but it's not installed."
    type -P sed  &>/dev/null || die "I require 'sed'  but it's not installed."
    type -P wc   &>/dev/null || die "I require 'wc'   but it's not installed."
    type -P seq  &>/dev/null || die "I require 'seq'  but it's not installed."
    type -P file &>/dev/null || die "I require 'file' but it's not installed."
    type -P grep &>/dev/null || die "I require 'grep' but it's not installed."
    type -P tput &>/dev/null || die "I require 'tput' but it's not installed."
    type -P php  &>/dev/null || die "I require 'php'  but it's not installed."

    check_browser
    [ -n "$OPENBROWSER" ] || warn "Cannot find a suitable browser to open URLs. Disabling effect of '-o' option!\n"
    check_markdown
   [ -n "$MARKDOWN" ] || warn "Cannot find a markdown converter to convert markdown to html.\n"
}
