---
name: rust-devenv-setup
description: Reproducible Nix-based Rust development environment setup with devenv, rust-overlay, clippy, rustfmt, and rust-analyzer.
user-invocable: false
---

# Rust Development Environment Setup

Set up a complete, reproducible Rust development environment using devenv and rust-overlay.

## Tools Included

| Tool | Purpose |
|------|---------|
| **devenv** | Nix-based declarative development environment |
| **rust-overlay** | Nix overlay for flexible Rust toolchain selection |
| **clippy** | Rust linter |
| **rustfmt** | Rust formatter |
| **rust-analyzer** | Rust LSP for IDE support |
| **cbindgen** | C header generation from Rust FFI crates (optional) |

## Prerequisites

- Nix package manager installed
- direnv installed and hooked into shell
- devenv CLI installed

## Implementation Workflow

Before running the setup script, gather parameters from the user using `AskUserQuestion`.

### Step 1: Infer defaults

- **PROJECT_NAME**: Infer from the current directory name or `Cargo.toml` package name
- **RUST_CHANNEL**: Default to `stable`
- **RUST_EDITION**: Default to `2024`
- **EXTRA_PACKAGES**: Infer from Cargo.toml dependencies (e.g. if `volcap-ffi` uses cdylib → add cbindgen)

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
      question: "Which Rust channel?",
      header: "Rust Channel",
      options: [
        { label: "stable (Recommended)", description: "Latest stable release" },
        { label: "nightly", description: "Nightly with unstable features" },
        { label: "beta", description: "Next stable candidate" }
      ],
      multiSelect: false
    },
    {
      question: "Extra packages needed?",
      header: "Extras",
      options: [
        { label: "None", description: "Base Rust toolchain only" },
        { label: "cbindgen", description: "C/C++ header generation for FFI crates" },
        { label: "cargo-nextest", description: "Faster test runner" },
        { label: "cargo-watch", description: "File watcher for auto-rebuild" }
      ],
      multiSelect: true
    }
  ]
})
```

### Step 3: Run `setup.sh`

Build the command from the user's answers and execute.

### Step 4: Add rust-overlay input

After running the script, add the rust-overlay input:

```bash
cd "${TARGET_DIR}" && devenv inputs add rust-overlay github:oxalica/rust-overlay --follows nixpkgs
```

This step is required because `devenv inputs add` modifies `devenv.yaml` with a lock entry that cannot be templated.

## Setup Script

`setup.sh` generates configuration files and directory structure.

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PROJECT_NAME` | Project name in kebab-case | **Required** |
| `RUST_CHANNEL` | Rust toolchain channel (`stable`, `nightly`, `beta`) | `stable` |
| `EXTRA_PACKAGES` | Space-separated extra nix packages (e.g. `rust-cbindgen cargo-nextest`) | (empty) |
| `TARGET_DIR` | Output directory | Current directory |

### Usage

```bash
# Basic setup
PROJECT_NAME="my-project" \
  bash "${CLAUDE_PLUGIN_ROOT}/skills/rust-devenv-setup/setup.sh"

# With extras
PROJECT_NAME="my-ffi-lib" RUST_CHANNEL="stable" \
  EXTRA_PACKAGES="rust-cbindgen" \
  bash "${CLAUDE_PLUGIN_ROOT}/skills/rust-devenv-setup/setup.sh"
```

### Generated Files

| File | Purpose |
|------|---------|
| `devenv.yaml` | Nix flake inputs (nixpkgs + rust-overlay) + cachix |
| `devenv.nix` | Rust toolchain + extra packages |
| `.envrc` | direnv integration for auto-activation |

**Note:** `devenv.yaml` is generated without the `rust-overlay` input lock. Run `devenv inputs add rust-overlay ...` after generation (Step 4).

## Post-Setup

After running the script:

```bash
# Add rust-overlay input (required for languages.rust.channel)
devenv inputs add rust-overlay github:oxalica/rust-overlay --follows nixpkgs

# Activate the environment
direnv allow

# Verify
rustc --version
cargo --version
```

## Key Gotchas

### `use_devenv: command not found` in direnv

The `.envrc` must contain `eval "$(devenv direnvrc)"` before `use devenv`. This is NOT a global direnv setting — it must be per-project.

### `languages.rust.channel` requires rust-overlay

Without the `rust-overlay` input, devenv will error:

```
error: To use 'languages.rust.channel', run:
  $ devenv inputs add rust-overlay github:oxalica/rust-overlay --follows nixpkgs
```

### nixpkgs package naming

Some Rust tools have different names in nixpkgs:

| Tool | nixpkgs package name |
|------|---------------------|
| cbindgen | `pkgs.rust-cbindgen` (NOT `pkgs.cbindgen`) |
| cargo-nextest | `pkgs.cargo-nextest` |
| cargo-watch | `pkgs.cargo-watch` |

Use `nix search nixpkgs <keyword>` to verify package names.

## Verification

```bash
# Check devenv status
devenv info

# Run clippy
cargo clippy

# Check formatting
cargo fmt --check

# Build
cargo check
```

## Customization References

- **FFI / cdylib crates** — see `references/ffi-variants.md`
