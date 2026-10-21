#!/bin/bash
# Removes the old auto-update hook and links after the move to plugins.
# Old installs run this hook once more. It always exits 0.

set -u

REPO=$(cd "$(dirname "$0")/.." && pwd)
SKILLS="$HOME/.claude/skills"

# Claude Code sends hook input on stdin, and this hook does not use it.
[ -t 0 ] || cat >/dev/null 2>&1

# Only links into the old skills/ folder belong to this repo.
for link in "$SKILLS"/*; do
  [ -L "$link" ] || continue
  case "$(readlink "$link")" in
    "$REPO/skills/"*) rm -f "$link" ;;
  esac
done

python3 - "$HOME/.claude/settings.json" "$REPO/bin/sync.sh" <<'EOF'
import json, os, shlex, sys

# Follow a symlinked settings file so the edit does not replace the link.
path = os.path.realpath(sys.argv[1])
command = shlex.quote(sys.argv[2])

if os.path.exists(path):
    with open(path) as f:
        data = json.load(f)
    hooks = data.get("hooks", {})
    groups = hooks.get("SessionStart", [])
    for group in groups:
        group["hooks"] = [h for h in group.get("hooks", []) if h.get("command") != command]
    groups = [g for g in groups if g["hooks"]]
    if groups:
        hooks["SessionStart"] = groups
    else:
        hooks.pop("SessionStart", None)
    if "hooks" in data and not hooks:
        del data["hooks"]
    tmp = path + ".tmp"
    with open(tmp, "w") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write("\n")
    os.replace(tmp, path)

print(json.dumps({
    "systemMessage": "abilities: the skills moved to a plugin marketplace, and the old hook removed itself. "
                     "Run /plugin marketplace add https://github.com/markkyaw/abilities.git, "
                     "then /plugin install abilities@abilities. Then turn on auto-update for abilities in /plugin.",
    "hookSpecificOutput": {"hookEventName": "SessionStart", "reloadSkills": True},
}))
EOF

exit 0
