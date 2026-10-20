#!/bin/bash
# Copies a skill folder from GitHub into skills/ and records its source.
# Usage: bin/add-skill.sh https://github.com/<owner>/<repo>/tree/<ref>/<path> [name]

set -eu

REPO=$(cd "$(dirname "$0")/.." && pwd)
# The tests set this variable to clone from a local folder.
BASE=${ABILITIES_GIT_BASE:-https://github.com}

usage() {
  echo "Usage: bin/add-skill.sh https://github.com/<owner>/<repo>/tree/<ref>/<path> [name]" >&2
  exit 2
}

url=${1:-}
url=${url%/}
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
name=${2:-$(basename "$path")}
dest="$REPO/skills/$name"

# An existing copy can have your own changes, so never replace it.
if [ -e "$dest" ]; then
  echo "The name $name is already in use: $dest" >&2
  exit 1
fi

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
license=""
dir=$path
while :; do
  for file in LICENSE LICENSE.md LICENSE.txt; do
    if [ -f "$tmp/src/$dir/$file" ]; then
      license="licenses/$owner-$repo.txt"
      mkdir -p "$REPO/licenses"
      cp "$tmp/src/$dir/$file" "$REPO/$license"
      break 2
    fi
  done
  [ "$dir" = . ] && break
  dir=$(dirname "$dir")
done

mkdir -p "$REPO/skills"
cp -R "$tmp/src/$path" "$dest"

python3 - "$REPO/sources.json" "$name" "$owner/$repo" "$path" "$ref" "$commit" "$license" <<'EOF'
import json, os, sys

path, name, repo, src_path, ref, commit, license = sys.argv[1:]
entries = []
if os.path.exists(path):
    with open(path) as f:
        entries = json.load(f)
entries.append({"name": name, "repo": repo, "path": src_path, "ref": ref,
                "commit": commit, "license": license or None})
entries.sort(key=lambda e: e["name"])
with open(path, "w") as f:
    json.dump(entries, f, indent=2)
    f.write("\n")
EOF

"$REPO/bin/link.sh"
echo "Added $name from $owner/$repo at ${commit:0:7}."
if [ -z "$license" ]; then
  echo "Warning: no license file found. Check the license before you push."
fi
echo "Commit and push skills/$name and sources.json${license:+ and $license}."
