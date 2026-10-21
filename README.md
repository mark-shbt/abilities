# abilities

A [Claude Code](https://claude.com/claude-code) plugin marketplace with the skills that I use each day. Most skills are copies from other authors, which I sometimes change.

## Install

Run these commands in a Claude Code session:

```
/plugin marketplace add https://github.com/markkyaw/abilities.git
/plugin install abilities@abilities
```

To get each new push, turn on auto-update: open `/plugin`, select Marketplaces, select abilities, and select Enable auto-update. Claude Code then downloads updates in the background. A running session shows `Run /reload-plugins to apply`, and the next session loads them.

## Skills

A skill's command is `/abilities:<skill>`, for example `/abilities:unslop`. The short form, such as `/unslop`, also works when no other command has that name. "Claude starts it" means that Claude uses the skill by itself when the task matches.

| Category | Skill | Use | Source |
| --- | --- | --- | --- |
| planning | `domain-modeling` | Claude starts it, or `/abilities:domain-modeling` | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/engineering/domain-modeling) |
| planning | `grill-me` | `/abilities:grill-me` | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/productivity/grill-me) |
| planning | `grilling` | Claude starts it, or `/abilities:grilling` | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/productivity/grilling) |
| planning | `prototype` | Claude starts it, or `/abilities:prototype` | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/engineering/prototype) |
| planning | `research` | Claude starts it, or `/abilities:research` | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/engineering/research) |
| planning | `teach` | `/abilities:teach` | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/productivity/teach) |
| planning | `wayfinder` | `/abilities:wayfinder` | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/engineering/wayfinder) |
| writing | `unslop` | Claude starts it, or `/abilities:unslop` | [cursor/plugins (pstack)](https://github.com/cursor/plugins/tree/main/pstack/skills/unslop) |
| writing | `wait-what` | `/abilities:wait-what` | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/productivity/wait-what) |
| writing | `writing-for-agents` | Claude starts it, or `/abilities:writing-for-agents` | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/productivity/writing-for-agents) |
| debugging | `diagnosing-bugs` | Claude starts it, or `/abilities:diagnosing-bugs` | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/engineering/diagnosing-bugs) |
| principles | `principle-attack-the-premise` | Claude starts it, or `/abilities:principle-attack-the-premise` | [cursor/plugins (pstack)](https://github.com/cursor/plugins/tree/main/pstack/skills/principle-attack-the-premise) |
| principles | `principle-build-the-lever` | Claude starts it, or `/abilities:principle-build-the-lever` | [cursor/plugins (pstack)](https://github.com/cursor/plugins/tree/main/pstack/skills/principle-build-the-lever) |
| principles | `principle-fix-root-causes` | Claude starts it, or `/abilities:principle-fix-root-causes` | [cursor/plugins (pstack)](https://github.com/cursor/plugins/tree/main/pstack/skills/principle-fix-root-causes) |
| principles | `principle-laziness-protocol` | Claude starts it, or `/abilities:principle-laziness-protocol` | [cursor/plugins (pstack)](https://github.com/cursor/plugins/tree/main/pstack/skills/principle-laziness-protocol) |
| principles | `principle-redesign-from-first-principles` | Claude starts it, or `/abilities:principle-redesign-from-first-principles` | [cursor/plugins (pstack)](https://github.com/cursor/plugins/tree/main/pstack/skills/principle-redesign-from-first-principles) |
| principles | `principle-subtract-before-you-add` | Claude starts it, or `/abilities:principle-subtract-before-you-add` | [cursor/plugins (pstack)](https://github.com/cursor/plugins/tree/main/pstack/skills/principle-subtract-before-you-add) |
| principles | `principle-test-behavior-not-implementation` | Claude starts it, or `/abilities:principle-test-behavior-not-implementation` | [cursor/plugins (pstack)](https://github.com/cursor/plugins/tree/main/pstack/skills/principle-test-behavior-not-implementation) |
| sessions | `handoff` | `/abilities:handoff` | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/productivity/handoff) |
| sessions | `retro` | `/abilities:retro` | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/engineering/retro) |

## Move from the old setup

The old setup used `install.sh` and a session-start hook. After the hook pulls this version, the next session removes the hook and the old links, and shows the install commands above. You can then delete the old clone.

## Add a skill (for the repo owner)

To copy a skill folder from GitHub, give a category and the folder URL:

```sh
bin/add-skill.sh planning https://github.com/mattpocock/skills/tree/main/skills/engineering/tdd
```

The script copies the folder to `plugins/abilities/skills/<name>/`, copies the source license to `plugins/abilities/licenses/`, and records the source and the category in `sources.json`. Read the files, and add the skill to the table above. Then commit and push.

Run the tests with `bash tests/test.sh`.

## Licenses

Each copied skill keeps the license of its source. The license texts are in `plugins/abilities/licenses/`.
