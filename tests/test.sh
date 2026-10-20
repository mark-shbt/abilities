#!/bin/bash
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



test_install_manual_removes_hook() {
  setup alpha
  cat > "$HOME/.claude/settings.json" <<'EOF2'
{"hooks": {"Stop": [{"hooks": [{"type": "command", "command": "/x/stop.sh"}]}]}}
EOF2
  "$R/install.sh" --auto-update >/dev/null 2>&1 || return 1
  [ "$(hook_count)" = 1 ] || return 1
  "$R/install.sh" --manual >/dev/null 2>&1 || return 1
  [ "$(hook_count)" = 0 ] &&
    grep -q '/x/stop.sh' "$HOME/.claude/settings.json" &&
    [ -L "$HOME/.claude/skills/alpha" ]
}

test_sync_removes_deleted_skill() {
  setup alpha
  "$R/install.sh" >/dev/null 2>&1
  other_clone
  git -C "$T/other" rm -rq skills/alpha
  push_other "remove alpha"
  sync_hook || return 1
  [ ! -L "$HOME/.claude/skills/alpha" ] && [ ! -e "$HOME/.claude/skills/alpha" ]
}

test_sync_diverged() {
  setup alpha
  other_clone
  make_skill "$T/other" beta
  push_other "add beta"
  make_skill "$R" gamma
  git -C "$R" add -A
  git -C "$R" commit -qm "add gamma"
  local before out
  before=$(git -C "$R" rev-parse HEAD)
  out=$(sync_hook) || return 1
  [ "$(git -C "$R" rev-parse HEAD)" = "$before" ] &&
    [[ "$out" == *systemMessage* ]] &&
    [[ "$out" == *"git pull --rebase"* ]]
}



test_sync_pulls_new_skill() {
  setup alpha
  "$R/install.sh" >/dev/null 2>&1
  other_clone
  make_skill "$T/other" beta
  push_other "add beta"
  local out
  out=$(sync_hook) || return 1
  [ -L "$HOME/.claude/skills/beta" ] && [ -f "$HOME/.claude/skills/beta/SKILL.md" ] &&
    echo "$out" | python3 -c 'import json, sys; assert json.load(sys.stdin)["hookSpecificOutput"]["reloadSkills"] is True'
}

# The ext helper never answers, like a network that drops packets.
test_sync_fetch_time_limit() {
  setup alpha
  git -C "$R" config protocol.ext.allow always
  git -C "$R" remote set-url origin 'ext::sleep 30'
  local start out
  start=$(date +%s)
  out=$(sync_hook) || return 1
  [ $(($(date +%s) - start)) -lt 9 ] && [[ "$out" == *systemMessage* ]]
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
