---
name: build-skill
description: Create effective skills for OpenCode agents. Load FIRST before writing any SKILL.md. Provides required format, naming conventions, progressive disclosure patterns, and validation. Use when building, reviewing, or debugging skills.
---

# Building Skills

Skills extend agent capabilities with specialized knowledge, workflows, and tools.

## Quick Start

Minimal viable skill in 30 seconds:

```bash
mkdir my-skill && cat > my-skill/SKILL.md << 'EOF'
---
name: my-skill
description: Does X when Y happens. Use for Z tasks.
---

# My Skill

Instructions go here.
EOF
```

Place new skills in this skills repository by default. OpenCode should load this repo through `opencode.json` `skills.paths`.

## Skill Type Decision Tree

```
What are you building?
├─ Instructions only → Simple skill (SKILL.md only)
│   Example: code-review guidelines, commit message format
│
├─ Domain knowledge → Reference-heavy skill (+ references/)
│   Example: API docs, database schemas, company policies
│
├─ Repeatable automation → Script-heavy skill (+ scripts/)
│   Example: PDF processing, data validation, file conversion
│
├─ Complex multi-step workflow → Multi-file skill (all directories)
│   Example: release process, deployment pipeline
│
└─ Large platform → Progressive skill 
    Example: AWS, GCP, Cloudflare (60+ products)
```

## When to Create a Skill

Create a skill when:
- Same instructions repeated across conversations
- Domain knowledge model lacks (schemas, internal APIs, company policies)
- Workflow requires 3+ steps with specific order
- Code rewritten repeatedly for same task
- Team needs shared procedural knowledge

## When NOT to Create a Skill

| Scenario | Do Instead |
|----------|------------|
| Single-use instructions | AGENTS.md or inline in conversation |
| Model already knows domain | Don't add redundant context |
| < 3 steps, no reuse | Inline instructions |
| Highly variable workflow | Higher-freedom guidelines |
| Just want to store files | Use regular directories |

## Reading Order

| Task | Files to Read |
|------|---------------|
| New skill from scratch | anatomy.md → frontmatter.md |
| Optimize existing skill | progressive-disclosure.md |
| Add scripts/resources | bundled-resources.md |
| Find skill pattern | patterns.md |
| Debug/fix skill | gotchas.md |

## In This Reference

| File | Purpose |
|------|---------|
| [anatomy.md](./references/anatomy.md) | Skill directory structures |
| [frontmatter.md](./references/frontmatter.md) | YAML spec, naming, validation |
| [progressive-disclosure.md](./references/progressive-disclosure.md) | Token-efficient design |
| [bundled-resources.md](./references/bundled-resources.md) | scripts/, references/, assets/ |
| [patterns.md](./references/patterns.md) | Real-world skill patterns |
| [gotchas.md](./references/gotchas.md) | Common mistakes + fixes |

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/init_skill.sh` | Scaffold new skill |
| `scripts/validate_skill.sh` | Validate skill structure |
| `scripts/package_skill.sh` | Create distributable zip |

## Pre-Flight Checklist

Before using a skill:

- [ ] SKILL.md starts with `---` (line 1, no blank lines)
- [ ] `name:` field present, matches directory name
- [ ] `description:` includes what + when to use
- [ ] Closing `---` after frontmatter
- [ ] SKILL.md under 200 lines (use references/ for more)
- [ ] All internal links resolve

Run: `./scripts/validate_skill.sh ./my-skill`

## Skill Locations

| Priority | Location |
|----------|----------|
| 1 | `~/path/to/skills/<name>/` (source of truth for this repo) |
| 2 | `.opencode/skills/<name>/` (project-local OpenCode fallback) |
| 3 | `~/.config/opencode/skills/<name>/` (global OpenCode fallback) |
| 4 | `.claude/skills/<name>/` (Claude-compat) |

OpenCode should be configured with `skills.paths` pointing at this repo. Avoid writing generated skills directly into `~/.config/opencode/skills`; that makes the runtime copy the source of truth, which is backwards. A tiny tragedy, but still a tragedy.

## See Also

- [Cloudflare Skill](https://github.com/dmmulroy/cloudflare-skill) - Reference implementation
