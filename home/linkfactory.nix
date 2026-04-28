{ config, lib, homeDirectory, dotfilesDir ? "${homeDirectory}/my-nix/dotfiles", ... }:

let
  mkLink = { source, target }: let
    # Generate a unique name for this symlink
    name = builtins.replaceStrings ["/" "." " "] ["_" "_" "_"] target;
    fullSource = "${dotfilesDir}/${source}";
    fullTarget = "${homeDirectory}/${target}";
  in {
    "symlink_${name}" = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p "$(dirname "${fullTarget}")"
      ln -sfn "${fullSource}" "${fullTarget}"
    '';
  };
in
  pairs: lib.mkMerge (map mkLink pairs)
