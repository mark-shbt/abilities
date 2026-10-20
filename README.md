# abilities

This repo holds a set of skills for [Claude Code](https://claude.com/claude-code). Some skills are my own. Other skills are copies of skills from other authors. I select them, and I sometimes change them.

Each machine keeps a clone of this repo. Claude Code loads the skills in each session, which includes subagents. With auto-update on, each new session gets the newest version of this repo.

## Skills

| Skill | How to use it | Source |
| --- | --- | --- |
| `grill-me` | `/grill-me` | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/productivity/grill-me) |
| `grilling` | Claude uses it when you ask it to grill a plan. | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/productivity/grilling) |
| `prototype` | Claude uses it when you ask for a prototype. | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/engineering/prototype) |
| `teach` | `/teach` | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/productivity/teach) |
| `unslop` | `/unslop` | [cursor/plugins (pstack)](https://github.com/cursor/plugins/tree/main/pstack/skills/unslop) |
| `wayfinder` | `/wayfinder` | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/engineering/wayfinder) |

`sources.json` records the source repo, the folder, and the commit of each copied skill.

## Set up a machine

These steps are for macOS. You need `git` and `python3`, which come with the Xcode command line tools.

1. Clone the repo.

   ```sh
   git clone https://github.com/markkyaw/abilities ~/git/abilities
   ```

2. Run the install script.

   ```sh
   ~/git/abilities/install.sh
   ```

3. Answer the question `Turn on auto-update? [Y/n]`.

The install script makes a symlink in `~/.claude/skills/` for each skill in `skills/`. If you turn on auto-update, the script also adds a `SessionStart` hook to `~/.claude/settings.json`. The script keeps all your other settings.

To set up without the question, use `install.sh --auto-update` or `install.sh --manual`. To change your choice later, run the install script again.

If you already have a folder in `~/.claude/skills/` with the same name as a skill here, the script does not change your folder. It skips that skill and shows a warning.

## Remove or move the clone

Before you delete or move the clone, run this command:

```sh
~/git/abilities/install.sh --manual
```

This removes the hook from `~/.claude/settings.json`. If you delete the clone first, each new session tries to run a script that does not exist. In that case, remove the `SessionStart` entry for `bin/sync.sh` from `~/.claude/settings.json` by hand.

After a move, run `install.sh` from the new folder. Keep only one clone of this repo on each machine.

## Update by hand

With auto-update off, run this command when you want the newest skills:

```sh
~/git/abilities/bin/sync.sh
```

## How auto-update works

Each time a Claude Code session starts, the hook runs `bin/sync.sh`. The script does these steps:

1. It fetches this repo from GitHub. If GitHub does not answer in 6 seconds, the script stops the fetch.
2. It moves your clone forward to the newest commit. It does this only when your clone has no commits that GitHub does not have.
3. It links new skills and removes the links for deleted skills.
4. It tells Claude Code to load the skills again, so the session uses the changes at once.

The script never commits, pushes, merges, or rebases. If a step fails, the session starts with the skills that you already have. Claude Code then shows one line that starts with `abilities:`.

| Message | What to do |
| --- | --- |
| `GitHub did not answer in 6 seconds` | Nothing. The next session tries again. |
| `The fetch failed` | Read the git error in the message. |
| `This Mac and GitHub have different commits` | Run `cd ~/git/abilities && git pull --rebase`. |
| `Local changes block the update` | Commit or stash your changes in `~/git/abilities`. |
| `skip <name>` | A folder in `~/.claude/skills/` has the same name. Rename one of them. |

## Add a skill (for the repo owner)

To add your own skill, make a folder in `skills/` with a `SKILL.md` file. Then run `bin/link.sh`.

To copy a skill from another GitHub repo, give the URL of its folder:

```sh
bin/add-skill.sh https://github.com/mattpocock/skills/tree/main/skills/engineering/tdd
```

The script copies the full folder into `skills/<name>/`. It also copies the license of the source repo into `licenses/` and adds an entry to `sources.json`. To use a different name, give the name as a second argument. The script does not commit, so read the copied files first. Then commit and push.

The script never replaces a skill that is already in `skills/`. To get a newer version from the source, compare the files by hand and copy the changes that you want.

## Tests

```sh
bash tests/test.sh
```

The tests use a temporary home folder and do not change your settings.

## Licenses

Each copied skill keeps the license of its source. The license texts are in [`licenses/`](licenses/).
