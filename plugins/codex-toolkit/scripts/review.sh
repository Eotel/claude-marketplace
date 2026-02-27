#!/bin/bash
# Codex CLI review wrapper using `codex review` subcommand
# Usage: review.sh <perspective> [--uncommitted|--base <branch>|--commit <sha>]
#        review.sh --uncommitted|--base <branch>|--commit <sha>
# Perspectives: bugs, security, edge-cases
#
# Hybrid modes:
#   With perspective only  → codex review "custom prompt" (per-perspective)
#   With flag only         → codex review <flag> (comprehensive, single run)

set -euo pipefail

# Dependency check
if ! command -v codex &> /dev/null; then
  echo "Error: codex CLI not found. Install with: npm install -g @openai/codex"
  exit 1
fi

# Detect if first arg is a flag (flag-only mode) or perspective
case "${1:---help}" in
  --uncommitted|--base|--commit)
    # Flag-only mode: single comprehensive review
    exec codex review "$@"
    ;;
  --help|-h)
    echo "Usage: review.sh <perspective> [--uncommitted|--base <branch>|--commit <sha>]"
    echo "       review.sh --uncommitted|--base <branch>|--commit <sha>"
    echo ""
    echo "Perspectives: bugs, security, edge-cases"
    echo ""
    echo "Without flags: runs codex review with a per-perspective custom prompt."
    echo "With flags only: runs codex review <flag> for a comprehensive review."
    exit 0
    ;;
esac

PERSPECTIVE="$1"
shift || true

# If additional flags are provided with a perspective, use flag mode (ignore perspective)
if [[ $# -gt 0 ]]; then
  exec codex review "$@"
fi

# Per-perspective custom prompt mode (default)
case "$PERSPECTIVE" in
  bugs)
    PROMPT="Review the code changes for bugs and logic errors.
Focus on: incorrect logic, off-by-one errors, null handling, race conditions, resource leaks.
Output format: [file:line] Issue description"
    ;;
  security)
    PROMPT="Review the code changes for security vulnerabilities.
Focus on: injection attacks, auth flaws, data exposure, insecure dependencies.
Output format: [file:line] Issue description"
    ;;
  edge-cases)
    PROMPT="Review the code changes for edge case handling.
Focus on: missing error handling, boundary conditions, empty inputs, timeouts.
Output format: [file:line] Issue description"
    ;;
  *)
    echo "Unknown perspective: $PERSPECTIVE"
    echo "Usage: review.sh <bugs|security|edge-cases> [--uncommitted|--base <branch>|--commit <sha>]"
    exit 1
    ;;
esac

codex review "$PROMPT"
