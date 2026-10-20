# Abilities Public Repo Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the abilities repo public, let each person select auto-update, and add copied third-party skills.

**Architecture:** Third-party skills are copies in `skills/<name>/`, the same as personal skills. `bin/add-skill.sh` makes a copy from a GitHub folder URL and records its source in `sources.json`. Auto-update pulls only this repo. `install.sh` adds or removes the hook from the choice of each person.

**Tech Stack:** `bash` 3.2, `git`, and `python3` from the macOS developer tools.

**Spec:** The design that the user approved in chat on 2026-10-20, after `2026-10-20-abilities-repo.md`. The summary is below.

## Global Constraints

- The repo is public. Commit email: `30735477+markkyaw@users.noreply.github.com`.
- Auto-update pulls only this repo. Nothing on a user machine fetches from a third-party repo.
- The first third-party skills: `unslop` from `cursor/plugins` path `pstack/skills/unslop`, and `grilling`, `grill-me`, `teach` from `mattpocock/skills` paths `skills/productivity/<name>`, and `wayfinder`, `prototype` from `skills/engineering/<name>`.
- A copied skill keeps all files in its source folder.
- The repo keeps the license of each source in `licenses/<owner>-<repo>.txt`.
- No script updates the copies from the source. The owner changes them by hand.
- All constraints from `2026-10-20-abilities-repo.md` still apply: the hook never commits, merges, rebases, or pushes, and it always exits 0.
- All prose and comments use ASD-STE100. Comments are 7 to 15 words.

## Review Focus

- A slow network with an HTTPS remote: the hook stops the fetch in 6 seconds and shows a warning.
- A fetch that fails for any reason: the warning includes the first line of the git error.
- A pull adds or changes a skill: the same session loads it.
- `install.sh --manual` after an earlier auto-update setup: the hook goes away, and the `Stop` hook stays.
- A folder URL with a trailing slash, or a skill name that is already in use: `add-skill.sh` handles it.

---

### Task 1: Sync hook fixes from the first review

**Files:**
- Modify: `bin/link.sh`, `bin/sync.sh`, `tests/test.sh`

**Interfaces:**
- Changes: `bin/link.sh` prints `linked <name>` and `removed <name>` for each change, and `skip <name>: <reason>` for each skip.
- Changes: `bin/sync.sh` prints one JSON object or nothing. The object has `systemMessage` when a warning exists. It has `hookSpecificOutput` `{"hookEventName": "SessionStart", "reloadSkills": true}` when `HEAD` or a link changed.

- [ ] **Step 1: Add the failing tests**

- Remove the tests that guard no real harm: `test_install_links_skills`, `test_install_no_settings`, `test_install_ignores_synced`, `test_sync_offline`, and `test_sync_quiet`.
- `test_sync_pulls_new_skill`: also check that the output parses as JSON with `hookSpecificOutput.reloadSkills == true`.
- `test_sync_fetch_time_limit`: an `origin` of `ext::sh -c "sleep 30"` (with `protocol.ext.allow always` in the clone) finishes in less than 9 seconds with a `systemMessage`.

- [ ] **Step 2: Run `bash tests/test.sh` and see the two FAIL lines**

- [ ] **Step 3: Change `bin/link.sh` and `bin/sync.sh`**

The fetch runs in the background with stderr to a temporary file. The script checks it each 0.1 seconds and kills it after 6 seconds. A failed fetch gives a warning with the first line of its stderr. A public repo needs no login, so the hook has no login message. `sync.sh` reads `link.sh` output by prefix.

- [ ] **Step 4: Run `bash tests/test.sh` and see all PASS lines**

- [ ] **Step 5: Commit** `Fix the sync hook time limit, error message, and skill reload`

### Task 2: Auto-update choice in `install.sh`

**Files:**
- Modify: `install.sh`, `tests/test.sh`

