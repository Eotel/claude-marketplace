---
name: codex-workflow
description: Use when working in a repo with Codex CLI to plan, edit files safely, and suggest verification steps.
---

# Codex Workflow

## Trigger
Use this skill when the user wants repository changes, investigation, or automation via shell commands.

## Steps
1. Clarify the goal if needed.
2. Inspect the repo with `rg --files`, `rg -n`, `ls`, or `tree`.
3. Propose a short plan for multi-step work.
4. Apply edits via `apply_patch` for single-file changes; scripts for bulk edits.
5. Avoid destructive git commands unless explicitly asked.
6. Suggest verification steps (lint/build/tests) when appropriate.

## Codex CLI notes (TTY vs non-interactive)
- `codex` (no subcommand) launches the interactive TUI and requires a TTY. If stdin/stdout are not terminals (e.g., non-interactive runners), do not run it.
- Use `codex exec` (or `codex review`) for non-interactive usage. Example: `codex exec --sandbox read-only "Review changes..."`.
- `-a/--ask-for-approval` accepts only: `untrusted`, `on-failure`, `on-request`, `never` and applies to `codex` (interactive) only. `codex exec` does not accept `-a`.
- If you want low-friction auto execution in `codex exec`, use `--full-auto` and/or `--sandbox`.
- When unsure, check TTY with `test -t 0` and `test -t 1`.

## Output style
Be concise, list files changed, and include next steps.
