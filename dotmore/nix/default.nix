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
      aspell
      aspellDicts.en
      aspellDicts.en-computers
      aspellDicts.en-science
      cloc
      cmake
      cvs
      direnv
      dos2unix
      dtrx
      emacsUnstable
      entr
      fd
      firefox
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
      proselint
      python38Full
      python38Packages.isort
      ripgrep
      ruby
      rustup
      shellcheck
      sshpass
      subversion
      tig
      tmux
      wordnet
      xsv
      youtube-dl
    ];
  };
}
