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

## Implementation Workflow

Before running the setup script, gather parameters from the user using `AskUserQuestion`.

### Step 1: Infer defaults

- **PROJECT_NAME**: Infer from the current directory name or git remote (e.g. `basename $(pwd)`)
- **PYTHON_VERSION**: Default to `3.12`
- **DEPS / DEV_DEPS**: Infer from conversation context if the user mentioned specific libraries

### Step 2: Ask the user to confirm

Use `AskUserQuestion` to confirm or adjust parameters. Ask all questions in a single call.

Example:

```
AskUserQuestion({
  questions: [
    {
      question: "What is the project name?",
      header: "Project",
      options: [
        { label: "<inferred-name>", description: "Inferred from current directory" },
        { label: "custom", description: "Enter a different name" }
      ],
      multiSelect: false
    },
    {
      question: "Which Python version?",
      header: "Python",
      options: [
        { label: "3.12 (Recommended)", description: "Latest stable, widest ecosystem support" },
        { label: "3.13", description: "Newest release" },
        { label: "3.11", description: "Previous stable" }
      ],
      multiSelect: false
    },
    {
      question: "Do you need database or web framework support?",
      header: "Extras",
      options: [
        { label: "None", description: "Base setup only" },
        { label: "FastAPI", description: "Async web framework" },
        { label: "Django", description: "Full-stack web framework" },
        { label: "Flask", description: "Lightweight web framework" }
      ],
      multiSelect: false
    }
  ]
})
```

Adapt the options based on context — skip questions where the answer is already clear from the conversation.

### Step 3: Run `setup.sh`

Build the command from the user's answers and execute.

### Step 4: Apply customizations

If the user selected a database or framework, read the corresponding `references/*.md` file and apply the additional edits to `devenv.nix` and `pyproject.toml`.

## Setup Script

`setup.sh` generates all configuration files and directory structure in one step.

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PROJECT_NAME` | Project name in kebab-case (e.g. `simple-a2a-agent`) | **Required** |
| `PYTHON_VERSION` | Python version (e.g. `3.12`) | `3.12` |
| `DEPS` | Production dependencies, space-separated | (empty) |
| `DEV_DEPS` | Development dependencies, space-separated | (empty) |
| `TARGET_DIR` | Output directory | Current directory |

### Usage

```bash
# Basic setup
PROJECT_NAME="my-project" PYTHON_VERSION="3.12" \
  bash "${CLAUDE_PLUGIN_ROOT}/skills/python-devenv-setup/setup.sh"

# With dependencies
PROJECT_NAME="my-api" PYTHON_VERSION="3.12" \
  DEPS="fastapi uvicorn" DEV_DEPS="pytest-asyncio httpx" \
  bash "${CLAUDE_PLUGIN_ROOT}/skills/python-devenv-setup/setup.sh"
```

### Generated Files

| File | Purpose |
|------|---------|
| `devenv.yaml` | Nix flake inputs + cachix configuration |
| `devenv.nix` | Development environment definition |
| `.envrc` | direnv integration for auto-activation |
| `pyproject.toml` | Project config with hatch, ruff, pytest settings |
| `treefmt.toml` | Multi-language formatter config |
| `.gitignore` | Development artifact exclusions |
| `src/<package>/` | Source package directory with `__init__.py` |
| `tests/` | Test directory with `__init__.py` |

## Post-Setup

After running the script:

```bash
# Activate the environment
direnv allow

# Install Python dependencies
uv sync

# Verify
python --version
ruff --version
uv run ty --version
```

**Note:** `uv.sync.enable` is intentionally disabled in the devenv.nix template to avoid bootstrap failures when `src/<package>/` doesn't exist yet on first setup.

## DB / Framework Customization

The setup script generates a base configuration. For database or web framework support, edit `devenv.nix` and `pyproject.toml` after running the script:

- **Database support** (MySQL, PostgreSQL, SQLite) — see `references/database-variants.md`
- **Framework settings** (Django, FastAPI, Flask) — see `references/framework-variants.md`

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
