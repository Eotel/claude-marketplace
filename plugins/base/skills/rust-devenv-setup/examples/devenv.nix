# devenv.nix - Base Rust development environment
{ pkgs, ... }:

{
  # Extra packages (customize as needed)
  packages = [
  ];

  # Rust configuration
  languages.rust = {
    enable = true;
    channel = "stable";
    components = [ "rustc" "cargo" "clippy" "rustfmt" "rust-analyzer" ];
  };

  # Git hooks
  git-hooks.hooks = {
    clippy.enable = true;
    rustfmt.enable = true;
    nixfmt-rfc-style.enable = true;
  };

  # Shell initialization
  enterShell = ''
    echo ""
    echo "Rust Development Environment"
    echo "============================="
    echo "rustc:  $(rustc --version)"
    echo "cargo:  $(cargo --version)"
    echo ""
    echo "Commands:"
    echo "  cargo check      - Type check"
    echo "  cargo clippy      - Lint"
    echo "  cargo fmt         - Format"
    echo "  cargo test        - Run tests"
    echo "  cargo build       - Build"
    echo ""
  '';
}
