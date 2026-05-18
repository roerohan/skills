---
name: frontload-permissions
description: Identify and request likely OpenCode permissions before starting a task. Use when a task will run commands, start servers, use Docker, edit files, install packages, or otherwise risks repeated permission prompts.
---

# Frontload Permissions

Before starting a task likely to trigger multiple permission prompts, pause briefly and infer the smallest useful set of permissions for the work. Frontload those permissions instead of discovering them one blocked command at a time.

## When To Use

Use this skill when the requested work may involve:

- Running package-manager scripts, tests, linters, formatters, builds, or dev servers.
- Starting or controlling long-running processes through tmux.
- Building, running, composing, inspecting, or stopping Docker containers.
- Editing files after observing runtime behavior.
- Installing dependencies or invoking project-local toolchains.
- Accessing files outside the current workspace.
- Repeating a family of similar shell commands where narrow one-off approvals would be noisy.

Do not use this for read-only code questions, simple file edits with no commands, or one-off low-friction commands.

## Workflow

1. Understand the task well enough to predict command families and edit scope.
2. Inspect existing permission configuration before asking for anything.
3. Compare the needed command families against configured permissions.
4. If only one or two bounded, local, non-mutating commands are likely to prompt, proceed with normal prompts instead of asking for broader permission.
5. Ask for only the missing permissions, grouped by purpose, when repeated prompts are likely.
6. Prefer reusable-but-bounded patterns over exact one-command approvals.
7. Continue normally after the user grants, declines, or narrows permissions.

## Checking Current Permissions

Look for relevant OpenCode config in this order:

- Project config: `opencode.json`, `opencode.jsonc`, `.opencode/opencode.json`, `.opencode/opencode.jsonc`.
- Parent directory configs if the workspace is nested and the file search reveals them.
- Global config: `~/.config/opencode/opencode.json` or `~/.config/opencode/opencode.jsonc` when accessible.
- Agent files that may override permissions: `.opencode/agent/*.md`, `.opencode/agents/*.md`, `~/.config/opencode/agent/*.md`, `~/.config/opencode/agents/*.md`.

When reading permission rules, remember:

- Per-agent permissions can override top-level permissions.
- For object-shaped permission rules, insertion order matters and the last matching rule wins.
- A broad allow followed by a narrower ask or deny may still block the narrowed pattern.
- Do not claim a permission is already available unless you inspected the relevant config or the tool already succeeded without asking.

## Permission Selection

Prefer patterns that cover the expected workflow without granting unrelated authority.

Do not frontload permissions just because a command might prompt. If reads and workspace edits are already covered, and the remaining verification is a singular safe command such as a local validator, shell syntax check, or git inspection, run it normally and let the ordinary prompt appear if needed.

Good patterns:

- `npm run *`, `pnpm *`, `yarn *`, `bun *` for JS project scripts and package-manager actions.
- `node *`, `npx *` only when direct Node or package execution is expected.
- `cargo *`, `go *`, `python *`, `python3 *`, `pytest *`, `uv *`, `poetry *`, `bundle *`, `rake *`, `mvn *`, `gradle *`, `./gradlew *` when those ecosystems are present.
- `docker build *`, `docker run *`, `docker compose *`, `docker ps *`, `docker logs *`, `docker stop *`, `docker rm *` for Docker workflows.
- `tmux *` and known tmux helper scripts when using tmux-managed servers.
- `lsof *` when checking port conflicts.
- `git status`, `git diff *`, `git log *` for inspection; add `git add *` and `git commit *` only if the user explicitly asked for a commit.
- `bash -n *` for shell-script syntax checks.
- `*/scripts/validate_skill.sh *` or similarly scoped local validation scripts when maintaining skills.

Avoid these unless the user explicitly requests them and the risk is justified:

- `*` for bash.
- `sudo *`.
- Destructive filesystem commands such as `rm -rf *`, broad `mv *`, or broad `chmod *`.
- Broad network or deployment commands such as `terraform apply *`, `kubectl delete *`, cloud provider mutation commands, or production deploy scripts.
- Git history rewriting or remote mutation such as `git push --force *`, `git reset --hard *`, or `git checkout -- *`.

## Edit Permissions

If the task requires editing files, check whether `edit` is already allowed for the active agent. If not, ask for edit permission scoped to the workspace or explain that edits may trigger approval prompts.

If the task needs files outside the workspace, identify the exact external paths and request `external_directory` access for those paths only. Prefer precise globs such as `~/projects/example/**` over home-directory-wide access.

## Asking The User

Ask once, using a compact permission preflight. Include:

- The inferred workflow.
- The permission families requested.
- Anything intentionally excluded.
- Whether the current config already appears to cover some of it.

Template:

```markdown
This task will likely need repeated approvals. Current config appears to cover: <covered items>. Missing likely permissions:

- `bash`: `<pattern>`, `<pattern>` for <reason>.
- `edit`: workspace files for <reason>.
- `external_directory`: `<path>` for <reason>.

I am not asking for `<excluded broad/risky permission>`. Approve these, narrow them, or tell me to proceed with prompts as they appear.
```

If the user wants config changes, edit the appropriate OpenCode config minimally and remind them that OpenCode must be restarted before new config permissions apply. If they only approve the current session prompts, do not edit config.

## Examples

### Dev Server Plus Edits

For “run the app and fix the UI bug,” infer likely needs:

- `npm run *` or the detected package manager command.
- `tmux *` plus tmux helper scripts if using tmux for the server.
- `lsof *` for port checks.
- `edit` for workspace files.

Do not ask for `node *` unless the repo actually invokes Node directly outside package scripts.

### Dockerized Program

For “the service runs in Docker, fix the failing endpoint,” infer likely needs:

- `docker build *`.
- `docker run *` or `docker compose *`, based on repository files.
- `docker ps *`, `docker logs *`, and maybe `docker stop *` for observation and cleanup.
- `edit` for `Dockerfile`, compose files, source files, and tests in the workspace.

Do not ask for unrestricted Docker commands if build/run/log/stop covers the task.

### Commit Requested

If the user explicitly asks to commit after the work, add:

- `git status`.
- `git diff *`.
- `git log *`.
- `git add *`.
- `git commit *`.

Do not include `git push *` unless the user explicitly asks to push.

### Validation-Only Maintenance

For “validate these skills and fix invalid frontmatter,” infer likely needs:

- `read`, `glob`, and `grep` for finding `SKILL.md` files and inspecting config.
- `edit` for workspace `SKILL.md` files.
- `*/scripts/validate_skill.sh *` or one equivalent local validator command.
- `git status` and `git diff *` for confirming touched files.

If config already covers reads, edits, and git inspection, do not ask for broad shell access. Run the local validator normally and only ask for a permission if repeated validation commands would otherwise cause repeated prompts.

Do not include package installs, formatters, commits, or `bash *` unless the task explicitly requires them.
