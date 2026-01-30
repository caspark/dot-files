#!/usr/bin/env zsh
# wt - interactive git worktree switcher using fzf
#
# Usage: source this file (e.g. from .zshrc), then run `wt` in any git repo.
#
# Features:
#   - Lists all git worktrees via fzf with branch, lock status, and lock reason
#   - Selecting a worktree cd's into it
#   - Option to create a new worktree interactively
#
# Requirements: fzf, git
#
# Git natively resolves the repository root from any subdirectory, so this
# works from anywhere inside a repo -- no manual .git discovery needed.

wt() {
  # Resolve fzf binary path once (avoids issues with subshells not inheriting PATH)
  local fzf_bin
  fzf_bin=$(command -v fzf 2>/dev/null)
  if [[ -z $fzf_bin ]]; then
    echo "wt: fzf is required but not found" >&2
    return 1
  fi

  # git worktree list already walks up to find the repo root, so no
  # manual .git discovery is needed.
  local porcelain
  porcelain=$(git worktree list --porcelain 2>&1) || {
    echo "wt: not inside a git repository" >&2
    return 1
  }

  # Parse porcelain output into parallel arrays
  local -a wt_paths wt_labels
  local path head branch bare locked lock_reason prunable
  local idx=0

  _wt_flush() {
    [[ -z $path ]] && return
    # Build the one-line label
    local label="$path"
    if [[ -n $branch ]]; then
      label+="  [${branch#refs/heads/}]"
    elif [[ $bare == 1 ]]; then
      label+="  (bare)"
    else
      label+="  (detached)"
    fi
    if [[ -n $locked ]]; then
      if [[ -n $lock_reason ]]; then
        label+="  🔒 locked: $lock_reason"
      else
        label+="  🔒 locked"
      fi
    fi
    if [[ -n $prunable ]]; then
      label+="  ⚠ prunable"
    fi

    wt_paths+=("$path")
    wt_labels+=("$label")
    idx=$((idx + 1))

    path= head= branch= bare= locked= lock_reason= prunable=
  }

  local line
  while IFS= read -r line || [[ -n $line ]]; do
    if [[ -z $line ]]; then
      _wt_flush
      continue
    fi
    case $line in
      worktree\ *)  path="${line#worktree }" ;;
      HEAD\ *)      head="${line#HEAD }" ;;
      branch\ *)    branch="${line#branch }" ;;
      bare)         bare=1 ;;
      locked)       locked=1; lock_reason= ;;
      locked\ *)    locked=1; lock_reason="${line#locked }" ;;
      prunable)     prunable=1 ;;
    esac
  done <<< "$porcelain"
  _wt_flush
  unfunction _wt_flush 2>/dev/null

  if (( ${#wt_paths} == 0 )); then
    echo "wt: no worktrees found" >&2
    return 1
  fi

  # Present via fzf
  local new_entry="+ Create new worktree"
  local selection

  selection=$(
    {
      local j
      for (( j = 1; j <= ${#wt_labels}; j++ )); do
        echo "$j	${wt_labels[$j]}"
      done
      echo "new	$new_entry"
    } | "$fzf_bin" \
            --with-nth=2.. \
            --delimiter=$'\t' \
            --header="Select a git worktree (or create new)" \
            --height=~100% \
            --no-preview
  )

  [[ -z $selection ]] && return 0

  # Strip the leading index\t prefix
  local sel_id="${selection%%	*}"
  selection="${selection#*	}"

  if [[ $sel_id == "new" ]]; then
    # Interactive new worktree creation
    local new_branch new_path base_path
    echo -n "Branch name: "
    read -r new_branch
    [[ -z $new_branch ]] && { echo "Aborted." >&2; return 1; }

    # Default path: sibling of first worktree with branch name
    base_path="${wt_paths[1]:h}"
    echo -n "Path [$base_path/$new_branch]: "
    read -r new_path
    [[ -z $new_path ]] && new_path="$base_path/$new_branch"

    git worktree add -b "$new_branch" "$new_path" || return 1
    cd "$new_path"
    return 0
  fi

  # Extract path from label (everything before the first double-space)
  local target="${selection%%  *}"
  cd "$target"
}
