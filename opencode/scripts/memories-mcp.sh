#!/bin/bash
# Wrapper to set MEMORIES_DATA_DIR for memories.sh MCP server
# This ensures memory storage goes to ~/.dotfiles/opencode/memory/db/ instead of ~/.config/memories/
export MEMORIES_DATA_DIR="$HOME/.dotfiles/opencode/memory/db"
exec npx -y @memories.sh/cli serve "$@"
