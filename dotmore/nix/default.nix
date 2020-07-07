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
      cmake
      emacsUnstable
      entr
      fish
      fzf
      htop
      jq
      lua
      neovim
      niv
      nixfmt
      pythonFull
      ripgrep
      ruby
      rustup
      tmux
      youtube-dl
    ];
  };
}
