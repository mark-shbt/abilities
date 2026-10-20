#!/bin/bash
# Links the skills and adds the sync hook. It is safe to run again.

set -eu

REPO=$(cd "$(dirname "$0")" && pwd)

"$REPO/bin/link.sh"

python3 - "$HOME/.claude/settings.json" "$REPO/bin/sync.sh" <<'EOF'
import json, os, shlex, sys

# Follow a symlinked settings file so the edit does not replace the link.
path = os.path.realpath(sys.argv[1])
command = shlex.quote(sys.argv[2])

data = {}
if os.path.exists(path):
    with open(path) as f:
        data = json.load(f)

groups = data.setdefault("hooks", {}).setdefault("SessionStart", [])
if any(h.get("command") == command for g in groups for h in g.get("hooks", [])):
    sys.exit(0)

groups.append({
    "matcher": "startup",
    "hooks": [{"type": "command", "command": command, "timeout": 10}],
})
os.makedirs(os.path.dirname(path), exist_ok=True)
tmp = path + ".tmp"
with open(tmp, "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write("\n")
os.replace(tmp, path)
print("added the SessionStart hook to " + path)
EOF
