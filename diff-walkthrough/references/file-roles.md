# File Roles

Classify each changed file by `role` and `changeKind`. The role drives reading order, grouping, and how much narration the file receives.

## Change Kind

Read `changeKind` from the diff header.

| `changeKind` | Diff Signal |
|--------------|-------------|
| `new` | `new file mode` or `--- /dev/null` |
| `del` | `deleted file mode` or `+++ /dev/null` |
| `ren` | `rename from` and `rename to` |
| `mod` | Existing file changed in place |

If a file is renamed and edited, classify it as `ren` and describe the body changes in the narration.

## Roles

Pick one role per file.

| Role | Meaning |
|------|---------|
| `foundation` | Types, schemas, interfaces, protocols, models, migrations, or shared contracts that other changed files depend on |
| `core` | Main behavior, algorithm, bug fix, or feature logic |
| `wiring` | Registration, routes, configuration, dependency injection, adapters, or integration glue |
| `ui` | User-facing views, components, templates, CLI prompts, dashboards, or copy |
| `test` | Executable tests, test helpers, regression cases, or meaningful test data builders |
| `docs` | Documentation, examples, runbooks, or changelogs |
| `noise` | Lockfiles, generated files, vendored code, snapshots, pure fixtures, or formatter-only churn |

## Decision Flow

1. Generated file, lockfile, vendored code, or formatter-only churn -> `noise`.
2. Test file with executable assertions or helpers -> `test`.
3. Pure fixture, snapshot, golden output, or large opaque test data -> `noise`.
4. UI/template/view/component -> `ui`.
5. New shared contract used by other changed files -> `foundation`.
6. Main behavior or bug fix -> `core`.
7. Documentation -> `docs`.
8. Everything else -> `wiring`.

## Path Signals

| Pattern | Likely Role |
|---------|-------------|
| `**/migrations/**`, `*.sql`, `schema.*` | `foundation` |
| `**/proto/**`, `*.proto`, `*.openapi.*` | `foundation` if authored, `noise` if generated |
| `**/types/**`, `**/models/**`, `*.d.ts` | `foundation` |
| `**/handlers/**`, `**/controllers/**`, `**/routes/**` | `core` or `wiring`; inspect body |
| `main.*`, `cmd/**`, `bin/**` | usually `wiring` |
| `**/components/**`, `**/views/**`, `*.tsx`, `*.jsx`, `*.vue`, `*.svelte` | `ui` |
| `**/*_test.*`, `**/__tests__/**`, `*.spec.*`, `*_spec.rb` | `test` |
| `**/fixtures/**`, `**/testdata/**`, snapshots, golden files | usually `noise` |
| workflow files, CI config, `Dockerfile`, deployment config | `wiring` when meaningful, `noise` for routine bumps |

## Noise Patterns

Treat these as low-information unless the diff makes them central:

- Lockfiles: `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `Cargo.lock`, `Pipfile.lock`, `poetry.lock`, `Gemfile.lock`, `go.sum`.
- Generated code: headers like `Code generated`, `DO NOT EDIT`, `Auto-generated`, plus `*.pb.go`, `*.gen.*`, `*_generated.*`.
- Large raw fixtures: `.har`, `.sdp`, `.csv`, snapshots, golden files, bulky JSON blobs.
- Formatter-only changes: whitespace, import sorting, or comment wrapping with no semantic edit.

Override the heuristic when a normally noisy file is load-bearing, such as an authored OpenAPI contract or migration that defines the main behavior.
