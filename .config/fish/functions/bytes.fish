# Defined in /tmp/fish.tcdBZe/bytes.fish @ line 1
function bytes
    # show bytes in a file
    od -tc -An $argv
end
