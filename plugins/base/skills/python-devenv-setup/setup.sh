#!/usr/bin/env bash
set -euo pipefail

# python-devenv-setup: Generate base development environment files from templates
#
# Required environment variables:
#   PROJECT_NAME    - Project name in kebab-case (e.g. "simple-a2a-agent")
#
# Optional environment variables:
#   PYTHON_VERSION  - Python version (default: "3.12")
#   DEPS            - Production dependencies, space-separated (e.g. "fastapi uvicorn")
#   DEV_DEPS        - Development dependencies, space-separated (e.g. "pytest-asyncio httpx")
#   TARGET_DIR      - Output directory (default: current directory)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="${SCRIPT_DIR}/examples"

# --- Validate required variables ---
if [[ -z "${PROJECT_NAME:-}" ]]; then
  echo "Error: PROJECT_NAME is required" >&2
  exit 1
fi

# --- Derive variables ---
PYTHON_VERSION="${PYTHON_VERSION:-3.12}"
DEPS="${DEPS:-}"
DEV_DEPS="${DEV_DEPS:-}"
TARGET_DIR="${TARGET_DIR:-.}"

# kebab-case → snake_case (e.g. "simple-a2a-agent" → "simple_a2a_agent")
PACKAGE_NAME="${PROJECT_NAME//-/_}"

# "3.12" → "py312"
PYTHON_VERSION_SHORT="py${PYTHON_VERSION//./}"

echo "Setting up Python project: ${PROJECT_NAME}"
echo "  Package name:    ${PACKAGE_NAME}"
echo "  Python version:  ${PYTHON_VERSION} (${PYTHON_VERSION_SHORT})"
echo "  Target dir:      ${TARGET_DIR}"
echo ""

# --- Copy templates with variable substitution ---

# Files that need no substitution (direct copy)
cp "${TEMPLATE_DIR}/devenv.yaml" "${TARGET_DIR}/devenv.yaml"
cp "${TEMPLATE_DIR}/envrc"       "${TARGET_DIR}/.envrc"
cp "${TEMPLATE_DIR}/treefmt.toml" "${TARGET_DIR}/treefmt.toml"
cp "${TEMPLATE_DIR}/gitignore"   "${TARGET_DIR}/.gitignore"

# devenv.nix — substitute Python version
sed "s/version = \"3.12\"/version = \"${PYTHON_VERSION}\"/" \
  "${TEMPLATE_DIR}/devenv.nix" > "${TARGET_DIR}/devenv.nix"

# pyproject.toml — substitute project name, package name, Python version
sed \
  -e "s/name = \"my-project\"/name = \"${PROJECT_NAME}\"/" \
  -e "s/requires-python = \">=3.12\"/requires-python = \">=${PYTHON_VERSION}\"/" \
  -e "s|src/my_project|src/${PACKAGE_NAME}|g" \
  -e "s/target-version = \"py312\"/target-version = \"${PYTHON_VERSION_SHORT}\"/" \
  -e "s/python-version = \"3.12\"/python-version = \"${PYTHON_VERSION}\"/" \
  "${TEMPLATE_DIR}/pyproject.toml" > "${TARGET_DIR}/pyproject.toml"

echo "Generated configuration files:"
echo "  devenv.yaml, devenv.nix, .envrc, pyproject.toml, treefmt.toml, .gitignore"

# --- Create directory structure ---
mkdir -p "${TARGET_DIR}/src/${PACKAGE_NAME}"
touch "${TARGET_DIR}/src/${PACKAGE_NAME}/__init__.py"
mkdir -p "${TARGET_DIR}/tests"
touch "${TARGET_DIR}/tests/__init__.py"

echo "Created directories:"
echo "  src/${PACKAGE_NAME}/ (with __init__.py)"
echo "  tests/ (with __init__.py)"

# --- Install dependencies ---
if [[ -n "${DEPS}" ]]; then
  echo ""
  echo "Adding production dependencies: ${DEPS}"
  # shellcheck disable=SC2086
  (cd "${TARGET_DIR}" && uv add ${DEPS})
fi

if [[ -n "${DEV_DEPS}" ]]; then
  echo ""
  echo "Adding development dependencies: ${DEV_DEPS}"
  # shellcheck disable=SC2086
  (cd "${TARGET_DIR}" && uv add --group dev ${DEV_DEPS})
fi

echo ""
echo "Setup complete. Next steps:"
echo "  direnv allow     # Activate the environment"
echo "  uv sync          # Install Python dependencies"
