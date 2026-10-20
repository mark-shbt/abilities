#!/bin/bash
# Tests for install.sh, bin/link.sh, and bin/sync.sh.
# Each test uses a temporary HOME and a local bare repo as origin.

set -u

SRC=$(cd "$(dirname "$0")/.." && pwd)
FAILED=0

# A temporary HOME has no git identity, so the tests supply one.
export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.com
export GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.com

make_skill() {
  mkdir -p "$1/skills/$2"
  printf -- '---\nname: %s\ndescription: Test skill %s.\n---\n' "$2" "$2" > "$1/skills/$2/SKILL.md"
}

# Fills T with HOME, an origin with the given skills, and a clone at R.
setup() {
  export HOME="$T/home"
  mkdir -p "$HOME/.claude/skills" "$HOME/git"
  git init -q --bare -b main "$T/origin.git"
  local seed="$T/seed"
  mkdir -p "$seed/skills"
  touch "$seed/skills/.gitkeep"
  cp -R "$SRC/bin" "$SRC/install.sh" "$seed/" 2>/dev/null
  local name
  for name in "$@"; do make_skill "$seed" "$name"; done
  git -C "$seed" init -q -b main
  git -C "$seed" add -A
  git -C "$seed" commit -qm seed
  git -C "$seed" push -q "$T/origin.git" main
  R="$HOME/git/abilities"
  git clone -q "$T/origin.git" "$R"
}

# A second clone that acts as the other Mac.
other_clone() {
  git clone -q "$T/origin.git" "$T/other"
}

push_other() {
  git -C "$T/other" add -A
  git -C "$T/other" commit -qm "$1"
  git -C "$T/other" push -q origin main
}

sync_hook() {
  echo '{}' | "$R/bin/sync.sh"
}

# Prints how many SessionStart hooks run bin/sync.sh.
hook_count() {
  python3 - "$HOME/.claude/settings.json" <<'EOF'
import json, sys
data = json.load(open(sys.argv[1]))
groups = data.get("hooks", {}).get("SessionStart", [])
print(sum(1 for g in groups for h in g.get("hooks", [])
          if h.get("command", "").endswith("/bin/sync.sh")))
EOF
}

test_install_links_skills() {
  setup alpha
  "$R/install.sh" >/dev/null 2>&1
  [ -L "$HOME/.claude/skills/alpha" ] &&
    [ "$(readlink "$HOME/.claude/skills/alpha")" = "$R/skills/alpha" ]
}

test_install_keeps_settings() {
  setup alpha
  cat > "$HOME/.claude/settings.json" <<'EOF'
{"hooks": {"Stop": [{"hooks": [{"type": "command", "command": "/x/stop.sh"}]}]},
 "effortLevel": "high"}
EOF
  "$R/install.sh" >/dev/null 2>&1 || return 1
  python3 - "$HOME/.claude/settings.json" <<'EOF' || return 1
import json, sys
data = json.load(open(sys.argv[1]))
assert data["effortLevel"] == "high"
assert data["hooks"]["Stop"][0]["hooks"][0]["command"] == "/x/stop.sh"
EOF
  [ "$(hook_count)" = 1 ]
}

test_install_twice() {
  setup alpha
  "$R/install.sh" >/dev/null 2>&1
  "$R/install.sh" >/dev/null 2>&1
  [ "$(hook_count)" = 1 ]
}

test_install_no_settings() {
  setup alpha
  "$R/install.sh" >/dev/null 2>&1
  [ -f "$HOME/.claude/settings.json" ] && [ "$(hook_count)" = 1 ]
}

test_install_skips_real_folder() {
  setup alpha
  mkdir -p "$HOME/.claude/skills/alpha"
  touch "$HOME/.claude/skills/alpha/mine"
  local out
  out=$("$R/install.sh" 2>&1)
  [ ! -L "$HOME/.claude/skills/alpha" ] &&
    [ -f "$HOME/.claude/skills/alpha/mine" ] &&
    [[ "$out" == *"skip alpha"* ]]
}

test_install_ignores_synced() {
  setup alpha
  mkdir -p "$HOME/.claude/skills/synced/x"
  echo keep > "$HOME/.claude/skills/synced/x/SKILL.md"
  "$R/install.sh" >/dev/null 2>&1 || return 1
  [ ! -L "$HOME/.claude/skills/synced" ] &&
    [ "$(cat "$HOME/.claude/skills/synced/x/SKILL.md")" = keep ]
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
