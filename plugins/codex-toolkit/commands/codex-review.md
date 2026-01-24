---
description: Run parallel code reviews using Codex CLI as an external reviewer
argument-hint: [target-path]
allowed-tools: Bash(./scripts/review.sh*), Bash(codex exec*)
---

# Codex Review

You are Claude Code. Use Codex CLI to get an external LLM review of code you implemented.

## Instructions

Run 3 parallel background reviews using different perspectives:

```bash
# Run all 3 in parallel as background tasks
./scripts/review.sh bugs $TARGET &
./scripts/review.sh security $TARGET &
./scripts/review.sh edge-cases $TARGET &
```

Where `$TARGET` is a file or directory path (defaults to `.` if empty).

Codex will read the files directly via `--sandbox read-only` mode.

## Alternative: Direct codex exec

For custom review prompts, use codex exec directly:

```bash
codex exec --sandbox read-only --full-auto "Review src/auth.ts for bugs"
```

For detailed analysis, add reasoning flag:

```bash
codex exec --sandbox read-only --full-auto --reasoning-effort high "Review src/auth.ts for security vulnerabilities"
```

## Workflow

1. Parse $ARGUMENTS for target path (defaults to current directory)
2. Launch 3 background tasks with `run_in_background: true`
3. Wait for all to complete using TaskOutput
4. Summarize findings from all perspectives
5. Report actionable issues only

## Output Format

After collecting results, summarize:

```
## Codex Review Summary

### Bugs
- [file:line] Issue description

### Security
- [file:line] Issue description

### Edge Cases
- [file:line] Issue description

### Verdict
[Overall assessment and recommended actions]
```
