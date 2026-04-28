{ config, pkgs, lib, secrets, inputs, ... }:

{
  # ── zswap ─────────────────────────────────────────────────────────────────
  boot.zswap = {
    enable         = true;
    compressor     = "zstd";
    maxPoolPercent = 20;
  };
  swapDevices = [ {
    device = "/swapfile";
    size   = 16384; # 16GB (in MB)
  } ];

  # Faster boot by reducing initrd size
  boot.initrd = {
    systemd.enable = true;
    supportedFilesystems = [ "btrfs" "ext4" "vfat" ];
  };
  boot.tmp.cleanOnBoot = true;

  # ── Plymouth boot splash ──────────────────────────────────────────────────
  boot.plymouth = {
    enable = true;
    theme  = "bgrt";
  };

  # Silent boot — suppress kernel/systemd noise during splash
  boot.consoleLogLevel = 3;
  boot.initrd.verbose  = false;
  boot.kernelParams = [
    "quiet"
    "splash"
    "boot.shell_on_fail"
    "udev.log_priority=3"
    "rd.systemd.show_status=auto"
  ];

  # ── Bootloader ───────────────────────────────────────────────────────────────
  boot.loader = {
    systemd-boot.enable      = true;
    systemd-boot.consoleMode = "max";
    efi.canTouchEfiVariables = true;
  };

  # ── Networking ───────────────────────────────────────────────────────────────
  networking = {
    hostName              = secrets.hostname;
    networkmanager.enable = true;
  };

  # ── Locale & time ────────────────────────────────────────────────────────────
  time.timeZone = secrets.timezone;

  i18n = {
    defaultLocale       = secrets.locale;
    extraLocaleSettings = secrets.extraLocale or {};
  };

  # ── Keyboard ─────────────────────────────────────────────────────────────────
  # console keymap (TTY)
  console.keyMap = secrets.keyboardLayout;

  # X11/Wayland keymap — picked up by libxkbcommon, works with Plasma on Wayland
  services.xserver.xkb = {
    layout  = secrets.keyboardLayout;
    variant = secrets.keyboardVariant;
  };

  # ── User ─────────────────────────────────────────────────────────────────────
  users.users.${secrets.username} = {
    isNormalUser = true;
    description  = secrets.fullName;
    extraGroups  = [ "wheel" "networkmanager" "audio" "video" "input" "gamemode" ];
    shell        = pkgs.fish;
    openssh.authorizedKeys.keys = [ secrets.sshPublicKey ];
  };

  # ── Shell ────────────────────────────────────────────────────────────────────
  programs.fish.enable = true;

  # ── SSH ──────────────────────────────────────────────────────────────────────
  services.openssh = {
    enable   = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin        = "no";
    };
  };

  programs.ssh.startAgent = true;

  # ── Desktop: KDE Plasma 6 ────────────────────────────────────────────────────
  services.desktopManager.plasma6.enable = true;

  # Plasma Login Manager
  services.displayManager.sddm.enable = true;
  services.displayManager.plasma-login-manager.enable = true;

  # Optional: auto-login (uncomment if desired)
  # services.displayManager.autoLogin = {
  #   enable = true;
  #   user = secrets.username;
  # };

  # ── Sound: PipeWire ──────────────────────────────────────────────────────────
  services.pulseaudio.enable = false;
  security.rtkit.enable      = true;
  services.pipewire = {
    enable            = true;
    alsa.enable       = true;
    alsa.support32Bit = true;
    pulse.enable      = true;
    jack.enable       = true;
  };

  # ── Printing (AirPrint support) ──────────────────────────────────────────────
  # AirPrint works with cups + avahi. No driver needed for most modern printers.
  services.printing = {
    enable = true;
    # Avahi is required for AirPrint discovery
    browsing = true;  # Enable printer sharing/browsing
  };

  # Avahi for Zeroconf/Bonjour/AirPrint discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;  # For .local hostname resolution
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  # ── Bluetooth ────────────────────────────────────────────────────────────────
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };
  services.blueman.enable = true;

  # ── Flatpak ──────────────────────────────────────────────────────────────────
  services.flatpak.enable = true;
  # Add Flathub after install: flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

  # ── Applications ──────────────────────────────────────────────────────────────
  programs.firefox.enable = true;

  programs.gamescope = {
    enable = true;
    capSysNice = true;  # Allows Gamescope to set real-time priority for better performance
  };

  programs.steam = {
    enable                         = true;
    remotePlay.openFirewall        = true;
    dedicatedServer.openFirewall   = true;
    extraCompatPackages            = [ pkgs.proton-ge-bin ];
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;

  programs.nh = {
    enable = true;
    flake = "/etc/nixos";

    clean = {
      enable = true;
      extraArgs = "--keep-since 7d --keep 3";
    };
  };

  # ── Nix ──────────────────────────────────────────────────────────────────────
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store   = true;
      trusted-users         = [ "root" secrets.username ];
      max-jobs              = "auto";
      cores                 = 0;
      log-lines             = 50;
    };
    # gc is disabled because nh.clean handles it
  };

  nixpkgs.config.allowUnfree = true;

  # ── System packages ──────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    # Build tools needed system-wide
    gcc gnumake pkg-config

    # Hooks into PAM/systemd
    direnv nix-direnv

    # KDE extras
    kdePackages.kcalc
    kdePackages.ark
    kdePackages.partitionmanager
    kdePackages.filelight        # disk usage visualiser
    wl-clipboard

    # Gaming
    mangohud
  ];

  # direnv / nix-direnv for devshells
  programs.direnv = {
    enable            = true;
    nix-direnv.enable = true;
  };

  # ── Fonts ────────────────────────────────────────────────────────────────────
  fonts.packages = with pkgs; [
    adwaita-fonts
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    noto-fonts
    noto-fonts-color-emoji
  ];

  # ── Essential desktop services ───────────────────────────────────────────────
  services = {
    udisks2.enable = true;   # Removable media management for KDE
    upower.enable = true;    # Power management
    fstrim.enable = true;    # SSD TRIM support
  };

  # ── Hardware firmware ────────────────────────────────────────────────────────
  hardware.enableRedistributableFirmware = true;

  # ── Security hardening ───────────────────────────────────────────────────────
  security = {
    polkit.enable = true;
    protectKernelImage = true;
    allowSimultaneousMultithreading = true;

    sudo = {
      enable = true;
      # wheelNeedsPassword = false;  # Passwordless sudo for wheel (optional)
    };
  };

  # ── Virtualization (optional) ────────────────────────────────────────────────
  # Uncomment if you need containers/VMs
  # virtualisation = {
  #   podman = {
  #     enable = true;
  #     dockerCompat = true;
  #   };
  #   libvirtd.enable = true;
  # };

  system.stateVersion = "25.11";
}
