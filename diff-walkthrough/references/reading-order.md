# Reading Order

The reading order is the main value of a diff walkthrough. Compute the order from the story of the change, not from path sorting or diff output order.

## Two-Pass Algorithm

1. Detect the motif: feature, bugfix, refactor, revert, mechanical, migration, dependency update, docs-only, or mixed.
2. Apply the default tier model, then modify it with the motif override.

## Motifs

| Motif | Signals |
|-------|---------|
| `feature` | New capability, new contracts or logic, tests proving new behavior |
| `bugfix` | Surgical logic change, focused regression test, commit text says fix/bug |
| `refactor` | Structure changes while intended behavior stays the same |
| `revert` | Diff backs out a prior change or says revert/backout |
| `mechanical` | Many identical-shape edits, codemod, formatter, rename, mass API update |
| `migration` | Old-to-new data/API/config model, compatibility or data handling matters |
| `dependency` | Version bump plus any required call-site changes |
| `docs-only` | Documentation is the product of the change |
| `mixed` | Main change plus distinct drive-by cleanup or unrelated second motif |

The one-sentence summary usually reveals the motif: "adds" means feature, "fixes" means bugfix, "renames/extracts" means refactor or mechanical, "reverts" means revert.

## Default Tier Model

For a feature-like change, order files as:

1. `foundation`: contracts, schemas, types, migrations
2. `core`: behavior and algorithms
3. `wiring`: routes, config, registration, adapters
4. `ui`: presentation and interaction
5. `test`: proof and regression coverage
6. `docs`: explanatory docs
7. `noise`: generated, lockfiles, fixtures, formatter churn

Within a tier, sort by dependency first, then smaller anchoring files, then path locality.

## Overrides

### Bugfix

Start with the fix. Then show the regression proof, then supporting context.

Order:

1. Core fix
2. Test or proof that catches the bug
3. Foundation or wiring only if needed to understand the fix
4. Noise last

Explicitly identify the line or assertion that prevents the regression when visible.

### Refactor

State whether behavior is intended to change. Then read producers before consumers.

Order:

1. Extracted helpers or new structure
2. Moved/renamed files, summarized briefly
3. Updated call sites
4. Tests if materially changed

### Revert

Do not narrate every restored file. Explain what is being backed out, why if known, and what behavior returns. Point to the original change when metadata provides it.

### Mechanical

Group repeated edits. Show one canonical example per pattern, then summarize the rest as a group with file counts and paths.

### Migration

Start with the old-to-new model. Then show compatibility, data movement, call-site updates, tests, and operational considerations.

### Dependency Update

If only lockfiles changed, keep it short. If call sites changed, start with the dependency-facing API change, then updated uses, tests, and lockfile noise.

### Mixed

Separate the primary change from drive-bys when they are materially distinct. A drive-by is distinct if removing it would leave the main change coherent.

Order the primary change using its motif, then group the drive-by files under a clear label such as "Drive-by cleanup".

## Self-Check

Before finalizing the order, ask:

- Can a reader follow the order without jumping backward for missing context?
- Is the smallest useful explanation point in the first three entries?
- For a bugfix, does the fix appear first?
- Are generated files, fixtures, and lockfiles collapsed unless `coverage=full`?
- If the diff is mixed, did you tell the reader that upfront?
