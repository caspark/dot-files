# This file should live at ~/.config/fish/config.fish
# ln -s ~/src/dot-files/config.fish ~/.config/fish/config.fish

# fix SSH agent
if type -q ssh_agent_fix
    ssh_agent_fix
end

# configure fish's standard git prompt
set __fish_git_prompt_showdirtystate 'yes'
#set __fish_git_prompt_showstashstate 'yes'
set __fish_git_prompt_showuntrackedfiles 'yes'
#set __fish_git_prompt_showupstream 'yes'
set __fish_git_prompt_color_branch magenta

set __fish_git_prompt_char_dirtystate '!'
set __fish_git_prompt_char_stagedstate 'S'
set __fish_git_prompt_char_untrackedfiles 'A'
#set __fish_git_prompt_char_stashstate 'T'
set __fish_git_prompt_char_upstream_ahead '+'
set __fish_git_prompt_char_upstream_behind '-'

# version manager for node, ruby, python, etc: https://asdf-vm.com/
# see also https://github.com/asdf-vm/asdf-nodejs
# and other plugins at https://asdf-vm.com/#/plugins-all
if test -d ~/.asdf/
    source ~/.asdf/asdf.fish
end

if type -q fzf-pick-git-branch
    bind \eg fzf-pick-git-branch
end

# for some reason WSL prepopulates the APPDATA envvar, which breaks installation of libvips (needed for sharp node module)
set -e APPDATA

function __check_rvm --on-variable PWD --description 'Do rvm stuff'
    status --is-command-substitution; and return

    if test -f $HOME/.config/fish/functions/post-cwd.fish
        fish_post_cwd
    end
end

# if we're on WSL, then...
if type -q (which wsl.exe)
    # echo "wsl detected"
    if test -d /run/WSL/ # and we're on WSL 2, then...
        # echo "wsl version is 2"
        # we need to set our X server DISPLAY variable to the windows host box (assuming it's wsl2)
        set -g -x DISPLAY (route -n | grep -m1 '^0.0.0.0' | awk '{ print $2; }'):0.0
    else # we're on WSL 1
        # echo "wsl version is 1"
        # we need to get Docker to talk to the docker-daemon over TCP using TLS
        set -g -x DOCKER_HOST tcp://loopback-docker-bridge.test:2376
        set -g -x DOCKER_TLS_VERIFY 1
    end
end

# make control backspace delete a whole word
bind \cH backward-kill-path-component
# make control delete delete a whole word
bind \e\[3\;5~ kill-word
