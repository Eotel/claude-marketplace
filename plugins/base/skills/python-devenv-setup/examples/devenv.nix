# devenv.nix - Base Python development environment
{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  # Python configuration
  languages.python = {
    enable = true;
    version = "3.12";
    uv.enable = true;
  };

  # Development packages
  packages = [
    pkgs.ruff
    pkgs.nixfmt-rfc-style
    pkgs.treefmt
  ];

  # Git hooks
  git-hooks.hooks = {
    ruff.enable = true;
    ruff-format.enable = true;
    nixfmt-rfc-style.enable = true;
  };

  # Shell initialization
  enterShell = ''
    echo ""
    echo "Python Development Environment"
    echo "=============================="
    echo "Python: $(python --version)"
    echo "uv: $(uv --version)"
    echo ""
    echo "Commands:"
    echo "  uv sync          - Install dependencies"
    echo "  uv add <pkg>     - Add dependency"
    echo "  ruff check .     - Run linter"
    echo "  ruff format .    - Format code"
    echo "  uv run ty check  - Type check"
    echo "  treefmt          - Format all files"
    echo ""
  '';
}
