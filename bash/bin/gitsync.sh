#!/bin/bash
set -euo pipefail

# ─── CONFIGURE YOUR MESSAGE HERE (static, safe) ────────────────────────────
COMMIT_MSG="auto: sync scripts"

# ─── SCRIPT LOGIC (NO EDITS NEEDED BELOW) ──────────────────────────────────
if ! git rev-parse --git-dir &>/dev/null; then
  echo "Error: Not in a git repository" >&2
  exit 1
fi

if [[ -z "$(git status --porcelain)" ]]; then
  echo "No changes to commit"
  exit 0
fi

echo "=== $(git status --short | wc -l) files changed ==="
git add -A
git commit -m "$COMMIT_MSG"
git push

echo "✓ Synced: $COMMIT_MSG"
