# abilities

Skills for [Claude Code](https://claude.com/claude-code). Some skills are my own. Other skills are copies from other authors, which I sometimes change.

| Skill | Use | Source |
| --- | --- | --- |
| `diagnosing-bugs` | Claude starts it, or `/diagnosing-bugs` | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/engineering/diagnosing-bugs) |
| `domain-modeling` | Claude starts it, or `/domain-modeling` | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/engineering/domain-modeling) |
| `grill-me` | `/grill-me` | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/productivity/grill-me) |
| `grilling` | Claude starts it, or `/grilling` | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/productivity/grilling) |
| `handoff` | `/handoff` | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/productivity/handoff) |
| `principle-attack-the-premise` | Claude starts it, or `/principle-attack-the-premise` | [cursor/plugins (pstack)](https://github.com/cursor/plugins/tree/main/pstack/skills/principle-attack-the-premise) |
| `principle-build-the-lever` | Claude starts it, or `/principle-build-the-lever` | [cursor/plugins (pstack)](https://github.com/cursor/plugins/tree/main/pstack/skills/principle-build-the-lever) |
| `principle-fix-root-causes` | Claude starts it, or `/principle-fix-root-causes` | [cursor/plugins (pstack)](https://github.com/cursor/plugins/tree/main/pstack/skills/principle-fix-root-causes) |
| `principle-laziness-protocol` | Claude starts it, or `/principle-laziness-protocol` | [cursor/plugins (pstack)](https://github.com/cursor/plugins/tree/main/pstack/skills/principle-laziness-protocol) |
| `principle-redesign-from-first-principles` | Claude starts it, or `/principle-redesign-from-first-principles` | [cursor/plugins (pstack)](https://github.com/cursor/plugins/tree/main/pstack/skills/principle-redesign-from-first-principles) |
| `principle-subtract-before-you-add` | Claude starts it, or `/principle-subtract-before-you-add` | [cursor/plugins (pstack)](https://github.com/cursor/plugins/tree/main/pstack/skills/principle-subtract-before-you-add) |
| `principle-test-behavior-not-implementation` | Claude starts it, or `/principle-test-behavior-not-implementation` | [cursor/plugins (pstack)](https://github.com/cursor/plugins/tree/main/pstack/skills/principle-test-behavior-not-implementation) |
| `prototype` | Claude starts it, or `/prototype` | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/engineering/prototype) |
| `research` | Claude starts it, or `/research` | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/engineering/research) |
| `retro` | `/retro` | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/engineering/retro) |
| `teach` | `/teach` | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/productivity/teach) |
| `unslop` | Claude starts it, or `/unslop` | [cursor/plugins (pstack)](https://github.com/cursor/plugins/tree/main/pstack/skills/unslop) |
| `wait-what` | `/wait-what` | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/productivity/wait-what) |
| `wayfinder` | `/wayfinder` | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/engineering/wayfinder) |
| `writing-for-agents` | Claude starts it, or `/writing-for-agents` | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/productivity/writing-for-agents) |

## Set up

You need macOS with `git` and `python3`.

```sh
git clone https://github.com/markkyaw/abilities ~/git/abilities
~/git/abilities/install.sh
```

The script links each skill into `~/.claude/skills/` and asks if you want auto-update. With auto-update on, each Claude Code session start pulls this repo. Use `--auto-update` or `--manual` to skip the question, and run the script again to change your choice.

With auto-update off, run `~/git/abilities/bin/sync.sh` to update.

Before you delete or move the clone, run `install.sh --manual` to remove the hook. Keep one clone on each machine.

## Messages

The update never commits, pushes, or merges. If it cannot update, the session uses your local skills and shows a line that starts with `abilities:`.

| Message | What to do |
| --- | --- |
| `GitHub did not answer in 6 seconds` | Nothing. The next session tries again. |
| `The fetch failed` | Read the git error in the message. |
| `This Mac and GitHub have different commits` | Run `cd ~/git/abilities && git pull --rebase`. |
| `Local changes block the update` | Commit or stash your changes. |
| `skip <name>` | A folder in `~/.claude/skills/` has the same name. Rename one of them. |

## Add a skill

Put your own skill in `skills/<name>/SKILL.md`, then run `bin/link.sh`. To copy a skill folder from GitHub, run this command:

```sh
bin/add-skill.sh https://github.com/mattpocock/skills/tree/main/skills/engineering/tdd
```

The script copies the folder and its license, and records the source in `sources.json`. Read the files, then commit and push. Run the tests with `bash tests/test.sh`.

Each copied skill keeps the license of its source, in [`licenses/`](licenses/).
