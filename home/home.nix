{ pkgs, config, lib, secrets, ... }:

let
  homeDirectory = config.home.homeDirectory;

  symlinks = import ./linkfactory.nix {
    inherit config lib homeDirectory;
    dotfilesDir = "${homeDirectory}/my-nix/dotfiles";
  };

  linkPairs = [
    { source = "fish/conf.d/main.fish";      target = ".config/fish/conf.d/main.fish"; }
    { source = "fish/conf.d/functions.fish"; target = ".config/fish/conf.d/functions.fish"; }

    { source = "emacs/init.el";              target = ".config/emacs/init.el"; }
    { source = "emacs/themes";               target = ".config/emacs/themes"; }
    
    { source = "ghostty";                    target = ".config/ghostty"; }
  ];

  symlinksDAG = symlinks linkPairs;
in
{
  imports = [
    ./git.nix
  ];

  # ── Ghostty terminal ──────────────────────────────────────────────────────
  programs.ghostty.enable = true;

  # ── Fish ──────────────────────────────────────────────────────────────────
  programs.fish = {
    enable = true;
    plugins = [
      { name = "tide";     src = pkgs.fishPlugins.tide.src; }
      { name = "fzf-fish"; src = pkgs.fishPlugins.fzf-fish.src; }
      { name = "autopair"; src = pkgs.fishPlugins.autopair.src; }
      { name = "done";     src = pkgs.fishPlugins.done.src; }
    ];
    interactiveShellInit = ''
      set -g fish_greeting ""
    '';
  };

  home = {
    username      = secrets.username;
    homeDirectory = "/home/${secrets.username}";
    stateVersion  = "25.11";

    packages = with pkgs; [
      # Editors
      emacs-pgtk

      # CLI tools
      bat eza fzf ripgrep fd btop duf gdu tlrc

      # Dev tools
      gh lazygit delta jq nil nixfmt

      # Utilities
      fastfetch tokei hyperfine nvd unzip
    ];

    sessionPath = [ "$HOME/.local/bin" ];
  };

  programs.home-manager.enable = true;
}
