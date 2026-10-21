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

A skill's command is `/abilities:<skill>`, for example `/abilities:unslop`. The short form, such as `/unslop`, also works when no other command has that name. You can type the command of any skill. An X in "Claude starts it" means that Claude also uses the skill by itself when the task matches. An empty cell means that only you can start it.

### Planning

| Skill | Description | Claude starts it | Source |
| --- | --- | :-: | --- |
| `/abilities:domain-modeling` | Sharpens the project terms and records them in GLOSSARY.md and decision records. | X | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/engineering/domain-modeling) |
| `/abilities:grill-me` | Starts grilling on your plan or design. |  | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/productivity/grill-me) |
| `/abilities:grilling` | Asks you questions in rounds until all design decisions are settled. | X | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/productivity/grilling) |
| `/abilities:prototype` | Builds a throwaway prototype to answer one design question. | X | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/engineering/prototype) |
| `/abilities:research` | Sends a background agent to read primary sources and write cited notes. | X | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/engineering/research) |
| `/abilities:setup-matt-pocock-skills` | Sets where a repo keeps its specs and tickets. Run it once in each repo before `to-spec` and `to-tickets`. |  | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/engineering/setup-matt-pocock-skills) |
| `/abilities:teach` | Teaches you a subject over many sessions, with HTML lessons. |  | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/productivity/teach) |
| `/abilities:to-spec` | Writes a spec from the conversation, for your review before the build. |  | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/engineering/to-spec) |
| `/abilities:to-tickets` | Splits a spec into small tickets and waits for your approval of the list. |  | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/engineering/to-tickets) |
| `/abilities:wayfinder` | Plans work that is too large for one session as a map of decision tickets. |  | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/engineering/wayfinder) |

### Writing

| Skill | Description | Claude starts it | Source |
| --- | --- | :-: | --- |
| `/abilities:unslop` | Removes AI writing patterns from text. | X | [cursor/plugins (pstack)](https://github.com/cursor/plugins/tree/main/pstack/skills/unslop) |
| `/abilities:wait-what` | Says the last reply again in plain STE, with more context. |  | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/productivity/wait-what) |
| `/abilities:writing-for-agents` | Gives rules for writing skills, CLAUDE.md, and AGENTS.md. | X | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/productivity/writing-for-agents) |

### Debugging

| Skill | Description | Claude starts it | Source |
| --- | --- | :-: | --- |
| `/abilities:diagnosing-bugs` | Finds the cause of a hard bug with a fast loop that fails on the bug. | X | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/engineering/diagnosing-bugs) |

### Principles

| Skill | Description | Claude starts it | Source |
| --- | --- | :-: | --- |
| `/abilities:principle-attack-the-premise` | After two failed fixes, tests the belief that the fixes share. | X | [cursor/plugins (pstack)](https://github.com/cursor/plugins/tree/main/pstack/skills/principle-attack-the-premise) |
| `/abilities:principle-build-the-lever` | Writes a script or tool for the work instead of edits by hand. | X | [cursor/plugins (pstack)](https://github.com/cursor/plugins/tree/main/pstack/skills/principle-build-the-lever) |
| `/abilities:principle-fix-root-causes` | Fixes the first wrong step, not the place where the symptom shows. | X | [cursor/plugins (pstack)](https://github.com/cursor/plugins/tree/main/pstack/skills/principle-fix-root-causes) |
| `/abilities:principle-laziness-protocol` | Makes the smallest change, with one source of truth. | X | [cursor/plugins (pstack)](https://github.com/cursor/plugins/tree/main/pstack/skills/principle-laziness-protocol) |
| `/abilities:principle-redesign-from-first-principles` | Changes the design as if the new need was there from the start. | X | [cursor/plugins (pstack)](https://github.com/cursor/plugins/tree/main/pstack/skills/principle-redesign-from-first-principles) |
| `/abilities:principle-subtract-before-you-add` | Removes dead code and extra checks before it adds code. | X | [cursor/plugins (pstack)](https://github.com/cursor/plugins/tree/main/pstack/skills/principle-subtract-before-you-add) |
| `/abilities:principle-test-behavior-not-implementation` | Keeps only tests that fail when the behavior breaks. | X | [cursor/plugins (pstack)](https://github.com/cursor/plugins/tree/main/pstack/skills/principle-test-behavior-not-implementation) |

### Sessions

| Skill | Description | Claude starts it | Source |
| --- | --- | :-: | --- |
| `/abilities:handoff` | Writes a summary of the session for the next session. |  | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/productivity/handoff) |
| `/abilities:retro` | Lists changes to rules and checks after a session. |  | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/engineering/retro) |

## Add a skill (for the repo owner)

To copy a skill folder from GitHub, give a category and the folder URL:

```sh
bin/add-skill.sh planning https://github.com/mattpocock/skills/tree/main/skills/engineering/tdd
```

The script copies the folder to `plugins/abilities/skills/<name>/`, copies the source license to `plugins/abilities/licenses/`, and records the source and the category in `sources.json`. Read the files, and add the skill to its category table above. Then commit and push.

Run the tests with `bash tests/test.sh`.

## Licenses

Each copied skill keeps the license of its source. The license texts are in `plugins/abilities/licenses/`.
