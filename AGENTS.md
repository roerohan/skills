# Agent Notes

## Repo Shape

- This repo contains standalone agent skills.
- Each top-level directory is one skill and should contain a `SKILL.md` file.
- Supporting files should live inside the relevant skill folder, commonly under `references/` or `scripts/`.

## Editing Rules

- Keep changes small and specific.
- Do not reorganize skills into category folders unless explicitly requested.
- Update the top-level `README.md` when adding, removing, or renaming a public skill.
- Preserve lowercase kebab-case names for skill folders and skill frontmatter.
- Prefer progressive disclosure: concise `SKILL.md`, detailed references nearby.

## Validation

- When changing a skill, check that `SKILL.md` still has valid frontmatter with `name` and `description`.
- When changing shell scripts, run `bash -n` on the edited scripts.
