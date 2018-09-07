case "`uname -s`" in
  *Darwin*)
    if [[ -x /usr/local/bin/bash ]] && [[ $BASH != /usr/local/bin/bash ]]; then
      exec /usr/local/bin/bash -i
    fi
    ;;
esac

# If not running interactively, don't do anything
case $- in
    *i*) ;;
    *) return;;
esac

# append to the history file, don't overwrite it
# allow parallel histories
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=200000

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
  else
    color_prompt=
  fi
fi

if [ "$color_prompt" = yes ]; then
  PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
  PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
  xterm*|rxvt*|screen*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  ls --version 2>&1 | grep GNU >/dev/null && alias ls='ls --color=auto'
  # Try -G for color (macOS)
  ls -G >/dev/null 2>&1 && alias ls='ls -G'
  # dir --version 2>&1 | grep GNU >/dev/null && alias dir='dir --color=auto'
  # vdir --version 2>&1 | grep GNU >/dev/null && alias vdir='vdir --color=auto'

  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

#####################################################
# convenience aliases and functions
#####################################################
alias fnogit='find . -not \( -path ./.git -prune \) -type f'

#####################################################
# start of platform-dependent stuff
#####################################################
case "`uname -s`" in
"OS/390")
# z/OS
shopt -s checkwinsize checkjobs globstar
case "$TERM" in
  screen) TERM=xterm ;;
  screen-256color) TERM=xterm-256color ;;
esac
export TERM=$TERM
export TERMINFO=$TERMINFO
export PS1='\e[93m\s-\v\e[39m \e[91m\h\e[39m:\e[92m\W\e[39m\$ '

# .base_exports should define ZOS_PORTED, ZOS_LOCAL, and ZOS_JAVA
test -e "$HOME/.base_exports" && . "$HOME/.base_exports"

alias grep="$ZOS_LOCAL/bin/grep"
# Unilaterally tag all files in the directory hierarchy rooted at cwd
# as ascii. Useful for tarballs.
alias tagrecur_ascii='find . -type f -exec chtag -tc 819 {} \;'
# convert all 1047 text files in the directory hierarchy rooted at cwd
# to ascii
alias convall_ascii='/bin/find . -type f -filetag t -filetag_codeset 1047 -exec bash -c '\''iconv -F -T -t 819 "$1" >"$1.t" && mv -f "$1.t" "$1"'\'' dummy {} \;'

use_minimal() {
    env -i HOME=$HOME USER=$USER TERM=$TERM PERL5LIB=~/minlib LIBPATH=$ZOS_PORTED/lib/perl5/5.24.0/os390/CORE:./lib:/usr/lib:$ZOS_PORTED/lib:/usr/lpp/Printsrv/lib PATH=$ZOS_PORTED/bin:/bin:$ZOS_LOCAL/bin:/usr/sbin:/usr/lpp/Printsrv/bin:$ZOS_JAVA/IBM/J8.0_64/bin:/usr/lpp/ldap/sbin _BPXK_AUTOCVT=ON _CEE_RUNOPTS='FILETAG(AUTOCVT,AUTOTAG) POSIX(ON)' ${1:-bash --norc --noprofile}
}

# anaconda stuff
export _BPXK_JOBLOG=STDERR
# switch between shells when want to stay in conda env?
# Some functions to turn on and off conda.
anaconda_master_prefix="$ZOS_PORTED/IBM/izoda/anaconda"


turn_on_conda() {
    if [[ ! -z "$1" && ! "$PS1" =~ (root).* ]]; then
        turn_on_conda
    fi
    #unset PYTHONHOME
    #unset PYTHONPATH
    . $anaconda_master_prefix/bin/activate $1
    #export LIBPATH=".:$LIBPATH"
    #unalias vim 2> /dev/null
    #unalias vimdiff 2> /dev/null
    #unalias vi 2> /dev/null
    #unalias fc 2> /dev/null
    #unalias less 2> /dev/null
    #unalias git 2> /dev/null
    #unset -f man 2> /dev/null        # this one is actually needed
    #alias vim="TERMINFO= vim"
    #alias vimdiff="TERMINFO= vimdiff"
    #alias vi="TERMINFO= vi"
    #alias fc="TERMINFO= fc"
    #alias less="TERMINFO= less"
    #alias git="TERMINFO= git"
    #man() {
    #    /bin/man "$@" | TERMINFO= less
    #}
    # this next line is helpful when building python enviornments
    #export PYTHONHOME="$CONDA_PREFIX"
}
#turn_off_conda() {
#    #unset PYTHONHOME
#    #unset PYTHONPATH
#    . deactivate
#    #unalias vim
#    #unalias vimdiff
#    #unalias vi
#    #unalias fc
#    #unalias less
#    #unalias git
#    #man() {
#    #    /bin/man "$@" | less
#    #}
#}
# end anaconda stuff

#alias runwithcleanenv="_CEE_RUNOPTS='POSIX(ON)' env -i sh"

alias iconvtoa="iconv -f 1047 -t 819"   # iconv convert from ebcdic to ascii
alias iconvtoe="iconv -f 819 -t 1047"   # iconv convert from ascii to ebcdic
alias ode="od -A n -t cxC"              # od assuming encoding is ebcdic
alias oda="od -A n -t axC"              # od assuming encoding is ascii

pkill() {
    if [ x"$1" = x ]; then
        echo "Need an argument"
        return 1
    fi
    ps -e | grep "$1" | sed 's/^[ \t]*//g' | cut -d ' ' -f 1 | xargs kill
}

zos_ts_user=${USER^^}
mydumps() {
    ls -Ll /tmp | awk "/$zos_ts_user.*CEEDUMP/ {print \"/tmp/\" \$NF}"
}

man() {
   /bin/man "$@" | less
}
;;
esac

#####################################################
# end of platform-dependent stuff
#####################################################
