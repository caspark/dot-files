let
  sources = import ./sources.nix;
  pkgs = import sources.nixpkgs {
    overlays = [
      # adds emacsUnstable and emacsGcc packages
      # (import sources.emacs-overlay)
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
      colordiff
      cvs
      direnv
      dos2unix
      dtrx
      emacs
      entr
      edir
      fd
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
      niv
      nixfmt-classic
      pandoc
      pkgs-unstable.bat
      pkgs-unstable.broot
      pkgs-unstable.delta
      pkgs-unstable.eza
      pkgs-unstable.fzf
      pkgs-unstable.fsearch
      pkgs-unstable.git-filter-repo
      pkgs-unstable.git-lfs
      pkgs-unstable.just
      pkgs-unstable.lnav
      pkgs-unstable.maestral
      # pkgs-unstable.maestral-gui
      pkgs-unstable.multitail
      pkgs-unstable.neovim
      pkgs-unstable.nushell
      pkgs-unstable.skim
      pkgs-unstable.starship
      pkgs-unstable.tealdeer
      pkgs-unstable.tokei
      pkgs-unstable.topgrade
      proselint
      qpdf
      recode
      ripgrep
      rlwrap
      ruby
      shellcheck
      shfmt
      sshpass
      subversion
      tig
      tmux
      trash-cli
      vmtouch
      wordnet
      xsv
      zellij
    ];
  };
}
