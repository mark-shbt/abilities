#!/bin/bash
# Pulls new skills at session start, then links them. It always exits 0.

set -u

REPO=$(cd "$(dirname "$0")/.." && pwd)
MESSAGES=""
RELOAD=false

# Claude Code sends hook input on stdin, and this hook does not use it.
[ -t 0 ] || cat >/dev/null 2>&1

warn() {
  MESSAGES="${MESSAGES:+$MESSAGES }$1"
}

# These settings stop a password prompt or a slow SSH connect.
export GIT_TERMINAL_PROMPT=0
export GIT_SSH_COMMAND="ssh -o BatchMode=yes -o ConnectTimeout=5"
g() {
  git -C "$REPO" "$@"
}

# A remote helper can start its own children, so stop the full tree.
kill_tree() {
  local child
  for child in $(pgrep -P "$1"); do kill_tree "$child"; done
  kill "$1" 2>/dev/null
}

# The fetch gets 6 seconds, so the hook ends before its 10-second limit.
fetch() {
  local err pid status
  err=$(mktemp)
  g fetch --quiet >/dev/null 2>"$err" &
  pid=$!
  for _ in $(seq 60); do
    kill -0 "$pid" 2>/dev/null || break
    sleep 0.1
  done
  if kill -0 "$pid" 2>/dev/null; then
    kill_tree "$pid"
    warn "GitHub did not answer in 6 seconds, so this session uses the local skills."
    rm -f "$err"
    return 1
  fi
  wait "$pid"
  status=$?
  if [ "$status" -ne 0 ]; then
    warn "The fetch failed, so this session uses the local skills. Git said: $(head -n 1 "$err")"
  fi
  rm -f "$err"
  return "$status"
}

before=$(g rev-parse HEAD 2>/dev/null)

if fetch; then
  if ! g rev-parse --verify --quiet '@{u}' >/dev/null; then
    warn "The branch has no upstream. Run: git -C $REPO branch -u origin/main"
  elif g merge-base --is-ancestor '@{u}' HEAD; then
    : # Up to date, or local commits wait for a push.
  elif g merge-base --is-ancestor HEAD '@{u}'; then
    g merge --ff-only --quiet '@{u}' >/dev/null 2>&1 ||
      warn "Local changes block the update. Commit or stash them in $REPO."
  else
    warn "This Mac and GitHub have different commits. Run: cd $REPO && git pull --rebase"
  fi
fi

# Claude Code finds skills before this hook ends, so changes need a reload.
[ "$(g rev-parse HEAD 2>/dev/null)" = "$before" ] || RELOAD=true

while IFS= read -r line; do
  case "$line" in
    linked\ * | removed\ *) RELOAD=true ;;
    *) warn "$line." ;;
  esac
done < <("$REPO/bin/link.sh")

if [ -n "$MESSAGES" ] || [ "$RELOAD" = true ]; then
  python3 - "$MESSAGES" "$RELOAD" <<'EOF'
import json, sys

messages, reload = sys.argv[1], sys.argv[2] == "true"
out = {}
if messages:
    out["systemMessage"] = "abilities: " + messages
if reload:
    out["hookSpecificOutput"] = {"hookEventName": "SessionStart", "reloadSkills": True}
print(json.dumps(out))
EOF
fi

exit 0