**Interfaces:**
- Produces: `install.sh [--auto-update | --manual]`. With no flag and a terminal, it asks `Turn on auto-update? [Y/n]`. With no flag and no terminal, it selects auto-update. `--manual` removes each hook entry whose command is this repo's `bin/sync.sh`, and removes a `SessionStart` group that becomes empty.

- [ ] **Step 1: Add the failing tests**

- `test_install_manual_removes_hook`: `install.sh --auto-update`, then `install.sh --manual`, gives `hook_count == 0`, and the `Stop` hook stays.

- [ ] **Step 2: Run the tests and see the new FAIL line**
- [ ] **Step 3: Change `install.sh`**
- [ ] **Step 4: Run the tests and see all PASS lines**
- [ ] **Step 5: Commit** `Let each person select auto-update in install.sh`

### Task 3: `bin/add-skill.sh`

**Files:**
- Create: `bin/add-skill.sh`
- Modify: `tests/test.sh`

**Interfaces:**
- Produces: `bin/add-skill.sh <url> [name]`. The URL form is `https://github.com/<owner>/<repo>/tree/<ref>/<path>`. The default name is the last part of `<path>`. The environment variable `ABILITIES_GIT_BASE` (default `https://github.com`) sets the clone base, so the tests can use a local repo.
- Produces: `sources.json`, a JSON list sorted by `name`. Each entry is `{"name", "repo": "<owner>/<repo>", "path", "ref", "commit", "license"}`. `license` is the repo path of the copied license, or `null`.
- Produces: `licenses/<owner>-<repo>.txt`, copied from the first `LICENSE`, `LICENSE.md`, or `LICENSE.txt` in the folders from `<path>` up to the repo root.

- [ ] **Step 1: Add the failing tests**

- `test_add_skill_copies_skill`: a source folder with `SKILL.md`, `EXTRA.md`, and `agents/a.md`, and a `LICENSE` in a parent folder. After the add, all three files are in `skills/<name>/`, the skill has a link, `licenses/<owner>-<repo>.txt` exists, and `sources.json` has the entry with the source commit SHA.
- `test_add_skill_name_in_use`: a second add with the same name exits non-zero and leaves a changed `SKILL.md` as it is.

- [ ] **Step 2: Run the tests and see the two FAIL lines**
- [ ] **Step 3: Write `bin/add-skill.sh`**

It does a shallow sparse clone (`--depth 1 --filter=blob:none --sparse -b <ref>`) into a temporary folder and runs `git sparse-checkout set <path>`. Cone mode also gives the files of each parent folder, which includes the license. The script does not commit.

- [ ] **Step 4: Run the tests and see all PASS lines**
- [ ] **Step 5: Commit** `Add add-skill.sh to copy a skill from a GitHub folder`

### Task 4: First skills, README, and the public switch

**Files:**
- Create: `skills/unslop/`, `skills/grilling/`, `skills/grill-me/`, `skills/teach/`, `skills/wayfinder/`, `skills/prototype/`, `sources.json`, `licenses/`
- Modify: `README.md`

- [ ] **Step 1: Run `bin/add-skill.sh` for the six URLs in the Global Constraints**

Expected: six folders, six `sources.json` entries, and two license files.

- [ ] **Step 2: Read each copied file before the commit**

The repo is public, and Claude follows these files. Look for instructions that run commands or send data.

- [ ] **Step 3: Rewrite `README.md` for any person**

Sections: what the repo is, setup (`git clone https://github.com/markkyaw/abilities ~/git/abilities`, then `install.sh` and the choice), manual update, add a skill (personal or copied), how the sync works, the warning table, and a credits table from `sources.json` with links to the licenses.

- [ ] **Step 4: Run `bash tests/test.sh`, then commit and push**

- [ ] **Step 5: Make the repo public**

```bash
gh repo edit markkyaw/abilities --visibility public --accept-visibility-change-consequences
```

- [ ] **Step 6: Run `./install.sh --auto-update` on this Mac and check in Claude Code**

Expected: `~/.claude/skills/` has six links, and `claude -p` names the `grill-me` skill.
