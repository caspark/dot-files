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
      clang
      cmake
      cvs
      direnv
      emacsUnstable
      entr
      fd
      fish
      fzf
      git
      htop
      ispell
      jq
      libvterm
      lua
      mercurialFull
      mosh
      neovim
      niv
      nixfmt
      pandoc
      python38Full
      python38Packages.isort
      ripgrep
      ruby
      rustup
      shellcheck
      sshpass
      subversion
      tmux
      wordnet
      xsv
      youtube-dl
    ];
  };
}
