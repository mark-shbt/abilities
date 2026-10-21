# abilities

A [Claude Code](https://claude.com/claude-code) plugin marketplace with the skills that I use each day. Most skills are copies from other authors, which I sometimes change.

## Install

Run these commands in a Claude Code session:

```
/plugin marketplace add https://github.com/markkyaw/abilities.git
/plugin install abilities@abilities
```

`abilities@abilities` installs all of the plugins. To install one group only, use its name, for example `/plugin install abilities-writing@abilities`.

To get each new push, turn on auto-update: open `/plugin`, select Marketplaces, select abilities, and select Enable auto-update. Claude Code then downloads updates in the background. A running session shows `Run /reload-plugins to apply`, and the next session loads them.

## Plugins

A skill's command is `/<plugin>:<skill>`, for example `/abilities-writing:unslop`. The short form, such as `/unslop`, also works when no other command has that name. "Claude starts it" means that Claude uses the skill by itself when the task matches.

| Plugin | Skill | Use | Source |
| --- | --- | --- | --- |
| `abilities-planning` | `domain-modeling` | Claude starts it, or `/abilities-planning:domain-modeling` | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/engineering/domain-modeling) |
| `abilities-planning` | `grill-me` | `/abilities-planning:grill-me` | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/productivity/grill-me) |
| `abilities-planning` | `grilling` | Claude starts it, or `/abilities-planning:grilling` | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/productivity/grilling) |
| `abilities-planning` | `prototype` | Claude starts it, or `/abilities-planning:prototype` | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/engineering/prototype) |
| `abilities-planning` | `research` | Claude starts it, or `/abilities-planning:research` | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/engineering/research) |
| `abilities-planning` | `teach` | `/abilities-planning:teach` | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/productivity/teach) |
| `abilities-planning` | `wayfinder` | `/abilities-planning:wayfinder` | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/engineering/wayfinder) |
| `abilities-writing` | `unslop` | Claude starts it, or `/abilities-writing:unslop` | [cursor/plugins (pstack)](https://github.com/cursor/plugins/tree/main/pstack/skills/unslop) |
| `abilities-writing` | `wait-what` | `/abilities-writing:wait-what` | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/productivity/wait-what) |
| `abilities-writing` | `writing-for-agents` | Claude starts it, or `/abilities-writing:writing-for-agents` | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/productivity/writing-for-agents) |
| `abilities-debugging` | `diagnosing-bugs` | Claude starts it, or `/abilities-debugging:diagnosing-bugs` | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/engineering/diagnosing-bugs) |
| `abilities-principles` | `principle-attack-the-premise` | Claude starts it, or `/abilities-principles:principle-attack-the-premise` | [cursor/plugins (pstack)](https://github.com/cursor/plugins/tree/main/pstack/skills/principle-attack-the-premise) |
| `abilities-principles` | `principle-build-the-lever` | Claude starts it, or `/abilities-principles:principle-build-the-lever` | [cursor/plugins (pstack)](https://github.com/cursor/plugins/tree/main/pstack/skills/principle-build-the-lever) |
| `abilities-principles` | `principle-fix-root-causes` | Claude starts it, or `/abilities-principles:principle-fix-root-causes` | [cursor/plugins (pstack)](https://github.com/cursor/plugins/tree/main/pstack/skills/principle-fix-root-causes) |
| `abilities-principles` | `principle-laziness-protocol` | Claude starts it, or `/abilities-principles:principle-laziness-protocol` | [cursor/plugins (pstack)](https://github.com/cursor/plugins/tree/main/pstack/skills/principle-laziness-protocol) |
| `abilities-principles` | `principle-redesign-from-first-principles` | Claude starts it, or `/abilities-principles:principle-redesign-from-first-principles` | [cursor/plugins (pstack)](https://github.com/cursor/plugins/tree/main/pstack/skills/principle-redesign-from-first-principles) |
| `abilities-principles` | `principle-subtract-before-you-add` | Claude starts it, or `/abilities-principles:principle-subtract-before-you-add` | [cursor/plugins (pstack)](https://github.com/cursor/plugins/tree/main/pstack/skills/principle-subtract-before-you-add) |
| `abilities-principles` | `principle-test-behavior-not-implementation` | Claude starts it, or `/abilities-principles:principle-test-behavior-not-implementation` | [cursor/plugins (pstack)](https://github.com/cursor/plugins/tree/main/pstack/skills/principle-test-behavior-not-implementation) |
| `abilities-sessions` | `handoff` | `/abilities-sessions:handoff` | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/productivity/handoff) |
| `abilities-sessions` | `retro` | `/abilities-sessions:retro` | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/engineering/retro) |

`abilities-debugging` also installs `abilities-principles`, which holds the debugging principles. `abilities-sessions` also installs `abilities-writing`, because `retro` calls `writing-for-agents`.

## Move from the old setup

The old setup used `install.sh` and a session-start hook. After the hook pulls this version, the next session removes the hook and the old links, and shows the install commands above. You can then delete the old clone.

## Add a skill (for the repo owner)

To copy a skill folder from GitHub into a plugin, run this command:

```sh
bin/add-skill.sh abilities-planning https://github.com/mattpocock/skills/tree/main/skills/engineering/tdd
```

The script copies the folder to `plugins/<plugin>/skills/<name>/`, copies the source license to `plugins/<plugin>/licenses/`, and records the source in `sources.json`. Read the files, then commit and push.

To make a new plugin, add `plugins/<plugin>/.claude-plugin/plugin.json`, add an entry to `.claude-plugin/marketplace.json`, and add the plugin to the dependencies of `plugins/abilities`. Then run `claude plugin validate .`.

Run the tests with `bash tests/test.sh`.

## Licenses

Each copied skill keeps the license of its source. Each plugin holds the license texts for its skills in its `licenses/` folder.
