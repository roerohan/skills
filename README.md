# Skills For Practical Agents

Reusable agent skills I use to make coding agents more useful, less vague, and less likely to sprint confidently into a wall.

These skills are small, composable workflows for OpenCode and other `SKILL.md`-compatible agents. They cover planning, frontend design, Cloudflare work, codebase exploration, repository walkthroughs, Jira automation, tmux-managed servers, and skill authoring.

The repo is intentionally boring: each skill lives in its own folder at the repository root, with a `SKILL.md` file and any supporting scripts or references next to it.

## Quickstart

Point OpenCode at this repo by adding it to your `opencode.json`:

```json
{
  "skills": {
    "paths": ["~/path/to/skills"]
  }
}
```

OpenCode scans custom skill paths for `**/SKILL.md`, so top-level folders like `tmux/SKILL.md` and `spec-planner/SKILL.md` are picked up automatically.

If you need to refresh a runtime copy manually:

```bash
cp -R ~/path/to/skills/* ~/.config/opencode/skills/
```

Do not author new skills there. Author them in this repo, then sync or configure OpenCode to load this repo directly.

## Why These Skills Exist

Agents are powerful, but they fail in familiar ways:

- They start building before understanding the problem.
- They produce generic plans that sound good and survive zero contact with the codebase.
- They run long-lived processes inline and turn the terminal into soup.
- They miss project context, naming conventions, and architectural pressure points.
- They need a repeatable way to use specialized references without bloating every prompt.

These skills make those failure modes explicit and give the agent better rails.

## Skills

### Planning And Product Thinking

- **[grill-me](./grill-me/SKILL.md)** — Interview the user relentlessly about a plan or design until the decision tree is resolved.
- **[spec-planner](./spec-planner/SKILL.md)** — Develop implementation-ready specs through skeptical questioning, discovery, drafting, and refinement.
- **[repo-walkthrough](./repo-walkthrough/SKILL.md)** — Explain how a repository works at a calibrated level, from novice overview to detailed architecture tour.

### Engineering Workflow

- **[tmux](./tmux/SKILL.md)** — Manage dev servers, watchers, logs, and other long-running commands in tmux panes.
- **[using-git-worktrees](./using-git-worktrees/SKILL.md)** — Create isolated git worktrees for feature work without trampling the current workspace.
- **[improve-codebase-architecture](./improve-codebase-architecture/SKILL.md)** — Find refactoring opportunities that deepen modules and improve testability and agent navigability.
- **[index-knowledge](./index-knowledge/SKILL.md)** — Generate hierarchical `AGENTS.md` knowledge files for a codebase.

### Platform And Tooling

- **[cloudflare](./cloudflare/SKILL.md)** — Work across Cloudflare Workers, Pages, KV, D1, R2, Durable Objects, Workers AI, Vectorize, networking, security, and IaC.
- **[jira-tool](./jira-tool/SKILL.md)** — Create, update, transition, and manage Jira tickets through the bundled CLI workflow.
- **[frontend-design](./frontend-design/SKILL.md)** — Apply React-oriented UI/UX guidance for component structure, layout, accessibility, and interaction design.

### Agent And Skill Infrastructure

- **[build-skill](./build-skill/SKILL.md)** — Create, review, and validate effective skills with the expected structure and progressive disclosure patterns.
- **[install-skill](./install-skill/SKILL.md)** — Install agent skills from GitHub repositories using `gh`.
- **[librarian](./librarian/SKILL.md)** — Research library internals, code patterns, and architecture across GitHub, npm, PyPI, and crates repositories.

## Skill Structure

Each skill should look like this:

```text
skill-name/
  SKILL.md
  references/
  scripts/
```

Only `SKILL.md` is required. Put large references and executable helpers next to the skill instead of bloating the main instructions.

Every `SKILL.md` should include frontmatter:

```markdown
---
name: skill-name
description: Use this when the agent should do a specific thing.
---
```

Skill names should be lowercase kebab-case.

## License

MIT. Use these, change them, delete the spicy bits, make them yours.
