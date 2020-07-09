let
  sources = import ./sources.nix;
  pkgs = import sources.nixpkgs {
    overlays = [
      (import sources.emacs-overlay)
    ];
  };
in pkgs // {
  ckrieger-devtools = pkgs.buildEnv {
    name = "ckrieger-devtools";
    paths = with pkgs; [
      cvs
      clang
      cmake
      direnv
      emacsUnstable
      entr
      fd
      fish
      fzf
      git
      htop
      jq
      lua
      neovim
      niv
      nixfmt
      mercurialFull
      python38Full
      wordnet
      libvterm
      shellcheck
      pandoc
      ispell
      python38Packages.isort
      subversion
      ripgrep
      ruby
      rustup
      tmux
      youtube-dl
    ];
  };
}
