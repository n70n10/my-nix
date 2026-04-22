{ pkgs, config, secrets, ... }:

let
  repoPath = secrets.nixosConfigPath;
  liveLink = path: config.lib.file.mkOutOfStoreSymlink "${repoPath}/${path}";
in
{
  imports = [
    ./home/git.nix
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
      source ${secrets.nixosConfigPath}/dotfiles/fish/config.fish
      source ${secrets.nixosConfigPath}/dotfiles/fish/conf.d/functions.fish
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
      # ── Micro ─────────────────────────────────────────────────────────────────
      ".config/micro/settings.json".source                = liveLink "dotfiles/micro/settings.json";
      ".config/micro/bindings.json".source                = liveLink "dotfiles/micro/bindings.json";
      ".config/micro/colorschemes/rose-pine.micro".source = liveLink "dotfiles/micro/colorschemes/rose-pine.micro";
      # ── Neovim ────────────────────────────────────────────────────────────────
      ".config/nvim".source                               = liveLink "dotfiles/nvim";
      # ── Ghostty ───────────────────────────────────────────────────────────────
      ".config/ghostty".source                            = liveLink "dotfiles/ghostty";
    };

    sessionPath = [ "$HOME/.local/bin" ];
  };

  programs.home-manager.enable = true;
}
