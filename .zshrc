# vim:foldmethod=marker foldlevel=1

#export TERM=xterm-24bit
#export COLORTERM=truecolor

move_to_top_of_path() {
  # Ensure a regex is provided
  if [[ -z "$1" ]]; then
    echo "Usage: move_to_top_of_path <regex>"
    return 1
  fi

  # Split $PATH into an array
  local IFS=':'
  local paths=($PATH)
  unset IFS

  # Array to hold matched paths
  local matched_paths=()
  # Array to hold unmatched paths
  local unmatched_paths=()

  # Iterate over paths
  for path in "${paths[@]}"; do
    if [[ "$path" =~ $1 ]]; then
      # If path matches regex, prepend to matched_paths array
      matched_paths=("$path" "${matched_paths[@]}")
    else
      # Else, keep in unmatched_paths array
      unmatched_paths+=("$path")
    fi
  done

  # Combine matched_paths and unmatched_paths, update $PATH
  PATH="${(j/:/)matched_paths}:${(j/:/)unmatched_paths}"

  export PATH
}

# set up nix (do this early so that nix-installed programs are available)
# NB: doesn't seem to be necessary on multiuser nix installs
[ -f ~/.nix-profile/etc/profile.d/nix.sh ] && source ~/.nix-profile/etc/profile.d/nix.sh

# {{{ Antigen config - load whatever plugins
# uncomment below line to enable logging - useful if a plugin install fails
#ANTIGEN_LOG=/tmp/zsh-antigen.log
source ~/.nix-profile/share/antigen/antigen.zsh

antigen use oh-my-zsh

# oh my zsh plugins:
antigen bundle colored-man-pages
antigen bundle command-not-found
antigen bundle docker # adds completions for docker only (no aliases)
antigen bundle zsh_reload # type src to reload configuration

# https://github.com/lukechilds/zsh-nvm
# (don't do export NVM_AUTO_USE=true because that makes cding to new dirs very slow)
export NVM_LAZY_LOAD=true
antigen bundle lukechilds/zsh-nvm

# https://github.com/wfxr/forgit
antigen bundle wfxr/forgit
# {{{ forgit's FZF commands quick reference:
# * git log -> glo
# * git diff -> gd
# * git reset file -> grh
# * git checkout file -> gcf
# * git checkout branch -> gcb
# * git checkout commit -> gco
# * stash viewer -> gss
# * clean picker -> gclean
# * rebase -i picker -> grb
# keybinds:
#   * ctrl + Y -> copy commit hash
#   * alt + j/k (p/n) -> move down/up in preview window
#   * ? -> toggle preview window
# }}}

# https://github.com/zsh-users/zsh-completions
antigen bundle zsh-users/zsh-completions

# https://github.com/zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-autosuggestions

# https://github.com/zsh-users/zsh-history-substring-search
antigen bundle zsh-users/zsh-history-substring-search

# https://github.com/zdharma/fast-syntax-highlighting
antigen bundle zdharma/fast-syntax-highlighting --branch=main

antigen apply
# }}} end plugins

# config for history-substring-search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down

# general config
export EDITOR=nvim

# aliases that don't have a better home
alias e="$EDITOR"
alias v="$VISUAL"
alias vim="nvim -O"
alias vi="nvim -O"
# attach to existing tmux session or create new tmux session if necessary
alias tux="tmux new -A -s tux"
# show bytes in a file
alias bytes="od -tc -An $argv"
# recompile qmk keyboard firmware - https://github.com/caspark/qmk_firmware/tree/master/keyboards/kinesis/keymaps/caspark
alias qmkc="qmk compile --keyboard kinesis/stapelberg --keymap caspark && cp ~/src/qmk_firmware/kinesis_stapelberg_caspark.hex /mnt/c/temp/"
alias gpu="git push -u origin HEAD"
alias gpuf="git push -u --force-with-lease origin HEAD"
alias rgc="rg --color=always"
alias dnf="dnf -C" # use system cache always to avoid unnecessary refreshing

# {{{ fzf and fzf plugin config
source ~/.nix-profile/share/fzf/key-bindings.zsh
source ~/.nix-profile/share/fzf/completion.zsh
# use fd (installed via nix) to generate options
_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}
_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}
# }}}

# {{{ completions
# {{{ npm completions
(( $+commands[npm] )) && {
  rm -f "${ZSH_CACHE_DIR:-$ZSH/cache}/npm_completion"

  _npm_completion() {
    local si=$IFS
    compadd -- $(COMP_CWORD=$((CURRENT-1)) \
                 COMP_LINE=$BUFFER \
                 COMP_POINT=0 \
                 npm completion -- "${words[@]}" \
                 2>/dev/null)
    IFS=$si
  }
  compdef _npm_completion npm
}
# }}}
# }}}

export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# {{{ functions
function ghome {
  if [[ -d "$HOME/.git" ]]; then
    echo "Disabling home repo and returning to previous work dir"
    mv $HOME/.git $HOME/.git-old
    popd
  else
    echo "Enabling home repo and jumping to ~/dotmore/"
    pushd $HOME/dotmore
    mv $HOME/.git-old $HOME/.git
  fi
}

