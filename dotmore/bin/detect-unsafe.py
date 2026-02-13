#!/usr/bin/env python3
"""
detect-unsafe.py — Find the last occurrence of `unsafe` being added or removed in git history.

Uses `git log -S unsafe` to find commits that changed the count of `unsafe`,
then shows the diff through git's configured pager (e.g. delta).

Usage:
    detect-unsafe.py [--repo <path>] [--count <n>]

Options:
    --repo <path>   Repository path (default: current directory)
    --count <n>     Number of commits to show (default: 1)
"""

import subprocess
import sys
import argparse
import os
import shutil


def run(cmd, cwd=None):
    result = subprocess.run(cmd, capture_output=True, text=True, cwd=cwd)
    return result.stdout.strip(), result.stderr.strip(), result.returncode


def get_pager(repo):
    """Get the pager configured for git diff/show."""
    # Check pager.show first, then pager.diff, then core.pager, then PAGER env, then less
    for key in ["pager.show", "pager.diff", "core.pager"]:
        stdout, _, rc = run(["git", "config", "--get", key], cwd=repo)
        if rc == 0 and stdout:
            return stdout
    return os.environ.get("PAGER", "less")


def main():
    parser = argparse.ArgumentParser(description="Detect last unsafe additions/removals in git history")
    parser.add_argument("--repo", default=".", help="Repository path")
    parser.add_argument("--count", type=int, default=1, help="Number of commits to show")
    parser.add_argument("--no-pager", action="store_true", help="Don't use a pager")
    args = parser.parse_args()

    repo = os.path.abspath(args.repo)

    # Find commits that changed the count of 'unsafe' in .rs files
    stdout, stderr, rc = run(
        ["git", "log", "-S", "unsafe", f"-n{args.count * 3}", "--pretty=format:%H %h %ai %s", "--", "*.rs"],
        cwd=repo
    )

    if rc != 0:
        print(f"Error running git log: {stderr}", file=sys.stderr)
        sys.exit(1)

    if not stdout:
        print("No commits found that add or remove 'unsafe' in Rust files.")
        sys.exit(0)

    commits = stdout.strip().split("\n")

    # Collect commit hashes that have actual unsafe keyword changes (not just the word in comments etc)
    valid_hashes = []
    for line in commits:
        if len(valid_hashes) >= args.count:
            break
        parts = line.split(" ", 3)
        if len(parts) < 4:
            continue
        full_hash = parts[0]

        # Quick check: does the diff actually have +/- lines with unsafe as a keyword?
        diff_stdout, _, _ = run(
            ["git", "show", full_hash, "--pretty=format:", "--stat", "--", "*.rs"],
            cwd=repo
        )
        if diff_stdout:
            valid_hashes.append(full_hash)

    if not valid_hashes:
        print("No relevant unsafe changes found in recent history.")
        sys.exit(0)

    # Build the full diff output: headers + diffs for each commit
    # We use git show with diff format that delta can render
    diff_parts = []
    for full_hash in valid_hashes:
        # Get commit info
        info_stdout, _, _ = run(
            ["git", "log", "-1", "--pretty=format:%h %ai %s", full_hash],
            cwd=repo
        )

        # Get the actual diff, filtering to only .rs files
        diff_stdout, _, _ = run(
            ["git", "show", full_hash, "--pretty=format:", "--", "*.rs"],
            cwd=repo
        )

        if not diff_stdout:
            continue

        # Filter to only hunks that touch 'unsafe'
        filtered = filter_unsafe_hunks(diff_stdout)
        if not filtered:
            continue

        # Count additions/removals
        added = sum(1 for l in filtered.split("\n") if l.startswith("+") and "unsafe" in l and not l.startswith("+++"))
        removed = sum(1 for l in filtered.split("\n") if l.startswith("-") and "unsafe" in l and not l.startswith("---"))

        action = ""
        if added > 0 and removed > 0:
            action = f"MODIFIED (added {added}, removed {removed})"
        elif added > 0:
            action = f"🔴 ADDED {added} unsafe occurrence(s)"
        elif removed > 0:
            action = f"🟢 REMOVED {removed} unsafe occurrence(s)"

        # Prepend a header as a comment-style block, then the real diff
        header = f"# Commit: {info_stdout}\n# Action: {action}\n"
        diff_parts.append(header + filtered)

    if not diff_parts:
        print("No relevant unsafe changes found in recent history.")
        sys.exit(0)

    full_output = "\n".join(diff_parts)

    if args.no_pager or not sys.stdout.isatty():
        print(full_output)
    else:
        pager_cmd = get_pager(repo)
        try:
            proc = subprocess.Popen(
                pager_cmd,
                shell=True,
                stdin=subprocess.PIPE,
                encoding="utf-8",
            )
            proc.communicate(input=full_output)
        except (BrokenPipeError, KeyboardInterrupt):
            pass


def filter_unsafe_hunks(diff_text):
    """Filter a unified diff to only include hunks that have +/- lines containing 'unsafe'."""
    lines = diff_text.split("\n")
    result = []
    current_file_header = []  # diff --git, ---, +++ lines
    in_hunk = False
    hunk_lines = []
    hunk_has_unsafe = False
    file_header_emitted = False

    for line in lines:
        if line.startswith("diff --git"):
            # Flush previous hunk
            if hunk_has_unsafe and hunk_lines:
                if not file_header_emitted:
                    result.extend(current_file_header)
                    file_header_emitted = True
                result.extend(hunk_lines)
            # Start new file
            current_file_header = [line]
            file_header_emitted = False
            hunk_lines = []
            hunk_has_unsafe = False
            in_hunk = False
        elif line.startswith("---") or line.startswith("+++") or line.startswith("index ") or line.startswith("old mode") or line.startswith("new mode") or line.startswith("new file") or line.startswith("deleted file"):
            if not in_hunk:
                current_file_header.append(line)
        elif line.startswith("@@"):
            # Flush previous hunk
            if hunk_has_unsafe and hunk_lines:
                if not file_header_emitted:
                    result.extend(current_file_header)
                    file_header_emitted = True
                result.extend(hunk_lines)
            hunk_lines = [line]
            hunk_has_unsafe = False
            in_hunk = True
        elif in_hunk:
            hunk_lines.append(line)
            if (line.startswith("+") or line.startswith("-")) and "unsafe" in line:
                hunk_has_unsafe = True

    # Flush last hunk
    if hunk_has_unsafe and hunk_lines:
        if not file_header_emitted:
            result.extend(current_file_header)
        result.extend(hunk_lines)

    return "\n".join(result)


if __name__ == "__main__":
    main()
