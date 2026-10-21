#!/bin/bash
# Copies a skill folder from GitHub into a plugin and records its source.
# Usage: bin/add-skill.sh <plugin> https://github.com/<owner>/<repo>/tree/<ref>/<path> [name]

set -eu

REPO=$(cd "$(dirname "$0")/.." && pwd)
# The tests set this variable to clone from a local folder.
BASE=${ABILITIES_GIT_BASE:-https://github.com}

usage() {
  echo "Usage: bin/add-skill.sh <plugin> https://github.com/<owner>/<repo>/tree/<ref>/<path> [name]" >&2
  exit 2
}

plugin=${1:-}
url=${2:-}
url=${url%/}
[ -n "$plugin" ] || usage
PLUGIN_DIR="$REPO/plugins/$plugin"
if [ ! -f "$PLUGIN_DIR/.claude-plugin/plugin.json" ]; then
  echo "No plugin named $plugin in $REPO/plugins" >&2
  exit 1
fi
case "$url" in
  https://github.com/*/*/tree/*/*) ;;
  *) usage ;;
esac

# A branch name with a slash is not supported, because the URL is ambiguous.
rest=${url#https://github.com/}
owner=${rest%%/*}
rest=${rest#*/}
repo=${rest%%/*}
rest=${rest#*/tree/}
ref=${rest%%/*}
path=${rest#*/}
name=${3:-$(basename "$path")}
dest="$PLUGIN_DIR/skills/$name"

# An existing copy can have your own changes, so never replace it.
for used in "$REPO"/plugins/*/skills/"$name"; do
  if [ -e "$used" ]; then
    echo "The name $name is already in use: $used" >&2
    exit 1
  fi
done

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

git clone --quiet --depth 1 --filter=blob:none --sparse -b "$ref" \
  "$BASE/$owner/$repo.git" "$tmp/src"
git -C "$tmp/src" sparse-checkout set "$path"
if [ ! -f "$tmp/src/$path/SKILL.md" ]; then
  echo "No SKILL.md in $owner/$repo at $path" >&2
  exit 1
fi
commit=$(git -C "$tmp/src" rev-parse HEAD)

# Cone mode also checks out the files of each parent folder.
# Each plugin holds its own license copies, because installs copy only the plugin.
license=""
dir=$path
while :; do
  for file in LICENSE LICENSE.md LICENSE.txt; do
    if [ -f "$tmp/src/$dir/$file" ]; then
      license="plugins/$plugin/licenses/$owner-$repo.txt"
      # Two skills from one repo can have different licenses, so keep both.
      if [ -f "$REPO/$license" ] && ! cmp -s "$tmp/src/$dir/$file" "$REPO/$license"; then
        license="plugins/$plugin/licenses/$owner-$repo-$name.txt"
      fi
      mkdir -p "$PLUGIN_DIR/licenses"
      cp "$tmp/src/$dir/$file" "$REPO/$license"
      break 2
    fi
  done
  [ "$dir" = . ] && break
  dir=$(dirname "$dir")
done

mkdir -p "$PLUGIN_DIR/skills"
cp -R "$tmp/src/$path" "$dest"

python3 - "$REPO/sources.json" "$name" "$plugin" "$owner/$repo" "$path" "$ref" "$commit" "$license" <<'EOF'
import json, os, sys

path, name, plugin, repo, src_path, ref, commit, license = sys.argv[1:]
entries = []
if os.path.exists(path):
    with open(path) as f:
        entries = json.load(f)
entries.append({"name": name, "plugin": plugin, "repo": repo, "path": src_path, "ref": ref,
                "commit": commit, "license": license or None})
entries.sort(key=lambda e: e["name"])
with open(path, "w") as f:
    json.dump(entries, f, indent=2)
    f.write("\n")
EOF

echo "Added $name to $plugin from $owner/$repo at ${commit:0:7}."
if [ -z "$license" ]; then
  echo "Warning: no license file found. Check the license before you push."
elif ! head -n 1 "$REPO/$license" | grep -q '^MIT License'; then
  echo "Warning: the license is not MIT. Update the license field in plugins/$plugin/.claude-plugin/plugin.json."
fi
echo "Commit and push plugins/$plugin and sources.json."
