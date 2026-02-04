---
description: Run parallel code reviews using Codex CLI as an external reviewer
argument-hint: [target-path]
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/review.sh*)
---

# Codex Review

You are Claude Code. Use Codex CLI to get an external LLM review of code.

## Instructions

Run 3 parallel background reviews using the review script with different perspectives.

**IMPORTANT:** Always use the full script path with `${CLAUDE_PLUGIN_ROOT}`:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/review.sh bugs $TARGET
${CLAUDE_PLUGIN_ROOT}/scripts/review.sh security $TARGET
${CLAUDE_PLUGIN_ROOT}/scripts/review.sh edge-cases $TARGET
```

Where `$TARGET` is a file or directory path from the user's arguments (defaults to `.` if not specified).

## Workflow

1. Parse $ARGUMENTS for target path (defaults to current directory if empty)
2. Launch 3 background tasks using the Bash tool with:
   - `run_in_background: true`
   - `timeout: 1200000` (20 minutes - Codex reviews may take longer due to reasoning-intensive analysis)
3. Wait for all tasks to complete using TaskOutput
4. Summarize findings from all 3 perspectives
5. Report only actionable issues

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
