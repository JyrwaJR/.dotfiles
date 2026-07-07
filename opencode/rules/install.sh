#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${HOME}/.claude/rules"
DRY_RUN=false
LIST_ONLY=false
LANG_DIRS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      TARGET="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --list)
      LIST_ONLY=true
      shift
      ;;
    --help|-h)
      echo "Usage: $0 [--target <dir>] [--dry-run] [--list] [language...]"
      exit 0
      ;;
    --)
      shift
      LANG_DIRS+=("$@")
      break
      ;;
    -*)
      echo "Error: unknown option: $1" >&2
      exit 1
      ;;
    *)
      LANG_DIRS+=("$1")
      shift
      ;;
  esac
done

AVAILABLE=()
for d in "$SCRIPT_DIR"/*/; do
  dirname="$(basename "$d")"
  if [[ "$dirname" != "common" ]]; then
    AVAILABLE+=("$dirname")
  fi
done

if [[ "$LIST_ONLY" == true ]]; then
  echo "Available language rules:"
  for lang in "${AVAILABLE[@]}"; do
    echo "  $lang"
  done
  exit 0
fi

if [[ ${#LANG_DIRS[@]} -eq 0 ]]; then
  echo "Usage: $0 [--target <dir>] [--dry-run] [language...]"
  echo ""
  echo "Available languages: ${AVAILABLE[*]}"
  exit 1
fi

if [[ ! -d "$SCRIPT_DIR/common" ]]; then
  echo "Error: common/ directory not found at $SCRIPT_DIR/common" >&2
  exit 1
fi

for lang in "${LANG_DIRS[@]}"; do
  found=false
  for a in "${AVAILABLE[@]}"; do
    if [[ "$lang" == "$a" ]]; then
      found=true
      break
    fi
  done
  if [[ "$found" == false ]]; then
    echo "Error: unknown language: $lang" >&2
    echo "Available: ${AVAILABLE[*]}" >&2
    exit 1
  fi
done

echo "Installing rules to: $TARGET"

if [[ "$DRY_RUN" == true ]]; then
  echo "  [DRY-RUN] cp -Rn $SCRIPT_DIR/common $TARGET/"
else
  mkdir -p "$TARGET"
  cp -Rn "$SCRIPT_DIR/common" "$TARGET/"
  echo "  Copied common/"
fi

for lang in "${LANG_DIRS[@]}"; do
  if [[ "$DRY_RUN" == true ]]; then
    echo "  [DRY-RUN] cp -Rn $SCRIPT_DIR/$lang $TARGET/"
  else
    cp -Rn "$SCRIPT_DIR/$lang" "$TARGET/"
    echo "  Copied $lang/"
  fi
done

echo "Done."
