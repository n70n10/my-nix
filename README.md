# NixOS Configuration

Flake-based NixOS config with Fish shell, KDE Plasma 6, and devshells for Go and Rust development.

## First-time setup

```
# 1. Clone
git clone git@github.com:n70n10/mynix.git
cd mynix

# 2. Fill in your personal data (includes git identity)
$EDITOR ./nixsec/secrets.nix

# 3. Generate hardware config (if not present)
nixos-generate-config --show-hardware-config | tee ./nixsec/hardware-configuration.nix > /dev/null

# 4. ***IMPORTANT*** mark nixsec files as unchanged!
git ls-files -z ./nixsec | xargs -0 git update-index --assume-unchanged

# 5. Build, switch, and activate Home Manager (may need #<hostmane> the 1st time)
sudo nixos-rebuild switch --flake /etc/nixos
```

## File structure

```
.
├── flake.nix                          # Entrypoint
├── home.nix                           # Home Manager config (dotfiles, git, fish)
├── git
│   └── git.nix                        # Git config
├── secrets.nix.example                # Template — commit this
├── deploy.sh                          # Syncs repo → /etc/nixos
├── .gitignore
├── hosts/
│   ├── common.nix                     # Shared config (Plasma, gaming, SSH…)
│   ├── amd.nix                        # AMD GPU + microcode
│   └── nvidia.nix                     # NVIDIA GPU + proprietary driver
├── dotfiles/
│   └── fish/
│       ├── config.fish
│       └── conf.d/
│           └── functions.fish
│   └── ...
├── devshells/
│   ├── go.nix                         # Go toolchain + tools
│   └── rust.nix                       # Rust via rustup + tools
└── nixsec/
    ├── hardware-configuration.nix     # cp from /etc/nixos
    └── secrets.nix                    # Full name, email, locale etc.
```

## secrets.nix

Each machine has its own `secrets.nix` — the `hostname` and `gpu` fields tell
the flake which host file to load, so no machine names appear in the repo.
Git identity (`fullName`, `email`) is read from here by Home Manager, so no
separate `gitconfig` file is needed.

```nix
{
  username = "your-username";
  fullName = "Your Full Name";
  email    = "your@email.com";

  # Locale / timezone — find yours with `timedatectl list-timezones`
  timezone  = "Europe/Rome";
  locale    = "en_US.UTF-8";

  # Extra locale overrides — remove keys you don't need, or set to {}
  extraLocale = {};

  # Keyboard — run `localectl list-keymaps` for console maps,
  # `localectl list-x11-keymap-layouts` for X11/Wayland layouts
  keyboardLayout  = "us";
  keyboardVariant = "";

  # Machine identity — keep this out of the repo
  hostname = "my-hostname";   # used for networking.hostName
  gpu      = "amd";           # host file to load: amd or nvidia

  # Nixos config path
  nixosConfigPath = "${HOME}mynix";

  # SSH public key for authorized_keys
  sshPublicKey = "ssh-ed25519 AAAA... your-key-comment";
}
```

## Dotfiles

Dotfiles are managed declaratively by Home Manager via `home.nix` — no manual
symlinking. Git identity is sourced from `secrets.nix`.
`nixos-rebuild switch` activates Home Manager and lays down all symlinks atomically.

## Devshells

```
nix develop .#go      # Go environment
nix develop .#rust    # Rust environment
```

Or use direnv — drop a `.envrc` in your project:

```
use flake /etc/nixos#go
```

## Fish aliases & functions

### Aliases

| Alias | Does |
| --- | --- |
| `..` / `...` / `....` | cd up 1 / 2 / 3 levels |
| `ls` | `eza` with icons, directories first |
| `ll` | `eza -la` with icons and git status |
| `lt` / `lta` | tree view 2 levels, with/without hidden |
| `tree` | `eza` tree, all files, excluding `.git` |
| `cat` | `bat` with syntax highlighting |
| `grep` / `find` | `ripgrep` / `fd` |
| `top` / `df` / `du` | `btop` / `duf` / `gdu` |
| `mi` | `micro` |
| `vi` / `vim` | `nvim` |
| `sv` | `sudo nvim` |
| `g` / `gs` / `ga` / `gaa` | `git` / `status` / `add` / `add -A` |
| `gc` / `gcm` / `gca` | `commit` / `commit -m` / `commit --amend` |
| `gco` / `gcob` | `checkout` / `checkout -b` |
| `gpl` / `gps` / `gpsu` | `pull` / `push` / push and set upstream |
| `gl` / `gd` / `gds` | log graph / `diff` / `diff --staged` |
| `grb` / `gst` / `gstp` | `rebase` / `stash` / `stash pop` |
| `lg` | `lazygit` |
| `nrs` / `nrt` / `nrb` | rebuild switch / test / boot (from repo root) |
| `nup` | `nix flake update` + rebuild switch |
| `ngens` | list system generations |
| `nrollback` | roll back to previous generation |
| `nfu` / `nfc` / `ngc` | flake update / check / garbage-collect |
| `ndev` | `nix develop` |
| `gob` / `got` / `gotr` / `gotv` | `go build` / `test` / `test -race` / `test -v` |
| `gom` / `gor` / `gogen` | `go mod tidy` / `go run .` / `go generate` |
| `cb` / `cr` / `ct` / `cta` | `cargo build` / `run` / `test` / `test --include-ignored` |
| `cc` / `ccl` / `cft` / `cw` | `cargo check` / `clippy` / `fmt` / `watch` |
| `ports` / `myip` / `reload` | listening ports / external IP / restart fish |

### Functions

| Function | Does |
| --- | --- |
| `ndiff` | diff current system vs what the next rebuild would produce |
| `nsh <pkg>` | `nix shell nixpkgs#<pkg>` — ephemeral shell |
| `dev [name]` | `nix develop [.#name]` |
| `mkcd <dir>` | `mkdir -p` + `cd` in one step |
| `fcd` | fuzzy `cd` into any subdirectory using fzf |
| `fe` | fuzzy open a file in `$EDITOR` using fzf |
| `bak <file>` | copy `<file>` to `<file>.bak` |
| `ex <archive>` | extract any archive (tar, zip, 7z, zst, gz…) |
| `every <s> <cmd>` | repeat `<cmd>` every `<s>` seconds |
| `pr` | push current branch + `gh pr create --fill` |
| `paths` | print `$PATH` one entry per line |

## Notes

* **NVIDIA CPU microcode**: `nvidia.nix` assumes Intel.
  Swap to `hardware.cpu.amd.updateMicrocode` if your NVIDIA machine has an AMD CPU.
* **hardware-configuration.nix**: safe to commit if you don't mind disk UUIDs
  being public. Remove from `.gitignore` and `git add` it explicitly.
* **Rust toolchain**: managed by `rustup` inside the devshell for easy target/channel
  switching. If you prefer a fully declarative approach, replace with `rust-overlay`.
* **Flatpak**: add Flathub once after install:
  `flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo`
* **Tide prompt**: run `tide configure` once after install — settings persist
  in `~/.config/fish/fish_variables` and survive rebuilds.
