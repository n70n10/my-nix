{ config, pkgs, lib, ... }:

{
  # ── NVIDIA GPU ───────────────────────────────────────────────────────────────
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Use open kernel module for Turing+ GPUs (RTX 2000 series and newer)
    open = true;
    # Beta should work better with latest kernel?
    package = config.boot.kernelPackages.nvidiaPackages.beta;

    modesetting.enable = true;
    nvidiaSettings = true;
    powerManagement.enable = true;  # Enable on laptops

    # Optional: Force prime sync for hybrid graphics (laptops with Intel/AMD iGPU)
    # prime = {
    #   sync.enable = true;
    #   offload.enable = true;
    #   intelBusId = "PCI:0:2:0";
    #   nvidiaBusId = "PCI:1:0:0";
    # };
  };

  # Kernel modules for NVIDIA
  boot.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [ nvidia-vaapi-driver ];
  };

  # ── Wayland / KDE env vars ────────────────────────────────────────────────────
  environment.variables = {
    GBM_BACKEND               = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    LIBVA_DRIVER_NAME         = "nvidia";
  };

  # ── CPU microcode ─────────────────────────────────────────────────────────────
  # Switch to hardware.cpu.amd.updateMicrocode if your NVIDIA box has an AMD CPU
  hardware.cpu.intel.updateMicrocode = true;
}
