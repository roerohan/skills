---
name: diff-walkthrough
description: Produce a guided walkthrough of a code diff, pull request, merge request, commit range, or staged changes. Use when the user asks to explain, narrate, summarize, review, or walk through a diff. Supports configurable depth and output formats, defaults to HTML, and uses Plannotator when available.
---

# Diff Walkthrough

Generate a grounded, reader-friendly walkthrough of a code change. Explain the change in the order a human should read it, not in filesystem or diff order.

Use the references for detailed rules when the diff is non-trivial:

- [`references/file-roles.md`](references/file-roles.md) for classifying changed files
- [`references/reading-order.md`](references/reading-order.md) for motif-based ordering
- [`references/annotations.md`](references/annotations.md) for inline callouts and concerns
- [`references/output-formats.md`](references/output-formats.md) for HTML, Markdown, terminal, and JSON output contracts

## Invocation

Trigger on requests like:

| User says | Behavior |
|-----------|----------|
| "walk me through this diff" | Explain the current unstaged or provided diff |
| "explain my staged changes" | Use `git diff --staged` |
| "summarize this PR/MR" | Fetch the hosted review with available tools, then explain it |
| "walk through HEAD~3..HEAD" | Use the requested commit range |
| "review this diff" | Include concerns and risks, not just narration |

If the source is ambiguous, prefer the safest local source in this order: explicitly provided URL/range, staged diff, unstaged diff. Ask one short question only if multiple real sources exist and choosing one would materially change the answer.

## Options

Parse options from the user's prompt. If omitted, use `depth=standard`, `format=html`, `concerns=off`, and `coverage=collapsed`.

| Option | Values | Meaning |
|--------|--------|---------|
| `depth` | `skim`, `standard`, `deep`, `teaching` | Controls detail and vocabulary |
| `format` | `html`, `markdown`, `terminal`, `json` | Controls output format |
| `concerns` | `off`, `on` | Adds review-style risks only when requested or implied by "review" |
| `coverage` | `collapsed`, `full` | Collapses noisy files by default; shows everything in full mode |

Depth behavior:

| Depth | Use When | Output |
|-------|----------|--------|
| `skim` | "quick", "brief", "tldr" | Intent, impact, reading order, major files only |
| `standard` | Default | Narrative per meaningful file/group with representative hunks |
| `deep` | "deep", "thorough", "detailed" | Cross-file relationships, edge cases, tests, migrations, risks |
| `teaching` | "novice", "teach me", "explain simply" | Plain language, diagrams, definitions, why each layer matters |

Format behavior:

| Format | Output |
|--------|--------|
| `html` | Write or serve a standalone walkthrough artifact and return how to view it |
| `markdown` | Return or write Markdown, using Mermaid diagrams when useful |
| `terminal` | Return a concise plain-text walkthrough with ASCII diagrams/tables |
| `json` | Return structured data for another tool to render |

If the user asks for a path, write there. Otherwise write generated walkthrough artifacts under `/tmp` using `mktemp`; do not place default generated walkthrough files in the repository workspace.

## Source Fetching

Use the most specific available tool for the source:

1. Local git: use `git diff`, `git diff --staged`, `git show`, or `git diff <range>`.
2. Hosted review URL: use the matching MCP first when available; only fall back to the matching CLI such as `gh` or `glab` when no suitable MCP is available, then use a local clone if present.
3. Pasted diff: parse the provided unified diff directly.
4. Patch files: read the file and treat it as the source diff.

Collect enough context to explain the change accurately:

- Unified diff per changed file
- File list and line stats
- Commit messages when available
- Hosted review title, description, author, and target/source refs when available
- Nearby source context only when the diff alone is insufficient

Do not assume vendor-specific infrastructure. This skill must work without hosted-review integrations or Plannotator.

## Plannotator

Before producing HTML, check whether Plannotator is available with a lightweight probe such as `command -v plannotator` and, if needed, inspect its help output. Also check obvious repo scripts only if the repository already references Plannotator.

Use Plannotator when all are true:

- The requested format is `html`.
- Plannotator is installed or clearly available through the repo tooling.
- Its interface can render the prepared walkthrough without guessing unsupported flags.

When Plannotator is available and suitable, write the prepared walkthrough as Markdown under `/tmp` using `mktemp`, then open that Markdown file with `plannotator annotate <file.md> --gate` when the installed help shows `--gate` is supported. Return the Markdown path and the Plannotator command used.

If Plannotator returns reviewer comments from the annotation gate, handle them based on the source. For local sources that can be safely edited, treat comments as user feedback on the current changes: inspect the referenced code or docs, make the requested fixes when they are safe and clear, run the smallest relevant validation, then generate a new walkthrough artifact under `/tmp` and open it with Plannotator again. For remote reviews or other sources the agent cannot safely modify, do not attempt fixes; instead respond with an analysis of whether each comment is valid, grounded, in scope for the review, and what change would address it. If the feedback is ambiguous, destructive, or outside the requested diff, ask one short clarifying question before editing or recommending action. Continue the local-fix loop until the gate is approved, comments are exhausted, or the user stops the flow.

