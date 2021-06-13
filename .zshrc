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
# fzf isn't loaded till later, but specify the defaults here so they're picked up by forgit
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
antigen bundle wfxr/forgit

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
alias vim="nvim"
alias vi="nvim"

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

# set up the prompt using https://starship.rs/ (starship is installed via nix)
eval "$(starship init zsh)"
