---
name: python-devenv-setup
description: Reproducible Nix-based Python development environment setup with devenv, uv, ruff, and ty.
user-invocable: false
---

# Python Development Environment Setup

Set up a complete, reproducible Python development environment using devenv, uv, ruff, and ty.

## Tools Included

| Tool | Purpose |
|------|---------|
| **devenv** | Nix-based declarative development environment |
| **uv** | Fast Python package manager (replaces pip/poetry) |
| **ruff** | Ultra-fast Python linter and formatter |
| **ty** | Extremely fast Python type checker (Astral) |
| **treefmt** | Multi-language formatter orchestration |

## Prerequisites

- Nix package manager installed
- direnv installed and hooked into shell
- devenv CLI installed

## Command Options

| Option | Values | Default | Description |
|--------|--------|---------|-------------|
| `--python` | 3.10, 3.11, 3.12, 3.13 | 3.12 | Python version |
| `--db` | mysql, postgres, sqlite | sqlite | Database support |
| `--framework` | django, fastapi, flask, none | none | Web framework |
| `--strict-types` | flag | false | Enable strict type checking |

## Generated Files Overview

| File | Purpose |
|------|---------|
| `devenv.yaml` | Nix flake inputs + cachix configuration |
| `devenv.nix` | Development environment definition |
| `.envrc` | direnv integration for auto-activation |
| `pyproject.toml` | Project config with hatch, ruff, pytest settings |
| `treefmt.toml` | Multi-language formatter config |
| `.gitignore` | Development artifact exclusions |

## Implementation Steps

### 1. Create devenv.yaml

Define Nix inputs and cachix caches. See `examples/devenv.yaml` for complete template.

### 2. Create devenv.nix

Configure Python version, packages, git hooks, and shell initialization.

Key sections:
- `languages.python` - Python version and uv configuration
- `packages` - Nix tools (ruff, treefmt, nixfmt)
- `git-hooks.hooks` - Automated linting on commit
- `enterShell` - Welcome message with available commands

For database support, add packages and environment variables. See `references/database-variants.md`.

### 3. Create .envrc

```bash
#!/usr/bin/env bash
export DIRENV_WARN_TIMEOUT=20s
eval "$(devenv direnvrc)"
use devenv
```

### 4. Create pyproject.toml

Configure project metadata, dependencies, and tool settings:
- `[project]` - Name, version, Python requirement
- `[build-system]` - Hatchling build backend
- `[dependency-groups]` - Dev dependencies (pytest, ruff, ty)
- `[tool.ruff]` - Linting rules and formatting
- `[tool.pytest]` - Test configuration

For framework-specific settings, see `references/framework-variants.md`.

### 5. Create treefmt.toml

Configure formatters for Python (ruff) and Nix (nixfmt).

### 6. Update .gitignore

Add exclusions for development artifacts, virtual environments, and tool caches.

## Setup Commands

After generating files:

```bash
# Create source directory structure (required for hatchling build)
mkdir -p src/my_project && touch src/my_project/__init__.py
mkdir -p tests && touch tests/__init__.py

# Enter the environment (auto-creates lock file)
direnv allow

# Install Python dependencies (manual step - uv sync is not auto-run)
uv sync

# Verify setup
python --version
ruff --version
uv run ty --version
```

**Note:** `uv.sync.enable` is intentionally disabled in the devenv.nix template to avoid bootstrap failures when `src/my_project/` doesn't exist yet on first setup.

## Verification

```bash
# Check devenv status
devenv info

# Run type check
uv run ty check

# Run linter
ruff check .

# Check formatting
ruff format --check .
treefmt --check
```

## Troubleshooting

### direnv not loading

Ensure direnv is hooked into shell:

```bash
# For bash
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc

# For zsh
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc

# Then allow the directory
direnv allow
```

### ty not finding packages

Ensure virtual environment exists and packages are installed:

```bash
uv sync
```

### Database compilation errors

See `references/database-variants.md` for required environment variables.

## Additional Resources

### Reference Files

- **`references/database-variants.md`** - MySQL and PostgreSQL configuration details
- **`references/framework-variants.md`** - Django and FastAPI specific settings

### Example Files

Complete, working configuration templates in `examples/`:

- `devenv.yaml` - Nix inputs configuration
- `devenv.nix` - Base development environment
- `pyproject.toml` - Project and tool configuration
- `treefmt.toml` - Formatter configuration
- `gitignore` - Git exclusions