If Plannotator is missing, unsuitable, or its interface is unclear, generate a standalone HTML file under `/tmp` using `mktemp`, then open or serve it with a lightweight local viewer such as `python3 -m http.server <port> --directory <dir>`. Return the HTML path, server URL, and any command needed to stop the server. Do not make Plannotator a hard dependency.

Mention in the final response whether Plannotator was used or whether the direct HTML fallback was used.

## Workflow

### 1. Read The Whole Change

First identify the motif before narrating files:

- What is the one-sentence purpose of the change?
- Is it a feature, bugfix, refactor, revert, migration, dependency update, or mechanical change?
- Which files are the conceptual foundation, core behavior, wiring, UI, tests, docs, or noise?
- What has to be understood before the rest makes sense?

Do not summarize each file independently until you understand the cross-file story.

### 2. Classify Files

Classify each file as `foundation`, `core`, `wiring`, `ui`, `test`, `docs`, or `noise`; classify its change as `new`, `mod`, `del`, or `ren`. Collapse `noise` by default. In `coverage=full`, include every file but still label noisy files clearly. For detailed rules, follow [`references/file-roles.md`](references/file-roles.md).

### 3. Choose Reading Order

Use this default order unless the motif calls for an override: foundation, core behavior, wiring and integration, UI, tests, docs, then noise.

Overrides:

- Bugfix: start with the failing behavior or fix, then proof/tests, then supporting context.
- Revert: explain what is being backed out and why; avoid over-narrating restored code.
- Mechanical change: group files by repeated pattern and show one representative example.
- Migration: start with the old-to-new model, then compatibility or data handling, then call sites.

For mixed or mechanical diffs, follow [`references/reading-order.md`](references/reading-order.md).

### 4. Explain With Diagrams

Prefer diagrams or charts when they clarify relationships. Do not add decorative diagrams that repeat prose.

Useful diagram types:

- Reading-order map: foundation -> core -> wiring -> tests
- Request/data flow: input -> transformation -> storage/output
- Review feedback loop: walkthrough -> Plannotator comments -> fixes -> refreshed walkthrough
- Code ownership or responsibility flow: caller -> adapter -> core logic -> output
- Before/after table for API or behavior changes
- Risk matrix when `concerns=on`
- File-role chart for large diffs

Prefer flow diagrams when they reveal sequence, responsibility, or feedback loops that prose would force the reader to reconstruct. Avoid decorative diagrams that restate the same bullet list. For HTML, use simple inline SVG, CSS boxes, or tables so the output opens without a build step. For Markdown, use Mermaid when appropriate and include a plain table fallback if the diagram is essential. For terminal output, use ASCII arrows and compact tables.

### 5. Write The Walkthrough

For each meaningful file or group:

- State what changed concretely, naming symbols, functions, endpoints, commands, or types from the diff.
- Explain how it relates to earlier and later files in the reading order.
- Include representative hunks or short code snippets when they teach the change better than prose, especially for new contracts, changed control flow, boundary validation, API shape changes, or subtle removals. Keep snippets small and omit unrelated context.
- Call out subtle behavior changes separately from obvious edits.
- In `teaching` depth, define jargon before using it heavily.
- In `deep` depth, cover edge cases, compatibility, tests, and operational impact.

When `concerns=on`, add a clearly separate concerns section. Only include concerns grounded in the diff or inspected context. Do not invent risks.

For line-level annotations, use the categories and anti-hallucination rules in [`references/annotations.md`](references/annotations.md).

### 6. Produce The Chosen Format

HTML should include:

- Title, source metadata, and generated timestamp
- Executive summary
- File-role chart or reading-order diagram when useful
- Guided walkthrough in reading order
- Representative diff hunks or code snippets
- Tests and confidence section
- Concerns section only when enabled

Markdown should mirror the same structure. Terminal output should be shorter and avoid large hunks. JSON should include at least `summary`, `source`, `options`, `files`, `readingOrder`, `diagrams`, `sections`, `tests`, and `concerns`.

Use [`references/output-formats.md`](references/output-formats.md) as the output contract for larger walkthroughs or when another tool will consume the result.

## Rules

- Ground every claim in the diff, commit metadata, or inspected source context.
- Prefer explanation over review unless the user asks for review or `concerns=on`.
- Do not paste entire large diffs; choose representative hunks.
- Do not fabricate line numbers, file paths, symbols, or intent.
- Keep generated files local to the workspace or requested output path.
- If verification is feasible, run the smallest relevant check for changed generated assets or scripts.
- If the diff is too large to fully process, say what was covered and what was collapsed.
