# Output Formats

The walkthrough can be rendered as HTML, Markdown, terminal text, or JSON. Use the same underlying analysis for every format.

## Shared Structure

Every substantial walkthrough should contain:

- Source metadata: repo, branch/range, PR/MR URL, command, author, or pasted-diff note when available
- Options used: `depth`, `format`, `coverage`, `concerns`
- Executive summary
- Reading order
- Diagram or chart when useful
- File/group walkthroughs
- Test and confidence section
- Concerns section only when enabled or requested

## HTML

HTML is the default. Prefer a single standalone file that opens in a browser without a build step.

Include:

- Semantic HTML with inline CSS
- Light/dark friendly colors when practical
- Tables or simple inline SVG diagrams for reading order, responsibility flows, feedback loops, and risk matrices
- Collapsible sections for noisy files and large hunks
- Escaped code and diff snippets

If Plannotator is available and supports the needed render path, use it. Otherwise generate direct HTML.

Direct HTML should avoid external CDN dependencies unless the user asks for richer rendering. A plain `<pre>` diff snippet is acceptable when it is readable.

## Markdown

Markdown should be useful in code review comments, docs, or chat.

Use:

- Tables for file roles and before/after comparisons
- Mermaid diagrams when they clarify sequence, ownership, data flow, or review feedback loops
- Fenced code blocks for representative hunks and short code snippets that make a concrete behavior change easier to understand
- Plain prose fallback when a Mermaid diagram is essential to understanding

## Terminal

Terminal output should be compact.

Use:

- Short sections
- ASCII arrows for flows
- Tables only when they stay narrow
- No long hunks unless the user asked for them

## JSON

Use JSON when another renderer or tool will consume the walkthrough.

Recommended top-level shape:

```json
{
  "source": {},
  "options": {
    "depth": "standard",
    "format": "json",
    "coverage": "collapsed",
    "concerns": false
  },
  "summary": "One paragraph summary.",
  "motif": "feature",
  "stats": { "files": 0, "additions": 0, "deletions": 0 },
  "readingOrder": [],
  "files": [],
  "groups": [],
  "diagrams": [],
  "tests": [],
  "concerns": []
}
```

Recommended file shape:

```json
{
  "id": "f1",
  "path": "src/example.ts",
  "role": "core",
  "changeKind": "mod",
  "stats": { "additions": 10, "deletions": 2 },
  "rationale": "Why this file appears here in the reading order.",
  "narration": "What changed and how it relates to the rest of the diff.",
  "hunks": [],
  "annotations": []
}
```

## Validation Checklist

Before delivering or writing a file:

- Every claim is grounded in the diff or inspected context.
- Reading order numbers are sequential.
- Grouped files contain at least two files; a single noisy file remains a file entry.
- `concern` annotations appear only when concerns are enabled.
- Stats approximately match the source diff.
- HTML escapes code and diff content.
- Markdown fences include language tags when known.
