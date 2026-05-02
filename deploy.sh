#!/usr/bin/env bash
set -euo pipefail

# Colours
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

DEST="$HOME/nixos-config"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Nix config → ~/nixos-config ──────────────────────────────────────────────────

TARGETS=(
    flake.nix
    flake.lock
    home/home.nix
    home/git.nix
    home/linkfactory.nix
    hosts/hosts.nix
    hosts/amd.nix
    hosts/nvidia.nix
    nixsec/hardware-configuration.nix
    nixsec/secrets.nix
    devshells/go.nix
    devshells/rust.nix
)

echo "🚀 Deploying NixOS configuration..."
echo "📁 Source: $SRC"
echo "📁 Destination: $DEST"
echo ""

for target in "${TARGETS[@]}"; do
    src_file="$SRC/$target"
    dst_file="$DEST/$target"

    # Skip if source doesn't exist
    if [[ ! -f "$src_file" ]]; then
        echo -e "  ⚠️  ${YELLOW}skip${NC}   $target (not found)"
        continue
    fi

    # If it's a nixsec file or flake.lock and it already exists at the destination, skip it
    if ([[ "$target" == nixsec/* ]] || [[ "$target" == flake.lock ]]) && [[ -f "$dst_file" ]]; then
        echo -e "  ⏭️  ${YELLOW}skip${NC}   $target (already exists)"
        continue
    fi

    # Create destination directory if needed
    dst_dir="$(dirname "$dst_file")"
    if [[ ! -d "$dst_dir" ]]; then
        mkdir -p "$dst_dir"
        echo -e "  📁 ${GREEN}created${NC} $dst_dir"
    fi

    # Only copy if different
    if diff -q "$src_file" "$dst_file" &>/dev/null; then
        echo -e "  ✓  ${GREEN}ok${NC}      $target"
    else
        cp "$src_file" "$dst_file"
        echo -e "  📋 ${GREEN}copied${NC}   $target"
    fi
done

echo ""
echo "✅ Deployment complete!"
echo "💡 Run 'nrs' to rebuild system (includes Home Manager activation)"
