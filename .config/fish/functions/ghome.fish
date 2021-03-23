# Defined in /tmp/fish.nng9P4/ghome.fish @ line 2
function ghome
    if test -d $HOME/.git
        echo "Disabling home repo and returning to previous work dir"
        mv $HOME/.git $HOME/.git-old
        popd
    else
        echo "Enabling home repo and jumping to ~/dotmore/"
        pushd $HOME/dotmore
        mv $HOME/.git-old $HOME/.git
    end
end
