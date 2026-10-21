#!/bin/bash
# Each test uses a temporary HOME and a copy of bin/ with one test plugin.

set -u

SRC=$(cd "$(dirname "$0")/.." && pwd)
FAILED=0

# A temporary HOME has no git identity, so the tests supply one.
export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.com
export GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.com

# Fills T with HOME and a repo copy at R that has the plugin "kit".
setup() {
  export HOME="$T/home"
  mkdir -p "$HOME/.claude/skills"
  R="$T/abilities"
  mkdir -p "$R/plugins/kit/.claude-plugin"
  cp -R "$SRC/bin" "$R/"
  echo '{"name": "kit"}' > "$R/plugins/kit/.claude-plugin/plugin.json"
}

# A local repo stands in for github.com/acme/tools.
make_upstream() {
  local up="$T/gh/acme/tools.git"
  mkdir -p "$up/pack/skills/shiny/agents" "$up/pack/skills/other"
  echo "MIT test" > "$up/pack/LICENSE"
  printf -- '---\nname: shiny\ndescription: Test.\n---\n' > "$up/pack/skills/shiny/SKILL.md"
  echo extra > "$up/pack/skills/shiny/EXTRA.md"
  echo agent > "$up/pack/skills/shiny/agents/a.md"
  printf -- '---\nname: other\ndescription: Test.\n---\n' > "$up/pack/skills/other/SKILL.md"
  echo "Apache test" > "$up/pack/skills/other/LICENSE"
  git -C "$up" init -q -b main
  git -C "$up" add -A
  git -C "$up" commit -qm upstream
  export ABILITIES_GIT_BASE="file://$T/gh"
  URL=https://github.com/acme/tools/tree/main/pack/skills/shiny
}

test_add_skill_copies_skill() {
  setup
  make_upstream
  "$R/bin/add-skill.sh" kit "$URL" >/dev/null 2>&1 || return 1
  local k="$R/plugins/kit"
  [ -f "$k/skills/shiny/SKILL.md" ] && [ -f "$k/skills/shiny/EXTRA.md" ] &&
    [ -f "$k/skills/shiny/agents/a.md" ] && [ ! -e "$k/skills/other" ] &&
    [ "$(cat "$k/licenses/acme-tools.txt")" = "MIT test" ] || return 1
  python3 - "$R/sources.json" "$(git -C "$T/gh/acme/tools.git" rev-parse HEAD)" <<'EOF'
import json, sys
[entry] = json.load(open(sys.argv[1]))
assert entry == {"name": "shiny", "plugin": "kit", "repo": "acme/tools",
                 "path": "pack/skills/shiny", "ref": "main", "commit": sys.argv[2],
                 "license": "plugins/kit/licenses/acme-tools.txt"}
EOF
}

test_add_skill_name_in_use() {
  setup
  make_upstream
  "$R/bin/add-skill.sh" kit "$URL" >/dev/null 2>&1 || return 1
  echo "my change" >> "$R/plugins/kit/skills/shiny/SKILL.md"
  ! "$R/bin/add-skill.sh" kit "$URL" >/dev/null 2>&1 &&
    grep -q "my change" "$R/plugins/kit/skills/shiny/SKILL.md"
}

test_add_skill_keeps_each_license() {
  setup
  make_upstream
  "$R/bin/add-skill.sh" kit "$URL" >/dev/null 2>&1 || return 1
  "$R/bin/add-skill.sh" kit "${URL%/shiny}/other" >/dev/null 2>&1 || return 1
  [ "$(cat "$R/plugins/kit/licenses/acme-tools.txt")" = "MIT test" ] || return 1
  python3 - "$R/sources.json" "$R" <<'EOF'
import json, sys
entries = {e["name"]: e for e in json.load(open(sys.argv[1]))}
assert entries["shiny"]["license"] == "plugins/kit/licenses/acme-tools.txt"
assert open(sys.argv[2] + "/" + entries["other"]["license"]).read() == "Apache test\n"
EOF
}

# Old installs have this hook and links into the old skills/ folder.
test_cleanup_removes_old_install() {
  setup
  cat > "$HOME/.claude/settings.json" <<EOF
{"hooks": {"Stop": [{"hooks": [{"type": "command", "command": "/x/stop.sh"}]}],
           "SessionStart": [{"hooks": [{"type": "command", "command": "$R/bin/sync.sh", "timeout": 10}]}]},
 "effortLevel": "high"}
EOF
  ln -s "$R/skills/alpha" "$HOME/.claude/skills/alpha"
  ln -s "$T/elsewhere" "$HOME/.claude/skills/theirs"
  mkdir -p "$HOME/.claude/skills/mine"
  local out
  out=$(echo '{}' | "$R/bin/sync.sh") || return 1
  [ ! -L "$HOME/.claude/skills/alpha" ] && [ -L "$HOME/.claude/skills/theirs" ] &&
    [ -d "$HOME/.claude/skills/mine" ] || return 1
  echo "$out" | python3 -c 'import json, sys; assert "marketplace add" in json.load(sys.stdin)["systemMessage"]' || return 1
  python3 - "$HOME/.claude/settings.json" <<'EOF'
import json, sys
data = json.load(open(sys.argv[1]))
assert data["effortLevel"] == "high"
assert data["hooks"]["Stop"][0]["hooks"][0]["command"] == "/x/stop.sh"
assert "SessionStart" not in data["hooks"]
EOF
}

run() {
  local name=$1
  T=$(mktemp -d)
  if ( "$name" ) >/dev/null 2>&1; then
    echo "PASS $name"
  else
    echo "FAIL $name"
    FAILED=1
  fi
  rm -rf "$T"
}

for t in $(declare -F | awk '{print $3}' | grep '^test_'); do
  run "$t"
done

exit $FAILED
