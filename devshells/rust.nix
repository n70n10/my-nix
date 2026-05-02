{ pkgs, fenixPkgs }:

let
  toolchain = fenixPkgs.stable.withComponents [
    "rustc"
    "cargo"
    "clippy"
    "rustfmt"
    "rust-src"
  ];
in
pkgs.mkShell {
  name = "rust-dev";

  packages = [
    toolchain
    fenixPkgs.rust-analyzer  # always latest nightly RA, preferred over nixpkgs

    pkgs.cargo-watch
    pkgs.cargo-expand
    pkgs.cargo-audit
    pkgs.cargo-outdated
    pkgs.cargo-nextest
    pkgs.cargo-flamegraph
    pkgs.mold

    pkgs.pkg-config
    pkgs.openssl
  ];

  env = {
    RUSTFLAGS       = "-C link-arg=-fuse-ld=${pkgs.mold}/bin/mold";
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
    RUST_SRC_PATH   = "${toolchain}/lib/rustlib/src/rust/library";
  };

  shellHook = ''
    echo "Rust $(rustc --version) devshell ready"
  '';
}
