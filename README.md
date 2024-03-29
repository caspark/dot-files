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

## Design and usage

Read https://drewdevault.com/2019/12/30/dotfiles.html to understand roughly how
this works.

* To track a new file, just `git add -f some-file`.
* To track a whole directory, unignore it from the `.gitignore`.

### Extra logic

When logic does not belong in an existing dot-file (e.g. arbitrary scripts), it
is added in `dotmore/`. This directory is completely tracked (i.e. un-ignored),
which helps guard against forgetting to track a file in it. That reduces
breakages which are only discovered when on a new machine.

### Nix

I try to keep most tools I use managed via a `nix` config to make it easy to
bootstrap a new system. See `dotmore/nix/README.md` for info.

* To install nix packages, run `sync-nix.sh``

### Vim

I maintain a moderately tricked-out setup of Neovim too, as it's great for
quickly editing files without waiting for a full IDE to load up.

My config is based around using <kbd>Space</kbd> as my leader key, and much of
the keybinds are inspired by the Vim-mode provided by Spacemacs/Doom: e.g.
`space, f, s` to save a file, `space, q, q` to without saving, `ctrl+c, ctrl+c`
to quit and save etc, and I tend to use standard Emacs edit mode bindings like
`ctrl+a`/`ctrl+e` to go to start/end of line while in Insert mode.

* To bootstrap the plugins, make sure `fzf` is installed, start `nvim`, ignore
  the errors on startup, and hit `space, v, p, i` (mnemonic "Vim Plugin
  Install") to install plugins via
  [vim-plug](https://github.com/junegunn/vim-plug).
* To update xdg-open to do the right thing (i.e.use nvim instead of vim), run
  `xdg-mime default nvim.desktop text/plain` (see config file in
  ~./local/share/applications).

Note that this config specifically only works with Neovim, not (e.g.) Vim 8, which is why the config is at `/.config/nvim/init.vim` rather than `/.vimrc`.

Plugins can be updated with `space v p u` (mnemonic "Vim Plugin Update"), but
note that this sometimes breaks things via my particular config: sometimes this
installs plugins which require newer versions of utils than what I have
configured `nix` to install (specifically: fzf seems to fall prey to this a
lot: newer versions of the fzf plugin get released that rely on fzf versions
that aren't available in my pinned version of the nix repo; this won't be a
problem if you just install fzf separately).

### Emacs

I keep a somewhat-working build of Emacs around, using the Doom Emacs
distribution, because [magit](https://magit.vc/) is just an amazing piece of
software even though Emacs as a whole tends to frustrate me with its slowness.

Emacs is installed via nix, which makes it easy to compile the latest
"unstable" build from source, as recommended by Doom. Doom source code lives at
`/emacs.d/`, managed as a submodule.

* To bootstrap the editor, first install emacs, then run `sync-emacs.sh'

### Windows

Sometimes I work on Windows, inside Windows Subsystem for Linux, and so I
sometimes have configuration for Windows apps that I want to manage. WSL2 does
not allow symlinks from within WSL to Windows (sensibly, given this mechanism is
based on a 9P server in Windows at time of writing), so as a workaround each
application whose configuration is managed has a directory in `dotmore/windows`
and inside each directory is a script `sync.sh` which applies the configuration.

* To sync all Windows configurations, run `windows-settings-sync.sh`

### ASDF and other "version managers"

While I manage a lot of dev tools using nix (see above), I prefer to manage
versions of (most) SDKs and programming language tools using
[asdf](https://github.com/asdf-vm/asdf) - I've found this reduces the amount of
time I spend chasing down obscure issues caused by nix's hacks to e.g. make
LLVM builds 100% reproducible.

ASDF global config is managed via `~/.toolversions` and `~/.asdfrc`. Command
cheat sheet:

* `asdf list` - list installed versions for all plugins
* `asdf list python` - list installed versions for a plugin
* `asdf shell python 3.10.0` - use specific version for this shell session
* `asdf local python 3.10.0` - use specific version for all shells in this pwd
* `asdf list all python` - list all known versions that could be installed
* `asdf install python 3.10.0` - install a specific version

Plugins to support each language need to be installed one by one, and typically
have their own prereqs that need to be installed via e.g. `apt`, so here's a
list of common plugins I use:

* https://github.com/danhper/asdf-python
* https://github.com/asdf-vm/asdf-nodejs
* https://github.com/asdf-vm/asdf-ruby
* https://github.com/asdf-vm/asdf-elixir
    * NB: needs https://github.com/asdf-vm/asdf-erlang
* https://github.com/kennyp/asdf-golang
* https://github.com/twuni/asdf-yarn

Sometimes specific projects have problems with the way that ASDF does things
(or rather, specific codebases assume behavior only present in lang-specific
toolsets), so here are common per-language alternatives:

* https://sdkman.io/ - java, scala, gradle, maven, etc
* https://github.com/nvm-sh/nvm
* https://rvm.io/ and https://github.com/rbenv/rbenv for ruby

#### Yarn and global installs

`yarn config set prefix ~/.yarn` and ~/.yarn/bin is already added to path, so
then [globally installed packages via
Yarn](https://github.com/asdf-vm/asdf-nodejs/issues/42) should work.
