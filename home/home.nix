{ pkgs, config, lib, secrets, ... }:

let
  homeDirectory = config.home.homeDirectory;

  symlinks = import ./linkfactory.nix {
    inherit config lib homeDirectory;
    dotfilesDir = "${homeDirectory}/my-nix/dotfiles";
  };

  linkPairs = [
    { source = "fish/conf.d/main.fish";         target = ".config/fish/conf.d/main.fish"; }
    { source = "fish/conf.d/functions.fish";    target = ".config/fish/conf.d/functions.fish"; }

    { source = "micro/settings.json";           target = ".config/micro/settings.json"; }
    { source = "micro/bindings.json";           target = ".config/micro/bindings.json"; }
    { source = "micro/colorschemes/rose-pine.micro"; target = ".config/micro/colorschemes/rose-pine.micro"; }

    { source = "nvim";                          target = ".config/nvim"; }

    { source = "ghostty";                       target = ".config/ghostty"; }
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
      micro neovim

      # CLI tools
      bat eza fzf ripgrep fd btop duf

      # Dev tools
      gh lazygit delta

      # Utilities
      fastfetch tokei hyperfine nvd
    ];

    sessionPath = [ "$HOME/.local/bin" ];
  };

  # ── Home activation (symlinks DAG + cleanup) ──────────────────────────────
  home.activation = symlinksDAG // {
    cleanHomeManager = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      echo "🧹 Cleaning old Home Manager generations..."
      nix profile wipe-history --profile ~/.local/state/nix/profiles/home-manager --older-than 30d 2>/dev/null || true
      nix-collect-garbage --delete-older-than 30d 2>/dev/null || true
    '';
  };

  programs.home-manager.enable = true;
}
