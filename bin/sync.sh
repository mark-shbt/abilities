#!/bin/bash
# Pulls new skills at session start, then links them. It always exits 0.

set -u

REPO=$(cd "$(dirname "$0")/.." && pwd)
MESSAGES=""

# Claude Code sends hook input on stdin, and this hook does not use it.
[ -t 0 ] || cat >/dev/null 2>&1

warn() {
  MESSAGES="${MESSAGES:+$MESSAGES }$1"
}

# These settings stop a slow fetch or a password prompt before the time limit.
export GIT_TERMINAL_PROMPT=0
export GIT_SSH_COMMAND="ssh -o BatchMode=yes -o ConnectTimeout=5"
g() {
  git -C "$REPO" -c http.lowSpeedLimit=1000 -c http.lowSpeedTime=5 "$@"
}

if ! g fetch --quiet >/dev/null 2>&1; then
  warn "Could not reach GitHub, so this session uses the local skills."
elif ! g rev-parse --verify --quiet '@{u}' >/dev/null; then
  warn "The branch has no upstream. Run: git -C $REPO branch -u origin/main"
elif g merge-base --is-ancestor '@{u}' HEAD; then
  : # Up to date, or local commits wait for a push.
elif g merge-base --is-ancestor HEAD '@{u}'; then
  g merge --ff-only --quiet '@{u}' >/dev/null 2>&1 ||
    warn "Local changes block the update. Commit or stash them in $REPO."
else
  warn "This Mac and GitHub have different commits. Run: cd $REPO && git pull --rebase"
fi

while IFS= read -r line; do
  warn "$line."
done < <("$REPO/bin/link.sh")

# Claude Code reads one JSON object from stdout and shows systemMessage.
if [ -n "$MESSAGES" ]; then
  python3 -c 'import json, sys; print(json.dumps({"systemMessage": "abilities: " + sys.argv[1]}))' "$MESSAGES"
fi

exit 0