function gbean {
  cd ~/src/beans && scripts/tmux.sh "$@"
}

function gslow {
  cd ~/src/slowrush && scripts/tmux.sh "$@"
}

function gwiz {
  cd ~/src/wizard-pixels && scripts/tmux.sh "$@"
}

function connect_to_or_start_ssh_agent {
  if [[ -v SSH_TTY ]]; then
    ssh-add -L >/dev/null 2>&1
    local CONTACT_STATUS="$?"
    if [[ "$CONTACT_STATUS" -eq 0 ]]; then
      # echo "DEBUG: Detected SSH connection; reusing forwarded SSH agent"
    else
      # echo "DEBUG: Detected SSH connection but failed to contact SSH agent! Return code was $contact_status"
    fi
    return
  fi

  local SSH_AGENT_PIDS="$(pgrep -u $USER ssh-agent | tr '\n' ' ')"
  local SSH_AGENT_PIDS_COUNT="$(echo -n "$SSH_AGENT_PIDS" | wc -w)"
  # echo "DEBUG: SSH agents PIDs found are $SSH_AGENT_PIDS; total PID count is $SSH_AGENT_PIDS_COUNT"

  if [[ "$SSH_AGENT_PIDS_COUNT" -eq 0 ]]; then
    # the simple case: there's no SSH agent running, so start one
    # first nuke pre-existing ssh sockets, otherwise subsequent shells won't know which
    # ssh agent socket to connect to
    rm -rf /tmp/ssh-*
    # then start our own SSH agent
    eval $(ssh-agent 2> /dev/null)
    # echo "DEBUG: Started new ssh-agent (no previous agent running): $(env | grep SSH | tr '\n' ' ')"
  elif [[ "$SSH_AGENT_PIDS_COUNT" -gt 1 ]]; then
    # More than one SSH agent is running (probably the OS started one or more of its own)
    # we have no way of knowing which one is the best one to connect to, so let's kill
    # all of them and start a new one
    # echo "DEBUG: Multiple SSH agents found so killing them all"

    # NB: the ${(z)foobar} syntax causes foobar's value to be split by words, so we can loop over each word.
    #     See https://zsh.sourceforge.io/Doc/Release/Expansion.html#Parameter-Expansion-Flags
    for PID in ${(z)SSH_AGENT_PIDS}; do
      # echo "DEBUG: Killing $PID"
      kill -9 $PID
    done
    # we also need to nuke pre-existing ssh sockets, otherwise subsequent shells won't know which
    # ssh agent socket to connect to
    rm -rf /tmp/ssh-*
    # now we're ready to start a new agent and use that
    eval "$(ssh-agent 2> /dev/null)"
    # echo "DEBUG: Started new ssh-agent after killing multiple old agents: $(env | grep SSH | tr '\n' ' ')"
  else
    # we have exactly 1 SSH agent already running so let's try to connect to it
    local CANDIDATE_SSH_AGENT_PID="$(pgrep -u $USER ssh-agent)"
    # Usually the socket is created by the parent process, which has a PID one less than ssh-agent
    local CANDIDATE_SSH_AGENT_PPID="$[$CANDIDATE_SSH_AGENT_PID - 1]"
    local CANDIDATE_SSH_AUTH_SOCK="$(find /tmp -user $USER -type s -name agent.$CANDIDATE_SSH_AGENT_PPID 2> /dev/null)"

    if [[ -z "$CANDIDATE_SSH_AUTH_SOCK" || ! -S "$CANDIDATE_SSH_AUTH_SOCK" ]]; then
      # echo "DEBUG: Failed to find auth socket from PID $CANDIDATE_SSH_AGENT_PID (PPID $CANDIDATE_SSH_AGENT_PPID)"
      # Didn't find a socket with expected name, so fall back to less rigorous search for socket
      # TODO: this could find more than 1 socket; we should fail hard here if that happens
      local CANDIDATE_SSH_AUTH_SOCK="$(find /tmp -user $USER -type s -name 'agent.*' 2> /dev/null)"
    fi

    # If we found a socket, set the environment variables
    if [[ -n "$CANDIDATE_SSH_AUTH_SOCK" && -S "$CANDIDATE_SSH_AUTH_SOCK" ]]; then
      export SSH_AGENT_PID="$CANDIDATE_SSH_AGENT_PID"
      export SSH_AUTH_SOCK="$CANDIDATE_SSH_AUTH_SOCK"
      # Try to contact ssh-agent
      ssh-add -L >/dev/null 2>&1

      # return code 2 means specifically we can't contact the ssh-agent
      if [[ "$?" -eq 2 ]]; then
        echo "ERROR: Failed to contact SSH agent (PID=$CANDIDATE_SSH_AGENT_PID, socket=$CANDIDATE_SSH_AUTH_SOCK)"
        unset SSH_AGENT_PID
        unset SSH_AUTH_SOCK
      else
        # echo "DEBUG: Reusing existing ssh-agent (PID=$CANDIDATE_SSH_AGENT_PID, socket=$CANDIDATE_SSH_AUTH_SOCK)"
      fi
    else
      echo "ERROR: Failed to find existing ssh-agent socket (PID=$CANDIDATE_SSH_AGENT_PID, parent PID=$CANDIDATE_SSH_AGENT_PPID)"
    fi
  fi
}

