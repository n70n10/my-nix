#!/usr/bin/env bash
set -euo pipefail

# Colours
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

DEST="/etc/nixos"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Nix config → /etc/nixos ──────────────────────────────────────────────────

TARGETS=(
    flake.nix
    home.nix
    git/git.nix
    hosts/common.nix
    hosts/amd.nix
    hosts/nvidia.nix
    devshells/go.nix
    devshells/rust.nix
)

echo "Deploying NixOS config: $SRC → $DEST"
echo

for target in "${TARGETS[@]}"; do
    src_file="$SRC/$target"
    dst_file="$DEST/$target"

    # Skip if source doesn't exist
    if [[ ! -f "$src_file" ]]; then
        echo -e "  ${YELLOW}skip${NC}   $target (not found)"
        continue
    fi

    # Create destination directory if needed
    dst_dir="$(dirname "$dst_file")"
    if [[ ! -d "$dst_dir" ]]; then
        sudo mkdir -p "$dst_dir"
    fi

    # Only copy if different
    if sudo diff -q "$src_file" "$dst_file" &>/dev/null; then
        echo -e "  ok     $target"
    else
        sudo cp "$src_file" "$dst_file"
        echo -e "  ${GREEN}copied${NC} $target"
    fi
done

# ── dotfiles → /etc/nixos ────────────────────────────────────────────────────
SRC=$SRC/dotfiles

echo
echo "Deploying dotfiles: $SRC → $DEST"
echo

# Skip if source doesn't exist
if [[ ! -d "$SRC" ]]; then
  echo -e "  ${YELLOW}skip${NC}   $SRC (not found)"
    exit 1
fi

# Create destination directory if needed
if [[ ! -d "$DEST" ]]; then
    sudo mkdir -p "$DEST"
fi

sudo rsync -av --delete \
  --exclude='.git/' \
  --exclude='.cache/' \
  --exclude='*.swp' \
  "$SRC" "$DEST"

echo
echo "Done. Run 'nrs' to rebuild (includes Home Manager activation)."
