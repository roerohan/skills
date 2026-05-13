---
name: install-skill
description: Install agent skills from GitHub repositories using gh CLI. Use when user asks to install a skill, add a skill, or set up a skill from a GitHub repo. Triggers on "install skill", "add skill", "gh skill install".
compatibility: Requires gh CLI (GitHub CLI) installed and authenticated.
---

# Install Skill

Install agent skills from GitHub repositories using `gh skill install`.

## Prerequisites

Before running any install, verify `gh` CLI is available:

```bash
command -v gh >/dev/null 2>&1 || { echo "Error: gh CLI not found. Install from https://cli.github.com" >&2; exit 1; }
```

If `gh` is not installed, stop and inform the user:
- Install from https://cli.github.com
- Then authenticate with `gh auth login`

## Defaults

| Setting | Default | Override |
|---------|---------|----------|
| Agent | `opencode` | User specifies `--agent <name>` |
| Scope | `user` | User says "project" or "directory" |
| Directory | (none) | User provides explicit path via `--dir` |

**Always use `--agent opencode --scope user` unless the user explicitly requests otherwise.**

## Workflow

### 1. Parse the User Request

Extract from the user's message:
- **Repository**: `OWNER/REPO` format (required)
- **Skill name**: specific skill within the repo (optional)
- **Version**: `@version` or pin (optional)
- **Agent override**: only if user explicitly names a different agent
- **Scope override**: only if user explicitly says "project" or "directory"
- **Directory override**: only if user provides a specific path

### 2. Validate gh CLI

Run `scripts/install.sh` or manually verify:

```bash
command -v gh >/dev/null 2>&1
gh auth status 2>/dev/null
```

If either fails, stop and inform the user.

### 3. Build the Command

Base command:

```bash
gh skill install <OWNER/REPO> [<skill[@version]>] --agent opencode --scope user
```

Apply overrides:
- If user says "install to project" or "project scope": `--scope project`
- If user gives a directory path: `--dir <path>` (replaces `--agent` and `--scope`)
- If user names a different agent: `--agent <agent-name>`
- If user wants to force overwrite: add `--force`
- If user specifies a version/pin: append `@version` or use `--pin <ref>`

### 4. Run the Install

Execute the built command via `scripts/install.sh` or directly:

```bash
gh skill install <repo> [skill] --agent opencode --scope user
```

### 5. Verify

After install, confirm:
- Command exited successfully (exit code 0)
- Report the installed skill name and location to the user

## Command Reference

```
gh skill install <repository> [<skill[@version]>] [flags]
```

| Flag | Purpose |
|------|---------|
| `--agent <string>` | Target agent (default: opencode for this skill) |
| `--scope <string>` | `project` or `user` (default: user) |
| `--dir <string>` | Custom directory (overrides agent and scope) |
| `--force` | Overwrite existing skills without prompting |
| `--pin <string>` | Pin to a specific git tag or commit SHA |
| `--from-local` | Install from a local directory instead of a repo |
| `--allow-hidden-dirs` | Include skills in hidden directories |

## Supported Agents

opencode, github-copilot, claude-code, cursor, codex, gemini-cli, antigravity,
amp, goose, junie, windsurf, cline, roo, and many more.

Full list: `gh skill install --help`

## Examples

```bash
# Install a skill for opencode globally (default)
gh skill install owner/repo skill-name --agent opencode --scope user

# Install a specific version
gh skill install owner/repo skill-name@v1.0.0 --agent opencode --scope user

# Install to project scope (when user asks)
gh skill install owner/repo skill-name --agent opencode --scope project

# Install to a custom directory (when user provides path)
gh skill install owner/repo skill-name --dir /path/to/skills

# Install for a different agent (when user specifies)
gh skill install owner/repo skill-name --agent claude-code --scope user

# Force overwrite
gh skill install owner/repo skill-name --agent opencode --scope user --force

# Install from local directory
gh skill install ./local-repo skill-name --from-local --agent opencode --scope user
```

## Error Handling

| Error | Action |
|-------|--------|
| `gh` not found | Tell user to install from https://cli.github.com |
| Not authenticated | Tell user to run `gh auth login` |
| Repo not found | Verify OWNER/REPO format and repo exists |
| Skill not found in repo | List available skills with `gh skill install <repo>` interactively, or check repo structure |
| Already installed | Ask user if they want to `--force` overwrite |

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/install.sh` | Validate prerequisites and run gh skill install |