function define_dopus_shortcut {
    # Directory Opus only exists on Windows so this function should only be called in WSL.

    function dopus {
        # opens the current directory or the first arg in Directory Opus
        DOPUS_PATH="$(wslpath -a "C:\Program Files\GPSoftware\Directory Opus\dopus.exe")"
        echo $DOPUS_PATH
        if [ $# -gt 0 ]; then
            DOPUS_TARGET="$1"
        else
            DOPUS_TARGET="$(pwd)"
        fi
        $DOPUS_PATH "$(wslpath -w "$DOPUS_TARGET")"
    }
}

function adjust_for_wsl {
  # if we're on WSL, then...
  if [[ -f "$(which wsl.exe 2> /dev/null)" ]]; then
    # echo "DEBUG: wsl detected"
    define_dopus_shortcut
    if [[ -d /run/WSL/ ]]; then
      # echo "DEBUG: wsl version detected as 2"
      # we need to set our X server DISPLAY variable to the windows host box
      export DISPLAY="$(route -n | grep -m1 '^0.0.0.0' | awk '{ print $2; }'):0.0"

      # set the wslu's wslview app as browser to host use system browser
      # https://superuser.com/a/1368878
      export BROWSER="wslview"
    else # we're on WSL 1
      # echo "DEBUG: wsl version detected as 1"
      # we need to get Docker to talk to the docker-daemon over TCP using TLS
      export DOCKER_HOST="tcp://loopback-docker-bridge.test:2376"
      export DOCKER_TLS_VERIFY="1"
    fi
  fi
}

function configure_sourcegraph {
  if [[ -f "$HOME/.config/sourcegraph" ]]; then
    source "$HOME/.config/sourcegraph"
    alias sourgs="sourg search"
    function sourgg {
      # sourgg = sourcegraph grep
      sourg search -json "$1 type:file" | jq '.Results[] | { file: .file.url, context: .lineMatches[] | .preview } | .file + ": " + (.context|gsub("^ +"; ""))'
    }
    function sourgc {
      # sourgc = sourcegraph color grep
      sourgg "$1" | rg --color=always "$1"
    }
  fi
}

function configure_asdf {
  if [[ -f "$HOME/.asdf/asdf.sh" ]]; then
    . "$HOME/.asdf/asdf.sh"
  fi

  if [[ -f "$HOME/.asdf/plugins/java/set-java-home.zsh" ]]; then
    . "$HOME/.asdf/plugins/java/set-java-home.zsh"
  fi
}

# functions intended to be used interactively

function sd {
  # sd = (switch to a) source directory
  cd "$HOME/src/$(ls -1 ~/src/ | fzf)"
}

function sb {
  # sb = (switch to a) source directory
  cd "$HOME/srb/$(ls -1 ~/srb/ | fzf)"
}

function bd {
  # bd = background disown
  $@ &> /dev/null &
  disown
}

function ep {
  dtrx "$@"
}

unalias l
function l {
  if [ -d "$1" ] && [ $# -eq 1 ]; then
    exa -la --octal-permissions --git --icons "$1"
  elif [ $# -gt "0" ]; then
    bat "$@"
  else
    l .
  fi
}

function mx {
  chmod +x "$@" && echo "Now executable: $@"
}

# }}} end functions

# set -x
if [ "$DESKTOP_SESSION" = "plasma" ] && [ -f /usr/bin/ksshaskpass ]; then
  export GIT_ASKPASS=ksshaskpass
  export SSH_ASKPASS=ksshaskpass
  export SSH_ASKPASS_REQUIRE=prefer
else
  connect_to_or_start_ssh_agent
fi

adjust_for_wsl
configure_sourcegraph
configure_asdf
# set +x

# set up PATH - for path vs PATH, see https://superuser.com/a/1447959
typeset -U path # prevent duplicates
path=("$HOME/.local/bin"
      "$HOME/dotmore/bin"
      "$HOME/.yarn/bin"
      "$HOME/.fly/bin/"
      $path)
export PATH

if [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
  # make sure things we cargo-install take priority over other things
  move_to_top_of_path '.*cargo/bin'
fi

# set up the prompt using https://starship.rs/ (starship is installed via nix)
eval "$(starship init zsh)"

if [ -f "$HOME/.config/broot/launcher/bash/br" ]; then
  source "$HOME/.config/broot/launcher/bash/br"
fi

SUDO_EDITOR="$(which $EDITOR)"
export SUDO_EDITOR

# fix blurry font in electron apps like vscode under wayland
[ "$XDG_SESSION_TYPE" = 'wayland' ] && export ELECTRON_OZONE_PLATFORM_HINT=auto
