# Annotations

Annotations are optional line-level or section-level callouts. Use them to anchor the walkthrough to precise evidence, not to decorate the output.

## Categories

| Category | Use For | Allowed When |
|----------|---------|--------------|
| `key` | The pivot line: bug fix, contract change, new helper invocation, removed root cause | `standard`, `deep`, or `teaching` depth |
| `subtle` | Easy-to-miss invariant, implication, ordering dependency, or absence of code | `standard`, `deep`, or `teaching` depth |
| `concern` | Concrete falsifiable review risk | Only when `concerns=on` or the user asked for review |

Do not use annotations in `skim` depth.

## Concern Bar

Only emit a `concern` when all are true:

1. The evidence is visible in the diff or inspected context.
2. The concern is concrete and falsifiable.
3. You would mention it in a real human code review.

Do not emit concerns for style preferences, vague performance worries, security speculation, or missing context you did not inspect.

## Anchoring

For HTML or JSON output, represent an annotation with:

```json
{
  "path": "src/example.ts",
  "line": 42,
  "side": "new",
  "kind": "key",
  "text": "`parseConfig` now validates the boundary input before constructing internal state."
}
```

Use `side: "old"` only when commenting on removed code. Use `side: "new"` for most comments.

If exact line numbers are unavailable, attach the annotation to the file section instead of inventing a line number.

## Density

Keep annotations sparse:

- Usually 0-3 annotations across a standard walkthrough.
- Usually no more than 2 annotations on one hunk.
- Prefer narration for cross-file story and annotations for precise line anchors.

## Tone

Use declarative, evidence-first wording.

Good: `parseInt` accepts `NaN`; this branch now rejects it before storing the value.

Bad: This might be buggy and should probably be cleaner.
