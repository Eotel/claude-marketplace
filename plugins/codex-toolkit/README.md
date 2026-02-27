# Codex Toolkit Plugin

External code review using Codex CLI as a parallel reviewer for Claude Code implementations.

## Purpose

Use a different LLM (Codex/OpenAI) to review code that Claude implemented. This provides:

- Independent perspective from a different model
- Parallel review across multiple concerns (bugs, security, edge-cases)
- Git diff-based analysis with `codex review` for focused reviews

## Workflow

```
Claude (implementer) -> writes code
        |
Codex CLI (reviewer) -> reviews git diff via `codex review`
        |
Claude -> summarizes findings and applies fixes
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

### `/codex-toolkit:codex-review [--uncommitted|--base <branch>|--commit <sha>]`

Run parallel code reviews using 3 perspectives:

| Perspective | Focus                                                    |
| ----------- | -------------------------------------------------------- |
| bugs        | Logic errors, off-by-one, null handling, race conditions |
| security    | Injection, auth flaws, data exposure                     |
| edge-cases  | Error handling, boundaries, timeouts                     |

**Usage:**

```bash
/codex-toolkit:codex-review                    # Review uncommitted changes (default)
/codex-toolkit:codex-review --uncommitted      # Explicitly review uncommitted changes
/codex-toolkit:codex-review --base main        # Review changes against main branch
/codex-toolkit:codex-review --commit abc123    # Review a specific commit
```

**Note:** Reviews run as background tasks with 20-minute timeout since Codex analysis may take longer due to reasoning.

## Scripts

### `scripts/review.sh`

Wrapper for `codex review` with predefined review prompts. Uses git diff-based analysis.

```bash
# Manual usage (plugin uses ${CLAUDE_PLUGIN_ROOT}/scripts/review.sh)
./scripts/review.sh bugs
./scripts/review.sh security --uncommitted
./scripts/review.sh edge-cases --base main
./scripts/review.sh bugs --commit abc123
```

## Session Hook

The plugin reminds Claude about Codex review capability at session start.

## License

MIT
