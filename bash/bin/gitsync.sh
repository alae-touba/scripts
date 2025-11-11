#!/bin/bash
set -euo pipefail

# ─── COLORS ──────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

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

echo -e "${YELLOW}=== $(git status --short | wc -l) files changed ===${NC}"
git add -A
git commit -m "$COMMIT_MSG"
git push

echo -e "${GREEN}✓ Synced: $COMMIT_MSG${NC}"
