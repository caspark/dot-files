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
      mosh
      niv
      nixfmt
      pandoc
      pkgs-unstable.bat
      pkgs-unstable.broot
      pkgs-unstable.exa
      pkgs-unstable.delta
      pkgs-unstable.fzf
      pkgs-unstable.git-filter-repo
      pkgs-unstable.git-lfs
      pkgs-unstable.just
      pkgs-unstable.neovim
      pkgs-unstable.starship
      pkgs-unstable.skim
      pkgs-unstable.topgrade
      pkgs-unstable.tokei
      pkgs-unstable.tealdeer
      pkgs-unstable.nushell
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
      vmtouch
      wordnet
      xsv
    ];
  };
}
