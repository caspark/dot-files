# The following lines were added by compinstall

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate _prefix
zstyle ':completion:*' completions 1
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' glob 1
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}'
zstyle ':completion:*' max-errors 1 numeric
zstyle ':completion:*' menu select=1
zstyle ':completion:*' prompt 'Correcting... (%e errors found)'
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' substitute 'NUMERIC == 2'
zstyle ':completion:*' verbose true
zstyle :compinstall filename '/home/caspar/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=100000
setopt autocd extendedglob nomatch
unsetopt notify beep
bindkey -e
# End of lines configured by zsh-newuser-install

export COLORTERM=truecolor

# set up nix (do this early so that nix-installed programs are available)
source ~/.nix-profile/etc/profile.d/nix.sh

# plugins
source ~/.nix-profile/share/antigen/antigen.zsh

antigen use oh-my-zsh

antigen bundle colored-man-pages
antigen bundle command-not-found
antigen bundle docker
antigen bundle git
antigen bundle npm
antigen bundle systemd
antigen bundle yarn
antigen bundle zsh_reload

# https://github.com/lukechilds/zsh-nvm
antigen bundle lukechilds/zsh-nvm
export NVM_AUTO_USE=true

# https://github.com/zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-autosuggestions

# https://github.com/zdharma/fast-syntax-highlighting
antigen bundle zdharma/fast-syntax-highlighting

# https://github.com/zsh-users/zsh-history-substring-search
antigen bundle zsh-users/zsh-history-substring-search

antigen apply

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

# fzf plugin
source ~/.nix-profile/share/fzf/key-bindings.zsh
source ~/.nix-profile/share/fzf/completion.zsh
# use fd (installed via nix) to generate options
_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}
_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/home/caspar/.sdkman"
[[ -s "/home/caspar/.sdkman/bin/sdkman-init.sh" ]] && source "/home/caspar/.sdkman/bin/sdkman-init.sh"

# set up the prompt using https://starship.rs/ (starship is installed via nix)
eval "$(starship init zsh)"
