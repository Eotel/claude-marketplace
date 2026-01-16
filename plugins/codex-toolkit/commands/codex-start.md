---
description: Plan a safe Codex CLI workflow for a repo task.
argument-hint: [task]
---

# Codex Start

You are Claude Code running in a shell environment. Create a short, safe execution plan for the task described by the user or $ARGUMENTS.

Instructions:
1. Restate the goal.
2. Identify required info; ask only if missing.
3. List 3-6 steps.
4. Use ripgrep (rg) for searches; prefer apply_patch for single-file edits.
5. Avoid destructive git commands unless explicitly asked.
6. After edits, suggest relevant checks (lint/build/tests).

If $ARGUMENTS is empty, ask the user for the task.
