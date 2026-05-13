---
name: repo-walkthrough
description: Walk a user through how a repository works, explaining critical flows at a calibrated simplicity level. Use when user says "walk me through this repo", "explain this repo", "how does this codebase work", or asks to understand a repo. Accepts a simplicity level argument (novice, pro, brief, detailed, etc.).
---

# Repo Walkthrough

Guide the user through a repository's architecture and critical flows, calibrated to their level.

## Invocation

The user may specify a simplicity level. Parse it from their prompt. Examples:

| User says | Level | Behavior |
|-----------|-------|----------|
| "novice", "beginner", "eli5" | Novice | Plain language, no jargon without definition, analogies welcome |
| "intermediate", "familiar" | Intermediate | Assume basic programming literacy, define domain-specific terms |
| "pro", "expert", "senior" | Pro | Concise, use precise terminology, skip fundamentals |
| "brief", "quick", "overview" | Brief | High-level summary only, minimal detail |
| "detailed", "deep", "thorough" | Detailed | Exhaustive coverage of each flow |

If no level is specified, default to **novice**.

The level controls *vocabulary and depth*, not *correctness*. Never simplify to the point of being wrong.

## Workflow

### Phase 1: Reconnaissance

Use the **Task tool with the `explore` agent** (thoroughness: "very thorough") to gather repo context. Ask it to:

1. Map the repo structure: root files, directory layout, config files, entry points
2. Identify the tech stack (languages, frameworks, build tools, package managers)
3. Read key files: README, package.json/Cargo.toml/go.mod/pyproject.toml, main entry points, config
4. Identify the primary domain: what does this software *do* for its users?
5. List the 3-5 most important code paths / critical flows

If the explore agent is not available, fall back to using Glob/Read/Grep directly.

Do NOT dump raw file listings at the user. Synthesize what you find.

### Phase 2: Orientation

Present a concise summary to the user:

- **What this repo is**: one-sentence purpose
- **Tech stack**: languages, frameworks, key dependencies
- **Repo shape**: how the code is organized (e.g., "monorepo with packages/", "standard Go project layout", "single SPA with src/")
- **Key entry points**: where execution begins, where requests arrive, where the CLI dispatches

Adjust detail to the user's level. For novice, explain *why* the structure exists. For pro, just name the conventions.

### Phase 3: Critical Flows

Identify and explain the **critical flows** -- the 3-5 most important paths through the code that define what this software does. Examples:

- How an HTTP request is handled end-to-end
- How data is ingested, transformed, and stored
- How the CLI parses a command and executes it
- How the build pipeline works
- How auth/session management works

For each critical flow:

1. Name the flow clearly
2. Trace the path through the code: entry point -> key functions/modules -> output/side-effect
3. Reference specific files and line ranges (e.g., `src/server.ts:45`)
4. At novice level: use analogies, explain *why* each step exists
5. At pro level: focus on non-obvious design decisions, tradeoffs, and gotchas

Present **one flow at a time**. After each flow, pause and ask the user:

- "Does this make sense?"
- "Want me to go deeper on any part of this?"
- "Ready for the next flow, or want to explore something specific?"

### Phase 4: Check Understanding

After covering the critical flows, ask the user:

- Which parts feel clear vs. fuzzy?
- Is there a specific area they want to focus on (e.g., "how does auth work?", "what happens when I run X?")?
- Whether they want to trace a specific scenario end-to-end

If the user names a focus area, dive into it with the same level-appropriate depth.

### Phase 5: Wrap-Up

Offer a brief recap of what was covered and suggest next steps:

- Files worth reading in detail
- Areas of the codebase that are complex or under-documented
- Good first tasks if the user wants to contribute

## Rules

- **Ground everything in code**: never speculate about behavior you haven't inspected. Read the files.
- **One flow at a time**: do not overwhelm with a wall of text. Pause for interaction.
- **Ask, don't assume understanding**: after each explanation block, check in with the user.
- **Adapt on the fly**: if the user says "too much detail" or "can you simplify?", adjust immediately.
- **Stay focused on critical paths**: skip boilerplate, config minutiae, and generated code unless the user asks about them.
- **Use the Task tool and Explore agent** for broad codebase searches to keep context lean.
