let
  sources = import ./sources.nix;
  pkgs = import sources.nixpkgs {
    overlays = [
      (import sources.emacs-overlay)
    ];
  };
  pkgs-unstable = import sources.nixpkgs-unstable {};
in pkgs // {
  ckrieger-devtools = pkgs.buildEnv {
    name = "ckrieger-devtools";
    paths = with pkgs; [
      act
      antigen
      aspell
      aspellDicts.en
      aspellDicts.en-computers
      aspellDicts.en-science
      cloc
      cmake
      colordiff
      cvs
      direnv
      dos2unix
      dtrx
      emacsUnstable
      entr
      fd
      firefox
      fish
      git
      gitAndTools.git-extras
      graphviz
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
      pkgs-unstable.bat
      pkgs-unstable.delta
      pkgs-unstable.fzf
      pkgs-unstable.starship
      proselint
      python38Full
      python38Packages.isort
      qpdf
      ripgrep
      rlwrap
      ruby
      rustup
      shellcheck
      sshpass
      subversion
      tig
      tmux
      vmtouch
      wordnet
      xsv
      youtube-dl
      zsh
    ];
  };
}
