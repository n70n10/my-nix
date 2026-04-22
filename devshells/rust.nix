{ pkgs }:

pkgs.mkShell {
  name = "rust-dev";

  packages = with pkgs; [
    rustup           # manages toolchains (stable, nightly, targets)
    rust-analyzer    # LSP
    cargo-watch      # live rebuild on save
    cargo-expand     # macro expansion
    cargo-audit      # security advisory check
    cargo-outdated   # dependency freshness
    cargo-nextest    # faster test runner
    cargo-flamegraph # perf flamegraphs
    mold             # fast linker — significant incremental build speedup

    # Native libs commonly needed by Rust crates
    pkg-config
    openssl
    libiconv
  ];

  env = {
    # Use mold as linker
    RUSTFLAGS       = "-C link-arg=-fuse-ld=${pkgs.mold}/bin/mold";
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
  };

  shellHook = ''
    if ! rustup toolchain list | grep -q stable; then
      rustup toolchain install stable
    fi
    rustup default stable
    echo "Rust $(rustc --version) devshell ready"
  '';
}
