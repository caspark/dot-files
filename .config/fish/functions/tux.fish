# Defined in /tmp/fish.Kdvf9h/tux.fish @ line 2
function tux
    # attach to the tmux session if it exists, otherwise create one
    tmux new -A -s tux
end
