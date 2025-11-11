#!/bin/bash

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ALIASES_FILE="$HOME/work/github/scripts/bash/.bash_aliases"
BASHRC="$HOME/.bashrc"

echo -e "${YELLOW}Installing bash aliases...${NC}"

# Backup .bashrc
echo -e "${YELLOW}Creating backup of .bashrc...${NC}"
cp "$BASHRC" "$BASHRC.backup.$(date +%Y%m%d_%H%M%S)"
echo "✅ Backup created"

# Remove old sourcing line if exists (prevent duplicates)
sed -i '\|source.*scripts/bash/.bash_aliases|d' "$BASHRC"

# Add sourcing line to .bashrc
echo "" >> "$BASHRC"
echo "# Load custom aliases from scripts repo" >> "$BASHRC"
echo "source $ALIASES_FILE" >> "$BASHRC"

# Ensure personal bin folder is on PATH
if ! grep -q "scripts/bash/bin" "$BASHRC"; then
  echo "" >> "$BASHRC"
  echo "# Add personal bin folder to PATH" >> "$BASHRC"
  echo 'export PATH="$HOME/work/github/scripts/bash/bin:$PATH"' >> "$BASHRC"
fi

echo -e "${GREEN}✅ Aliases installed!${NC}"
echo ""
echo "Run: source ~/.bashrc"
