# Skills Repo Context

This repository contains reusable agent skills. A skill is a directory with a `SKILL.md` file and optional supporting references or scripts.

## Language

**Skill**:
A reusable agent capability loaded from `SKILL.md`. It gives the agent specialized instructions, workflows, or references for a recurring task.

**Skill folder**:
The directory containing a skill's `SKILL.md` and any supporting files. In this repo, skill folders live at the repository root.

**Reference**:
Supporting documentation used by a skill. References belong near the skill that consumes them, usually under `references/`.

**Script**:
Executable helper used by a skill. Scripts belong near the skill that invokes them, usually under `scripts/`.

**Progressive disclosure**:
Keeping `SKILL.md` concise and moving detailed, task-specific material into references that the agent reads only when needed.

## Relationships

- A **Skill** lives in one **Skill folder**.
- A **Skill folder** may contain many **References** and **Scripts**.
- The top-level `README.md` indexes stable skills and explains how to load them.

## Conventions

- Keep skill folders at the repository root.
- Use lowercase kebab-case skill names.
- Keep `SKILL.md` focused on when to use the skill and the primary workflow.
- Put bulky details in local references instead of stuffing every token into the main file. The agent already has enough ways to become verbose; no need to hand it a shovel.
