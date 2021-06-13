# vim:foldmethod=marker foldlevel=1

export COLORTERM=truecolor

# set up nix (do this early so that nix-installed programs are available)
source ~/.nix-profile/etc/profile.d/nix.sh

# {{{ Antigen config - load whatever plugins
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

# https://github.com/zdharma/fast-syntax-highlighting
antigen bundle zdharma/fast-syntax-highlighting

# https://github.com/zsh-users/zsh-history-substring-search
antigen bundle zsh-users/zsh-history-substring-search

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
alias gpu="git push -u origin HEAD"
alias gpuf="git push -u --force-with-lease origin HEAD"

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

export SDKMAN_DIR="/home/caspar/.sdkman"
[[ -s "/home/caspar/.sdkman/bin/sdkman-init.sh" ]] && source "/home/caspar/.sdkman/bin/sdkman-init.sh"

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
# }}} end functions

# set up the prompt using https://starship.rs/ (starship is installed via nix)
eval "$(starship init zsh)"
