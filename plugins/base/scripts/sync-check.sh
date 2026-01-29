#!/bin/bash
# sync-check.sh - Check differences between base plugin and everything-claude-code
#
# Usage: ./scripts/sync-check.sh [path-to-everything-claude-code]
#
# This script compares the base plugin with everything-claude-code to identify
# updates that may need to be merged.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
UPSTREAM="${1:-$HOME/ghq/github.com/affaan-m/everything-claude-code}"

if [ ! -d "$UPSTREAM" ]; then
    echo "Error: Upstream directory not found: $UPSTREAM"
    echo "Usage: $0 [path-to-everything-claude-code]"
    exit 1
fi

echo "========================================="
echo "Base Plugin Sync Check"
echo "========================================="
echo "Base:     $BASE_DIR"
echo "Upstream: $UPSTREAM"
echo ""

# Directories to compare
DIRS=("skills" "agents" "commands" "scripts/hooks" "scripts/lib" "hooks")

# Files/directories to exclude from comparison (project-specific)
EXCLUDES=(
    "golang-patterns"
    "golang-testing"
    "postgres-patterns"
    "continuous-learning-v2"
    "database-reviewer.md"
    "go-build-resolver.md"
    "go-reviewer.md"
    "go-build.md"
    "go-review.md"
    "go-test.md"
    "instinct-export.md"
    "instinct-import.md"
    "instinct-status.md"
    "evolve.md"
    ".gitkeep"
)

# Build exclude pattern for diff
EXCLUDE_PATTERN=""
for exc in "${EXCLUDES[@]}"; do
    EXCLUDE_PATTERN="$EXCLUDE_PATTERN --exclude=$exc"
done

for dir in "${DIRS[@]}"; do
    upstream_dir="$UPSTREAM/$dir"
    base_dir="$BASE_DIR/$dir"

    if [ ! -d "$upstream_dir" ]; then
        continue
    fi

    echo "--- $dir ---"

    if [ ! -d "$base_dir" ]; then
        echo "  [MISSING] Directory does not exist in base"
        continue
    fi

    # Run diff and capture output
    diff_output=$(diff -rq $EXCLUDE_PATTERN "$upstream_dir" "$base_dir" 2>/dev/null || true)

    if [ -z "$diff_output" ]; then
        echo "  [OK] No differences"
    else
        echo "$diff_output" | while read -r line; do
            # Parse diff output
            if [[ $line == "Only in $UPSTREAM"* ]]; then
                # Extract filename after ": "
                file="${line##*: }"
                echo "  [UPSTREAM ONLY] $file"
            elif [[ $line == "Only in $BASE_DIR"* ]]; then
                file="${line##*: }"
                echo "  [BASE ONLY] $file"
            elif [[ $line == "Files"*"differ" ]]; then
                # Extract just the relative path
                file="${line#Files }"
                file="${file%% and *}"
                file="${file#$upstream_dir/}"
                echo "  [DIFFER] $file"
            fi
        done
    fi
    echo ""
done

echo "========================================="
echo "Legend:"
echo "  [OK]            - No differences"
echo "  [UPSTREAM ONLY] - Exists only in everything-claude-code"
echo "  [BASE ONLY]     - Exists only in base plugin"
echo "  [DIFFER]        - Content differs"
echo ""
echo "Excluded (project-specific):"
for exc in "${EXCLUDES[@]}"; do
    echo "  - $exc"
done
echo "========================================="
