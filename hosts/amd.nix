{ config, pkgs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # ── AMD GPU ──────────────────────────────────────────────────────────────────
  hardware.graphics = {
    enable      = true;
    enable32Bit = true;
    # RADV (Mesa) is the default AMD Vulkan driver — no extraPackages needed.
    # Add rocmPackages.clr here if you need OpenCL/ROCm for GPU compute.
  };

  # Unlock all power-play features (fan curves, overclocking headroom, etc.)
  boot.kernelParams = [ "amdgpu.ppfeaturemask=0xffffffff" ];

  # ── CPU microcode ─────────────────────────────────────────────────────────────
  hardware.cpu.amd.updateMicrocode = true;
}
