#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# ///

import argparse
import os
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class Worktree:
    path: Path
    branch_ref: str | None
    detached: str | None

    @property
    def branch_name(self) -> str | None:
        if self.branch_ref is None:
            return None
        return self.branch_ref.removeprefix("refs/heads/")

    @property
    def display_name(self) -> str:
        return self.branch_name or f"detached:{self.detached[:12] if self.detached else self.path.name}"


def git(args: list[str], *, cwd: Path | None = None, check: bool = True, capture: bool = True) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["git", *args],
        cwd=cwd,
        check=check,
        text=True,
        stdout=subprocess.PIPE if capture else None,
        stderr=subprocess.PIPE if capture else None,
    )


def git_stdout(args: list[str], *, cwd: Path | None = None) -> str:
    return git(args, cwd=cwd).stdout.strip()


def require_git_repo() -> Path:
    try:
        root = git_stdout(["rev-parse", "--show-toplevel"])
    except subprocess.CalledProcessError as e:
        print(e.stderr, end="", file=sys.stderr)
        raise SystemExit("gintegrate.py must be run from within a git repo") from e
    return Path(root)


def current_branch(repo: Path) -> str:
    branch = git_stdout(["branch", "--show-current"], cwd=repo)
    if not branch:
        raise SystemExit("gintegrate.py must be run from a checked-out branch, not detached HEAD")
    return branch


def parse_worktrees(text: str) -> list[Worktree]:
    worktrees: list[Worktree] = []
    path: Path | None = None
    branch_ref: str | None = None
    detached: str | None = None

    def flush() -> None:
        nonlocal path, branch_ref, detached
        if path is not None:
            worktrees.append(Worktree(path=path, branch_ref=branch_ref, detached=detached))
        path = None
        branch_ref = None
        detached = None

    for line in text.splitlines():
        if not line:
            flush()
            continue
        key, _, value = line.partition(" ")
        if key == "worktree":
            flush()
            path = Path(value)
        elif key == "branch":
            branch_ref = value
        elif key == "detached":
            detached = value
    flush()
    return worktrees


def list_worktrees(repo: Path) -> list[Worktree]:
    return parse_worktrees(git_stdout(["worktree", "list", "--porcelain"], cwd=repo))


def has_tracked_or_staged_changes(path: Path) -> bool:
    # Do not use --ignore-untracked, because staged untracked files should still skip.
    status = git_stdout(["status", "--porcelain=v1", "--untracked-files=no"], cwd=path)
    return bool(status)


def run_or_abort(args: list[str], *, cwd: Path) -> None:
    result = git(args, cwd=cwd, check=False)
    if result.returncode != 0:
        if result.stdout:
            print(result.stdout, end="")
        if result.stderr:
            print(result.stderr, end="", file=sys.stderr)
        raise SystemExit(result.returncode)


def merge_ff_only(repo: Path, source_ref: str) -> None:
    run_or_abort(["merge", "--ff-only", source_ref], cwd=repo)


def rebase_worktree(worktree: Worktree, onto_branch: str) -> None:
    run_or_abort(["rebase", onto_branch], cwd=worktree.path)


def ref_branch_name(repo: Path, ref: str) -> str | None:
    try:
        full_ref = git_stdout(["rev-parse", "--symbolic-full-name", ref], cwd=repo)
    except subprocess.CalledProcessError:
        return ref
    if full_ref.startswith("refs/heads/"):
        return full_ref.removeprefix("refs/heads/")
    return None


def main() -> int:
    parser = argparse.ArgumentParser(description="Fast-forward merge a branch, then rebase sibling worktrees onto the current branch.")
    parser.add_argument("source_ref", help="branch/ref to merge into the current branch")
    args = parser.parse_args()

    repo = require_git_repo()
    target_branch = current_branch(repo)
    source_branch = ref_branch_name(repo, args.source_ref)
    current_path = Path(git_stdout(["rev-parse", "--show-toplevel"], cwd=repo)).resolve()

    merge_ff_only(repo, args.source_ref)
    print(f"{target_branch}: merged in {args.source_ref}")

    for worktree in list_worktrees(repo):
        worktree_path = worktree.path.resolve()
        if worktree_path == current_path:
            continue
        if source_branch is not None and worktree.branch_name == source_branch:
            continue
        if has_tracked_or_staged_changes(worktree.path):
            print(f"{worktree.display_name}: skipped - tracked or staged changes")
            continue

        rebase_worktree(worktree, target_branch)
        print(f"{worktree.display_name}: rebased to {target_branch}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
