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

## Output style
Be concise, list files changed, and include next steps.
