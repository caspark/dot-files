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
      pythonFull
      subversion
      ripgrep
      ruby
      rustup
      tmux
      youtube-dl
    ];
  };
}
