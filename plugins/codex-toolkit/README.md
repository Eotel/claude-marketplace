# Codex Toolkit Plugin

External code review using Codex CLI as a parallel reviewer for Claude Code implementations.

## Purpose

Use a different LLM (Codex/OpenAI) to review code that Claude implemented. This provides:
- Independent perspective from a different model
- Parallel review across multiple concerns (bugs, security, edge-cases)
- High-quality analysis with Codex's reasoning capabilities

## Workflow

```
Claude (implementer) → writes code
        ↓
Codex CLI (reviewer) → reviews Claude's implementation
        ↓
Claude → summarizes findings and applies fixes
```

## Requirements

- [Codex CLI](https://github.com/openai/codex) installed: `npm install -g @openai/codex`
- OpenAI API key configured for Codex

The script will check for the `codex` command and provide installation instructions if missing.

## Installation

```bash
# Copy plugin to Claude Code plugins
cp -r plugins/codex-toolkit ~/.claude/plugins/
```

## Command

### `/codex-toolkit:codex-review [target]`

Run parallel code reviews using 3 perspectives:

| Perspective | Focus |
|-------------|-------|
| bugs | Logic errors, off-by-one, null handling, race conditions |
| security | Injection, auth flaws, data exposure |
| edge-cases | Error handling, boundaries, timeouts |

**Usage:**
```bash
/codex-toolkit:codex-review              # Review current directory
/codex-toolkit:codex-review src/auth.ts  # Review specific file
/codex-toolkit:codex-review ./src        # Review directory
```

## Scripts

### `scripts/review.sh`

Wrapper for `codex exec` with predefined review prompts. Codex reads files directly via `--sandbox read-only` mode.

```bash
./scripts/review.sh bugs src/main.ts
./scripts/review.sh security ./src
./scripts/review.sh edge-cases
```

## Direct Usage

For custom reviews without the wrapper:

```bash
# Basic review - Codex reads the file directly
codex exec --sandbox read-only --full-auto "Review src/auth.ts for bugs"

# With high reasoning effort
codex exec --sandbox read-only --full-auto --reasoning-effort high "Detailed security audit of ./src"
```

## Session Hook

The plugin reminds Claude about Codex review capability at session start.

## License

MIT
