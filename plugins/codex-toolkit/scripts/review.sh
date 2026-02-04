#!/bin/bash
# Codex CLI review wrapper
# Usage: review.sh <perspective> [target]
# Perspectives: bugs, security, edge-cases

set -euo pipefail

# Dependency check
if ! command -v codex &> /dev/null; then
  echo "Error: codex CLI not found. Install with: npm install -g @openai/codex"
  exit 1
fi

PERSPECTIVE="${1:-bugs}"
TARGET="${2:-.}"

case "$PERSPECTIVE" in
  bugs)
    PROMPT="Review the code in '$TARGET' for bugs and logic errors.
Focus on: incorrect logic, off-by-one errors, null handling, race conditions, resource leaks.
Output format: [file:line] Issue description"
    ;;
  security)
    PROMPT="Review the code in '$TARGET' for security vulnerabilities.
Focus on: injection attacks, auth flaws, data exposure, insecure dependencies.
Output format: [file:line] Issue description"
    ;;
  edge-cases)
    PROMPT="Review the code in '$TARGET' for edge case handling.
Focus on: missing error handling, boundary conditions, empty inputs, timeouts.
Output format: [file:line] Issue description"
    ;;
  *)
    echo "Unknown perspective: $PERSPECTIVE"
    echo "Usage: review.sh <bugs|security|edge-cases> [target-path]"
    exit 1
    ;;
esac

# Use read-only sandbox for safe code review (no modifications)
# exec runs non-interactively, suitable for background tasks
codex exec --sandbox read-only "$PROMPT"
