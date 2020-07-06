# Dotfiles

> "No one can conceive the variety of feelings which bore me onwards, like a
> hurricane, in the first enthusiasm of success. Life and death appeared to me
> ideal bounds, which I should first break through, and pour a torrent of light
> into our dark world." - Victor Frankenstein

This is the latest iteration of my personal dot-files, transplanted from my
previous (private) repository.

## Installation

Clone directly into your home directory:

``` shell
cd ~
git init
git remote add origin git@github.com:caspark/dot-files.git
git fetch
git checkout -f master
```

## Design

Read https://drewdevault.com/2019/12/30/dotfiles.html to understand roughly how
this works.

When logic does not belong in an existing dot-file (e.g. arbitrary scripts), it
is added in `dotmore/`. This directory is completely tracked (i.e. un-ignored),
which helps guard against forgetting to track a file in it. That reduces
breakages which are only discovered when on a new machine.

Sometimes I work on Windows, inside Windows Subsystem for Linux, and so I
sometimes have configuration for Windows apps that I want to manage. WSL2 does
not allow symlinks from within WSL to Windows (sensibly, given this mechanism is
based on a 9P server in Windows at time of writing), so as a workaround each
application whose configuration is managed has a directory in `dotmore/windows`
and inside each directory is a script `sync.sh` which applies the configuration.

## Usage

Quick reference:

* To track a new file, just `git add -f some-file`.
* To track a whole directory, unignore it from the `.gitignore`.
* To sync all Windows configurations, run `windows-settings-sync.sh`

