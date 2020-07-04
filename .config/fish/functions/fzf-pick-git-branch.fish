# Defined in /tmp/fish.wnBvgr/fzf-pick-git-branch.fish @ line 2
function fzf-pick-git-branch --description 'List git branches'
  set -l commandline (__fzf_parse_commandline)
  set -l dir $commandline[1]
  set -l fzf_query $commandline[2]

  # "-path \$dir'*/\\.*'" matches hidden files/folders inside $dir but not
  # $dir itself, even if hidden.
  set -q FZF_PICK_BRANCH_COMMAND; or set -l FZF_PICK_BRANCH_COMMAND "
  git branch --list -a --format='%(refname)' 2> /dev/null | sed 's@^\./@@'"

  set -q FZF_TMUX_HEIGHT; or set FZF_TMUX_HEIGHT 40%
  begin
    set -lx FZF_DEFAULT_OPTS "--height $FZF_TMUX_HEIGHT --reverse $FZF_DEFAULT_OPTS $FZF_CTRL_T_OPTS"
    eval "$FZF_PICK_BRANCH_COMMAND | "(__fzfcmd)' -m --query "'$fzf_query'"' | while read -l r; set result $result $r; end
  end
  if [ -z "$result" ]
    commandline -f repaint
    return
  else
    # Remove last token from commandline.
    commandline -t ""
  end
  for i in $result
    set branch (echo "$i" | sed -e 's/refs\/heads\///' |  sed -e 's/refs\/remotes\/origin\///')
    commandline -it -- (string escape $branch)
    commandline -it -- ' '
  end
  commandline -f repaint
end
