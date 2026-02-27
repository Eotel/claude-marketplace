---
description: Run parallel code reviews using Codex CLI as an external reviewer
argument-hint: [--uncommitted|--base <branch>|--commit <sha>]
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/review.sh*)
---

# Codex Review

You are Claude Code. Use Codex CLI to get an external LLM review of code changes.

## Instructions

### Mode 1: Default (no flags) — 3 parallel perspective reviews

When $ARGUMENTS is empty or not a flag, run 3 parallel background reviews:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/review.sh bugs
${CLAUDE_PLUGIN_ROOT}/scripts/review.sh security
${CLAUDE_PLUGIN_ROOT}/scripts/review.sh edge-cases
```

### Mode 2: With flag — single comprehensive review

When $ARGUMENTS contains `--uncommitted`, `--base <branch>`, or `--commit <sha>`, run a single review:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/review.sh $ARGUMENTS
```

This delegates directly to `codex review <flag>` for a built-in comprehensive review.

## Workflow

1. Parse $ARGUMENTS to determine the mode
2. **Mode 1 (default):** Launch 3 background tasks using the Bash tool with:
   - `run_in_background: true`
   - `timeout: 1200000` (20 minutes)
3. **Mode 2 (with flag):** Launch 1 background task with the same settings
4. Wait for all tasks to complete using TaskOutput
5. Summarize findings
6. Report only actionable issues

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

If no issues found in a category, state "No issues found."
For Mode 2 (single comprehensive review), adapt the format to match the output structure.
