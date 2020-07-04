function ssh_agent_fix
    set SSH_AGENT_PIDS (pgrep -u $USER ssh-agent)
    if set -q SSH_TTY
        ssh-add -L >/dev/null 2>&1
        set contact_status $status
        if test $contact_status -eq 0
            #echo "Detected SSH connection; reusing forwarded SSH agent"
        else
            #echo "Detected SSH connection but failed to contact SSH agent! Return code was "$contact_status
        end
	return
    end

    if test (count $SSH_AGENT_PIDS) -eq 0
        # the simple case: there's no SSH agent running, so start one
        # first nuke pre-existing ssh sockets, otherwise subsequent shells won't know which
        # ssh agent socket to connect to
        rm -rf /tmp/ssh-*
        # then start our own SSH agent
        eval (ssh-agent -c 2> /dev/null)
        #echo "Started new ssh-agent: "(env | grep SSH | tr '\n' ' ')
    else if test (count $SSH_AGENT_PIDS) -gt 1
        # More than one SSH agent is running (probably the OS started one or more of its own)
        # we have no way of knowing which one is the best one to connect to, so let's kill
        # all of them and start a new one
        for PID in $SSH_AGENT_PIDS
            # echo "Killing $PID"
            kill -9 $PID
        end
        # we also need to nuke pre-existing ssh sockets, otherwise subsequent shells won't know which
        # ssh agent socket to connect to
        rm -rf /tmp/ssh-*
        # now we're ready to start a new agent and use that
        eval (ssh-agent -c 2> /dev/null)
        #echo "Started new ssh-agent: "(env | grep SSH | tr '\n' ' ')
    else
        # we have exactly 1 SSH agent already running so let's try to connect to it
        set CANDIDATE_SSH_AGENT_PID (pgrep -u $USER ssh-agent)
        # Usually the socket is created by the parent process, which has a PID one less than ssh-agent
        set CANDIDATE_SSH_AGENT_PPID (math $CANDIDATE_SSH_AGENT_PID - 1)
        set CANDIDATE_SSH_AUTH_SOCK (find /tmp -user $USER -type s -name agent.$CANDIDATE_SSH_AGENT_PPID ^ /dev/null)

        if test -z $CANDIDATE_SSH_AUTH_SOCK || ! test -S $CANDIDATE_SSH_AUTH_SOCK
            # Didn't find a socket with expected name, so fall back to less rigorous search for socket
            # TODO: this could find more than 1 socket; we should fail hard here if that happens
            set CANDIDATE_SSH_AUTH_SOCK (find /tmp -user $USER -type s -name 'agent.*' ^ /dev/null)
        end

        # If we found a socket, set the environment variables
        if test -n $CANDIDATE_SSH_AUTH_SOCK && test -S $CANDIDATE_SSH_AUTH_SOCK
            set -gx SSH_AGENT_PID $CANDIDATE_SSH_AGENT_PID
            set -gx SSH_AUTH_SOCK $CANDIDATE_SSH_AUTH_SOCK
            # Try to contact ssh-agent
            ssh-add -L >/dev/null 2>&1

            # return code 2 means specifically we can't contact the ssh-agent
            if test $status -eq 2
                echo "Failed to contact SSH agent (PID=$CANDIDATE_SSH_AGENT_PID, socket=$CANDIDATE_SSH_AUTH_SOCK)"
                set -ge SSH_AGENT_PID
                set -ge SSH_AUTH_SOCK
                #else
                #echo "Reusing existing ssh-agent (PID=$CANDIDATE_SSH_AGENT_PID, socket=$CANDIDATE_SSH_AUTH_SOCK)"
            end
        else
            echo "Failed to find existing ssh-agent socket (PID=$CANDIDATE_SSH_AGENT_PID, parent PID=$CANDIDATE_SSH_AGENT_PPID)"
        end
    end
end

