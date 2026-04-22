{ pkgs, config, secrets, ... }:

{
  imports = [
    ./home/git.nix
  ];

  # ── Ghostty terminal ──────────────────────────────────────────────────────
  programs.ghostty.enable = true;

  # ── Fish ──────────────────────────────────────────────────────────────────
  programs.fish = {
    enable = true;  # activates HM's fish module
    plugins = [
      { name = "tide";     src = pkgs.fishPlugins.tide.src; }
      { name = "fzf-fish"; src = pkgs.fishPlugins.fzf-fish.src; }
      { name = "autopair"; src = pkgs.fishPlugins.autopair.src; }
      { name = "done";     src = pkgs.fishPlugins.done.src; }
    ];
    interactiveShellInit = ''
      ${builtins.readFile ./dotfiles/fish/config.fish}
      ${builtins.readFile ./dotfiles/fish/conf.d/functions.fish}
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

    file = {
      # Micro
      ".config/micro/settings.json".source         = ./dotfiles/micro/settings.json;
      ".config/micro/bindings.json".source         = ./dotfiles/micro/bindings.json;

      # Neovim
      ".config/nvim".source                        = ./dotfiles/nvim;

      # Ghostty
      ".config/ghostty".source                     = ./dotfiles/ghostty;
    };

    sessionPath = [ "$HOME/.local/bin" ];
  };

  programs.home-manager.enable = true;
}
