# React Patterns

Component architecture, hooks, composition, state management, and meta-framework conventions.

## Component Design

### Component Hierarchy

| Layer | Server or Client | Owns State | Fetches Data |
|-------|-----------------|------------|--------------|
| Route/Page | Server (loader/RSC) | No | Yes |
| Feature | Client (usually) | Yes | No (receives via props/context) |
| UI | Either | No (controlled) | No |

### Component Sizing Rules

- **< 80 lines** — UI components. **< 150 lines** — Feature components
- **> 200 lines** — Extract sub-components or custom hooks
- **One component per file** — Exception: tightly coupled compound components

### Props Design

```tsx
// Good: minimal, composable
type ButtonProps = {
  variant: "primary" | "secondary" | "ghost" | "destructive"
  size: "sm" | "md" | "lg"
  children: React.ReactNode
  disabled?: boolean
  onClick?: () => void
}

// Bad: boolean prop sprawl
type ButtonProps = {
  isPrimary?: boolean
  isSecondary?: boolean
  isSmall?: boolean
  isLarge?: boolean
  label: string  // ← use children instead
}
```

**Rules:**
- Use discriminated unions over boolean flags
- `children` for content; avoid `label`/`text` string props when JSX flexibility is needed
- Optional props should have sensible defaults
- Limit to ~7 props per component; more signals need for composition

### Ref Forwarding

Always forward refs on UI components wrapping native elements:

```tsx
const Input = React.forwardRef<HTMLInputElement, InputProps>(
  ({ className, ...props }, ref) => (
    <input ref={ref} className={cn("...", className)} {...props} />
  )
)
```

## Composition Patterns

### Children Over Config

```tsx
// Good: composable             // Bad: config object
<Card>                          <Card
  <CardHeader>                    title="Title"
    <CardTitle>Title</CardTitle>  body="Body"
  </CardHeader>                   footer={<Actions />}
  <CardContent>Body</CardContent> />
</Card>
```

### Compound Components

Group related components under a namespace when they always work together:

```tsx
<Tabs defaultValue="tab1">
  <Tabs.List>
    <Tabs.Trigger value="tab1">Tab 1</Tabs.Trigger>
  </Tabs.List>
  <Tabs.Content value="tab1">Content 1</Tabs.Content>
</Tabs>
```

### Render Props / Slots

Use when the parent needs to control how children render:

```tsx
<DataTable
  data={users}
  columns={columns}
  renderEmpty={() => <EmptyState action={<CreateButton />} />}
/>
```

## Hooks

### Custom Hook Guidelines

| Rule | Rationale |
|------|-----------|
| Prefix with `use` | Required by React rules |
| One concern per hook | Composability |
| Return tuple or object | Tuple for 1-2 values, object for 3+ |
| No JSX in hooks | Hooks manage logic, components render |

### Effect Discipline

| Need | Use | Not |
|------|-----|-----|
| Derive from props/state | Compute during render | `useEffect` + `setState` |
| Respond to user event | Event handler | `useEffect` |
| Sync with external system | `useEffect` with cleanup | Fire-and-forget effect |
| Fetch data | Meta-framework loader / `useSuspenseQuery` | `useEffect` + `fetch` |
| Initialize once | `useRef` + lazy init | `useEffect` with `[]` |

**Rule:** If you're setting state inside `useEffect` based on other state, you probably don't need the effect.

## State Management

### Decision Tree

```
Where does this state live?
├─ URL / route params          → URL state (useParams, searchParams)
├─ Server data                 → Server state (TanStack Query, loader)
├─ Single component            → useState / useReducer
├─ Parent + children           → Lift state to parent, pass via props
├─ Distant components (same feature) → Context (scoped to feature)
├─ Truly global (theme, auth)  → Context at app root or global store
└─ Form state                  → Form library or useActionState
```

**Rules:**
- URL is the best global state — shareable, bookmarkable, back-button works
- Server state belongs in a cache (TanStack Query), not component state
- Context is for dependency injection (theme, i18n), not a general store
- Avoid Redux/Zustand unless genuinely needed — most apps don't need global stores

## Meta-Framework Conventions

These apply regardless of whether you use TanStack Start, Next.js, or Remix:

| Concern | Where |
|---------|-------|
| Data fetching | Route loaders / server components |
| Mutations | Server actions / route actions |
| Navigation | Framework `<Link>`, not `<a>` |
| Head/meta | Framework head management |
| Auth guards | Route middleware / layout loaders |
| Error handling | Route error boundaries |
| Code splitting | Route-based (automatic) |

### Server vs Client Boundary

| Server (default) | Client (`"use client"` / islands) |
|-------------------|----------------------------------|
| Data fetching, DB queries | Event handlers (onClick, onChange) |
| Auth checks, redirects | Browser APIs (localStorage, etc.) |
| HTML generation, SEO | State that changes post-mount |
| Metadata | Third-party client-only libraries |

**Rule:** Start everything as server code. Add `"use client"` only when you need interactivity. Push the client boundary as far down the tree as possible.

## Performance

| Pattern | When |
|---------|------|
| `React.lazy` + `Suspense` | Heavy components not needed at initial load |
| `useMemo` | Expensive computation with same inputs |
| `useCallback` | Stable reference for child `memo` or effect deps |
| `React.memo` | Component re-renders often with same props |
| Virtualization | Lists > 50 items |
| Image optimization | Framework `<Image>` component with lazy loading |

**Rule:** Don't memoize by default. Measure first, optimize where profiling shows waste.

## Anti-Patterns

| Anti-Pattern | Fix |
|-------------|-----|
| Prop drilling > 3 levels | Context or composition (pass components, not data) |
| `useEffect` for derived state | Compute during render |
| `useEffect` for data fetching | Use meta-framework loader or TanStack Query |
| Giant god components | Split into feature + UI components |
| String refs / `findDOMNode` | `useRef` + `forwardRef` |
| Index as key in dynamic lists | Use stable unique ID |
| Inline object/array literals in JSX | Extract to const or `useMemo` if causing re-renders |
| `any` in component props | Proper generic types |
| Copy server data into state | Use the query/loader cache as source of truth |

## See Also

- [components.md](./components.md) — UI component patterns (buttons, forms, modals)
- [accessibility.md](./accessibility.md) — a11y in React components
- [layout.md](./layout.md) — Layout primitives for React component structure
