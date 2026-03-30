#!/usr/bin/env bash
set -euo pipefail

# rust-devenv-setup: Generate base Rust development environment files from templates
#
# Required environment variables:
#   PROJECT_NAME      - Project name in kebab-case (e.g. "volcap")
#
# Optional environment variables:
#   RUST_CHANNEL      - Rust channel: stable, nightly, beta (default: "stable")
#   EXTRA_PACKAGES    - Space-separated extra nix packages (e.g. "rust-cbindgen cargo-nextest")
#   TARGET_DIR        - Output directory (default: current directory)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="${SCRIPT_DIR}/examples"

# --- Validate required variables ---
if [[ -z "${PROJECT_NAME:-}" ]]; then
  echo "Error: PROJECT_NAME is required" >&2
  exit 1
fi

# --- Derive variables ---
RUST_CHANNEL="${RUST_CHANNEL:-stable}"
EXTRA_PACKAGES="${EXTRA_PACKAGES:-}"
TARGET_DIR="${TARGET_DIR:-.}"

echo "Setting up Rust project: ${PROJECT_NAME}"
echo "  Rust channel:    ${RUST_CHANNEL}"
echo "  Extra packages:  ${EXTRA_PACKAGES:-none}"
echo "  Target dir:      ${TARGET_DIR}"
echo ""

# --- Copy templates with variable substitution ---

# .envrc — direct copy
cp "${TEMPLATE_DIR}/envrc" "${TARGET_DIR}/.envrc"

# devenv.yaml — direct copy (rust-overlay added via devenv inputs add)
cp "${TEMPLATE_DIR}/devenv.yaml" "${TARGET_DIR}/devenv.yaml"

# devenv.nix — substitute channel and inject extra packages
PACKAGES_NIX=""
if [[ -n "${EXTRA_PACKAGES}" ]]; then
  for pkg in ${EXTRA_PACKAGES}; do
    PACKAGES_NIX="${PACKAGES_NIX}    pkgs.${pkg}\n"
  done
fi

sed \
  -e "s/channel = \"stable\"/channel = \"${RUST_CHANNEL}\"/" \
  -e "s|  packages = \[|  packages = [\n${PACKAGES_NIX}|" \
  "${TEMPLATE_DIR}/devenv.nix" > "${TARGET_DIR}/devenv.nix"

# Clean up empty lines from packages injection if no extras
if [[ -z "${EXTRA_PACKAGES}" ]]; then
  cp "${TEMPLATE_DIR}/devenv.nix" "${TARGET_DIR}/devenv.nix"
  sed -i '' "s/channel = \"stable\"/channel = \"${RUST_CHANNEL}\"/" "${TARGET_DIR}/devenv.nix"
fi

echo "Generated configuration files:"
echo "  devenv.yaml, devenv.nix, .envrc"

# --- Add rust-overlay input ---
echo ""
echo "Adding rust-overlay input..."
(cd "${TARGET_DIR}" && devenv inputs add rust-overlay github:oxalica/rust-overlay --follows nixpkgs)

echo ""
echo "Setup complete. Next steps:"
echo "  direnv allow      # Activate the environment"
echo "  rustc --version   # Verify Rust is available"
