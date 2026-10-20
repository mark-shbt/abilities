# abilities

This private repo holds my personal skills for Claude Code. Each Mac keeps a clone of the repo. Claude Code loads the skills on each Mac and in each session, which includes subagents.

## Set up a new Mac

1. Sign in to GitHub with an account that can read this repo.

   ```sh
   gh auth login
   ```

2. Clone the repo to `~/git/abilities`.

   ```sh
   gh repo clone markkyaw/abilities ~/git/abilities
   ```

3. Run the install script.

   ```sh
   ~/git/abilities/install.sh
   ```

The install script does two things:

- It makes a symlink in `~/.claude/skills/` for each skill folder in `skills/`.
- It adds a `SessionStart` hook to `~/.claude/settings.json`. The script keeps all other settings.

You can run the install script again at any time. It does not add a second hook.

## Add a skill

1. Make a folder in `skills/` with a `SKILL.md` file, for example `skills/my-skill/SKILL.md`.
2. Run `~/git/abilities/bin/link.sh`, or start a new Claude Code session.
3. Commit the folder and push it.

When you change a skill, Claude Code uses the change at once. The symlink points to the file in this repo.

## How the sync works

Each time a Claude Code session starts, the hook runs `bin/sync.sh`. The script does these steps:

1. It fetches the repo from GitHub.
2. It does a fast-forward of the local branch when the branch has no local commits that GitHub does not have.
3. It links new skills and removes the links for deleted skills.

The script never commits, pushes, merges, or rebases. You push your changes yourself.

If the script cannot finish a step, the session starts with the local skills. Claude Code then shows one line that starts with `abilities:`.

| Message | What to do |
| --- | --- |
| `Could not reach GitHub` | Nothing. The next session tries again. |
| `This Mac and GitHub have different commits` | Run `cd ~/git/abilities && git pull --rebase`, then push. |
| `Local changes block the update` | Commit or stash your changes in `~/git/abilities`. |
| `skip <name>` | A real folder in `~/.claude/skills/` has the same name. Rename one of them. |

The script does not touch `~/.claude/skills/synced`. Claude.ai manages that folder.

## Tests

```sh
bash tests/test.sh
```

The tests use a temporary home folder and do not change your settings.
