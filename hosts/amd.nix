{ config, pkgs, lib, ... }:

{
  # ── AMD GPU ──────────────────────────────────────────────────────────────────
  hardware.graphics = {
    enable      = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  # VA-API for hardware video acceleration
  environment.variables = {
    LIBVA_DRIVER_NAME = "radeonsi";  # or "amdgpu"
  };

  # Unlock all power-play features (fan curves, overclocking headroom, etc.)
  boot.kernelParams = [ "amdgpu.ppfeaturemask=0xffffffff" ];

  # ── CPU microcode ─────────────────────────────────────────────────────────────
  hardware.cpu.amd.updateMicrocode = true;
}
