# Nix configuration

We use [nix](https://nixos.org/) to install a bunch of devtools.

Read more:

* The [Nix Manual](https://nixos.org/nix/manual/) is dry but thorough.
* [Nix Pills](https://nixos.org/nixos/nix-pills/index.html) is the best step by
  step intro to the Nix language.
* [Nix Cookbook](https://nix-cookbook.readthedocs.io/) shows some ways to use
  Nix in practice.
* The [Nixpkgs Manual](https://nixos.org/nixpkgs/manual/) is necessary to
  understand at least some of the (massive) nixpkgs ecosystem.

## Config overview

* All packages we care about are bundled into a mega-package called
  `ckrieger-devtools`, making it easy to install everything in one go.
* [nixpkgs-unstable](https://nixos.org/nixos/packages.html?channel=nixpkgs-unstable)
  is the nixpkgs channel used.
* To make the build reproducible, [niv](https://github.com/nmattia/niv) is used
  to pin the nixpkgs channel (and any other inputs) to specific versions.

## Using

Install the packages by passing this directory (i.e. `default.nix`) as the expression containing derivations to build, and select just the ckrieger-devtools attribute:

``` shell
nix-env -f "$HOME/dotmore/nix" -iA ckrieger-devtools
```

To update to latest versions of all nix packages from unstable branch:

``` shell
niv -s "$HOME/dotmore/nix/sources.json" update nixpkgs -b nixpkgs-unstable
# (then install packages again)
```

To search for available packages:

``` shell
nix-env -f "$HOME/dotmore/nix" -qasP python

# or

nix search -f "$HOME/dotmore/nix" python
# may need to occasionally update the cache too:
nix search -u
```

