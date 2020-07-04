# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

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
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

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


# *****************************************************************************
#
# customizations by Caspar below this point
#
# *****************************************************************************

source "$HOME/src/dot-files/.bashextras"

alias ep="dtrx --one-entry rename --noninteractive"

function parse_git_dirty {
  [[ $(git status 2> /dev/null | tail -n1) != "nothing to commit (working directory clean)" ]] || echo "*"
  }

  function parse_git_branch {
    git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/[\1$(parse_git_dirty)]/"
}
export PS1='\[\e[31;1m\]\t \w\[\e[0m\]$(__git_ps1 "[\[\e[0;32m\]%s\[\e[0m\]\[\e[0;33m\]$(parse_git_dirty)\[\e[0m\]]")\[\e[31;1m\] \$ \[\e[0m\]'


# Set the title to the current dir or the current command
case "$TERM" in
xterm*|rxvt*)
#    PROMPT_COMMAND='echo -ne "\033]0;${PWD}\007"'
   ;;
*)
    ;;
esac

# Define some path manipulation functions, courtesy of https://unix.stackexchange.com/a/270558
pathadd() {
    newelement=${1%/}
    if [ -d "$1" ] && ! echo $PATH | grep -E -q "(^|:)$newelement($|:)" ; then
        if [ "$2" = "after" ] ; then
            PATH="$PATH:$newelement"
        else
            PATH="$newelement:$PATH"
        fi
    fi
}
pathrm() {
    PATH="$(echo $PATH | sed -e "s;\(^\|:\)${1%/}\(:\|\$\);\1\2;g" -e 's;^:\|:$;;g' -e 's;::;:;g')"
}

# Ensure that bash is always hooked up to a running ssh-agent
# Original version at http://www.lofar.org/wiki/doku.php?id=public:ssh-usage-linux
SSH_AGENT_COUNT=$(pgrep -u $USER ssh-agent | wc -l)
if (( $SSH_AGENT_COUNT == 0 )); then
  eval $(ssh-agent 2> /dev/null)
  # Uncomment below line to debug
  # echo "Started new ssh-agent: $(env | grep SSH | tr '\n' ' ')"
elif (( $SSH_AGENT_COUNT == 1 )); then
  CANDIDATE_SSH_AGENT_PID=$(pgrep -u $USER ssh-agent)

  # Usually the socket is created by the parent process, which has a PID one less than ssh-agent
  CANDIDATE_SSH_AGENT_PPID=$CANDIDATE_SSH_AGENT_PID
  ((CANDIDATE_SSH_AGENT_PPID--))
  CANDIDATE_SSH_AUTH_SOCK=$(find /tmp -user $USER -type s -name agent.$CANDIDATE_SSH_AGENT_PPID 2> /dev/null)

  if [ ! -S "$CANDIDATE_SSH_AUTH_SOCK" ]; then
    # Didn't find a socket with expected name, so fall back to less rigorous search for socket
    # TODO: this could find more than 1 socket; we should fail hard here if that happens
    CANDIDATE_SSH_AUTH_SOCK=$(find /tmp -user $USER -type s -name 'agent.*' 2> /dev/null)
  fi

  # If we found a socket, set the environment variables
  if [ -S "$CANDIDATE_SSH_AUTH_SOCK" ]; then
    export SSH_AGENT_PID=$CANDIDATE_SSH_AGENT_PID
    export SSH_AUTH_SOCK=$CANDIDATE_SSH_AUTH_SOCK
    # Try to contact ssh-agent
    ssh-add -L >/dev/null 2>&1
    if [ $? -eq 2 ]; then # return code 2 means specifically we can't contact the ssh-agent
      echo "Failed to contact SSH agent (PID=$CANDIDATE_SSH_AGENT_PID, socket=$CANDIDATE_SSH_AUTH_SOCK)"
      unset SSH_AGENT_PID
      unset SSH_AUTH_SOCK
    else
      : # do nothing in this happy case (uncomment below line to debug)
      #echo "Reusing existing ssh-agent (PID=$CANDIDATE_SSH_AGENT_PID, socket=$CANDIDATE_SSH_AUTH_SOCK)"
    fi
  else
    echo "Failed to find existing ssh-agent socket (PID=$CANDIDATE_SSH_AGENT_PID, parent PID=$CANDIDATE_SSH_AGENT_PPID, CANDIDATE_SSH_AUTH_SOCK=${CANDIDATE_SSH_AUTH_SOCK})"
  fi
else
  echo "More than 1 ssh-agent running; not sure which one to connect to so doing nothing"
fi

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

[ - f ~/qmk_utils/activate_wsl.sh ] && source ~/qmk_utils/activate_wsl.sh
