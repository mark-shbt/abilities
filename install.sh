#!/bin/bash
# Links the skills and sets the auto-update hook. It is safe to run again.
# Usage: install.sh [--auto-update | --manual]

set -eu

REPO=$(cd "$(dirname "$0")" && pwd)

case "${1:-}" in
  --auto-update) mode=auto ;;
  --manual) mode=manual ;;
  "")
    mode=auto
    if [ -t 0 ]; then
      read -r -p "Turn on auto-update? [Y/n] " answer
      case "$answer" in [nN]*) mode=manual ;; esac
    fi
    ;;
  *)
    echo "Usage: install.sh [--auto-update | --manual]" >&2
    exit 2
    ;;
esac

"$REPO/bin/link.sh"

python3 - "$HOME/.claude/settings.json" "$REPO/bin/sync.sh" "$mode" <<'EOF'
import json, os, shlex, sys

# Follow a symlinked settings file so the edit does not replace the link.
path = os.path.realpath(sys.argv[1])
command = shlex.quote(sys.argv[2])
mode = sys.argv[3]

data = {}
if os.path.exists(path):
    with open(path) as f:
        data = json.load(f)

hooks = data.setdefault("hooks", {})
groups = hooks.get("SessionStart", [])
for group in groups:
    group["hooks"] = [h for h in group.get("hooks", []) if h.get("command") != command]
groups = [g for g in groups if g["hooks"]]

if mode == "auto":
    groups.append({
        "matcher": "startup",
        "hooks": [{"type": "command", "command": command, "timeout": 10}],
    })

if groups:
    hooks["SessionStart"] = groups
else:
    hooks.pop("SessionStart", None)
if not hooks:
    del data["hooks"]

os.makedirs(os.path.dirname(path), exist_ok=True)
tmp = path + ".tmp"
with open(tmp, "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write("\n")
os.replace(tmp, path)

if mode == "auto":
    print("Auto-update is on. Each new Claude Code session pulls this repo.")
else:
    print("Auto-update is off. Run bin/sync.sh to update.")
EOF
