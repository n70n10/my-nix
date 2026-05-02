{ config, lib, homeDirectory, dotfilesDir, ... }:

let
  mkLinkCmd = { source, target }: let
    fullSource = "${dotfilesDir}/${source}";
    fullTarget = "${homeDirectory}/${target}";
  in ''
    mkdir -p "$(dirname "${fullTarget}")"
    ln -sfn "${fullSource}" "${fullTarget}"
  '';
in
  pairs: {
    activation.symlinkDotfiles = lib.hm.dag.entryAfter ["writeBoundary"] (
      builtins.concatStringsSep "\n" (map mkLinkCmd pairs)
    );

    file.".config/.hm-refresh".text =
      let sorted = builtins.sort (a: b: a.source < b.source) pairs;
      in builtins.concatStringsSep "\n" (map (p: "${p.source} -> ${p.target}") sorted);
  }
