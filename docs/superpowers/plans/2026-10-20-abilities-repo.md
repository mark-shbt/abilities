# Abilities Repo Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make a private repo of personal Claude Code skills that two Macs load and keep in sync.

**Architecture:** Each Mac clones the repo to `~/git/abilities`. A link script makes one symlink per skill folder in `~/.claude/skills/`. A `SessionStart` hook pulls the repo with `--ff-only` and runs the link script again.

**Tech Stack:** POSIX `sh` and `bash` 3.2 (the macOS default), `git`, and `python3` for the JSON edit. All of them come with the macOS developer tools.

**Spec:** The design that the user approved in chat on 2026-10-20. The summary is below.

## Global Constraints

- Repo: `markkyaw/abilities`, private. Clone path: `~/git/abilities`.
- Skills live in `skills/<name>/SKILL.md`.
- Never read, change, or delete `~/.claude/skills/synced`.
- Never replace a real file or folder in `~/.claude/skills/`. Skip it and warn.
- The hook never commits, pushes, merges, or rebases. It only uses `git pull --ff-only`.
- The hook always exits 0. A failure shows one warning line and never blocks the session.
- Hook time limit: 10 seconds.
- `install.sh` keeps every other key in `~/.claude/settings.json`, including the `Stop` hook.
- Running `install.sh` two times gives the same result as one time.
- No new third-party tools.
- All prose and comments use ASD-STE100. Comments are 7 to 15 words.
- All scripts use `$HOME`, so the tests can use a temporary home folder.

## Review Focus

- The two Macs have different commits: the pull stops, the work stays, and one warning shows.
- No network or no GitHub access: the session starts in the 10-second limit with one warning.
- A skill name is the same as a real folder in `~/.claude/skills/`: the script skips it and warns.
- The other Mac deletes a skill: the link for that skill goes away.
- `~/.claude/settings.json` does not exist or has no `hooks` key: the script makes the file or key.

---

### Task 1: Link script and install script

**Files:**
- Create: `bin/link.sh`
- Create: `install.sh`
- Create: `skills/.gitkeep`
- Test: `tests/test.sh`

**Interfaces:**
- Produces: `bin/link.sh` with no arguments. It prints one warning line for each skipped skill to stdout and exits 0.
- Produces: `install.sh` with no arguments. It runs `bin/link.sh`, then adds the hook.
- Produces: the hook entry `{"matcher": "startup", "hooks": [{"type": "command", "command": "<repo>/bin/sync.sh", "timeout": 10}]}` under `hooks.SessionStart`.
- Produces: `tests/test.sh`. It makes a temporary `HOME` and a local bare repo as `origin`. It prints `PASS <name>` or `FAIL <name>` for each test and exits 1 on a failure.

- [ ] **Step 1: Write the failing tests in `tests/test.sh`**

- `test_install_links_skills`: a repo with `skills/alpha` gives a symlink at `$HOME/.claude/skills/alpha` to the repo folder.
- `test_install_keeps_settings`: an existing `settings.json` with a `Stop` hook and `"effortLevel": "high"` keeps both after the install.
- `test_install_twice`: two runs give one `SessionStart` entry for `sync.sh`.
- `test_install_no_settings`: with no `settings.json`, the install makes the file with the hook.
- `test_install_skips_real_folder`: a real folder at `$HOME/.claude/skills/alpha` stays as it is, and the output contains `skip alpha`.
- `test_install_ignores_synced`: a file in `$HOME/.claude/skills/synced` stays unchanged.

- [ ] **Step 2: Run `bash tests/test.sh` and see the six FAIL lines**

- [ ] **Step 3: Write `bin/link.sh`**

The script finds the repo from its own path. It links each folder in `skills/` that has a `SKILL.md`. It replaces a symlink that points to a different path. It removes a symlink whose target is in `<repo>/skills/` and does not exist.

- [ ] **Step 4: Write `install.sh`**

The script runs `bin/link.sh`. Then a `python3` heredoc loads `settings.json` (or `{}`), adds the hook entry only if no entry has the same `command`, and writes the file with a two-space indent.

- [ ] **Step 5: Run `bash tests/test.sh` and see six PASS lines**

- [ ] **Step 6: Commit**

```bash
git add bin/link.sh install.sh skills/.gitkeep tests/test.sh
git commit -m "Add the link script, the install script, and the tests"
```

### Task 2: Sync hook

**Files:**
- Create: `bin/sync.sh`
- Modify: `tests/test.sh`

**Interfaces:**
- Consumes: `bin/link.sh` from Task 1.
- Produces: `bin/sync.sh` with no arguments. On success it prints nothing. On a problem it prints one JSON line, `{"systemMessage": "abilities: <reason>"}`, and exits 0.

- [ ] **Step 1: Add the failing tests to `tests/test.sh`**

- `test_sync_pulls_new_skill`: a new skill pushed to `origin` from a second clone gets a link after `sync.sh`.
- `test_sync_removes_deleted_skill`: a skill deleted on `origin` loses its link after `sync.sh`.
- `test_sync_diverged`: a local commit and a different `origin` commit leave `HEAD` unchanged. The output contains `systemMessage` and `git pull --rebase`.
- `test_sync_offline`: an `origin` URL that does not exist gives exit 0 and a `systemMessage` line.
- `test_sync_quiet`: with no new commits, the output is empty.

- [ ] **Step 2: Run `bash tests/test.sh` and see the five new FAIL lines**

- [ ] **Step 3: Write `bin/sync.sh`**

The script reads and discards stdin. It sets `GIT_TERMINAL_PROMPT=0` and passes `-c http.lowSpeedLimit=1000 -c http.lowSpeedTime=5` to git. It runs `git pull --ff-only --quiet`. On a failure it prints the warning and still runs `bin/link.sh`. It also forwards each `link.sh` warning as a `systemMessage` line.

- [ ] **Step 4: Run `bash tests/test.sh` and see eleven PASS lines**

- [ ] **Step 5: Commit**

```bash
git add bin/sync.sh tests/test.sh
git commit -m "Add the sync hook that pulls and links skills"
```

### Task 3: README, GitHub repo, and setup on this Mac

**Files:**
- Create: `README.md`
- Create: `.gitignore` (ignore `.DS_Store`)

- [ ] **Step 1: Write `README.md`**

Sections: what the repo is, set up a new Mac (`gh repo clone markkyaw/abilities ~/git/abilities`, then `~/git/abilities/install.sh`), add a skill, how the sync works, and what to do after the warning about different commits.

- [ ] **Step 2: Commit, then make the private repo and push**

```bash
git add README.md .gitignore docs
git commit -m "Add the README and the plan"
gh repo create markkyaw/abilities --private --source . --push
```

- [ ] **Step 3: Run `./install.sh` on this Mac**

Expected: `~/.claude/settings.json` has the `SessionStart` entry and still has the `Stop` hook.

- [ ] **Step 4: Do an end-to-end check with a temporary skill**

Add `skills/abilities-check/SKILL.md`, run `bin/link.sh`, and run `claude -p` to ask for the skill by name. Expected: Claude finds the skill. Then delete the skill and run `bin/link.sh`. Expected: the link goes away.
