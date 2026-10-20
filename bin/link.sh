#!/bin/bash
# Links each skill folder in this repo into ~/.claude/skills.
# Prints one line for each skipped skill. It always exits 0.

set -u

REPO=$(cd "$(dirname "$0")/.." && pwd)
SRC="$REPO/skills"
DEST="$HOME/.claude/skills"

mkdir -p "$DEST" || exit 0

for dir in "$SRC"/*/; do
  [ -f "${dir}SKILL.md" ] || continue
  name=$(basename "$dir")
  target="$SRC/$name"
  link="$DEST/$name"
  if [ -L "$link" ]; then
    [ "$(readlink "$link")" = "$target" ] && continue
    rm "$link"
  elif [ -e "$link" ]; then
    # A real folder may be your own work, so the script never replaces it.
    echo "skip $name: $link is not a symlink"
    continue
  fi
  ln -s "$target" "$link"
done

# The other Mac can delete a skill, which leaves a broken link here.
for link in "$DEST"/*; do
  [ -L "$link" ] || continue
  case "$(readlink "$link")" in
    "$SRC"/*) [ -e "$link" ] || rm "$link" ;;
  esac
done

exit 0
