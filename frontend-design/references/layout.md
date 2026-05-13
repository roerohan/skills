# Layout and Spacing

Spatial organization principles for page and component layouts in React applications.

## Layout Models

### When to Use What

| Model | Use When | Avoid When |
|-------|----------|------------|
| Flexbox | 1D alignment (row or column) | Complex 2D grid layouts |
| Grid | 2D layouts, page structure | Simple linear stacking |
| Stack (flex column) | Vertical list of elements | Side-by-side elements |
| Cluster (flex row wrap) | Tags, badges, inline groups | Strict grid alignment |

### Page Layout Patterns

```
Standard page:
┌──────────────────────────────────┐
│ Header / Nav                     │
├────────┬─────────────────────────┤
│ Sidebar│ Main Content            │
│        │                         │
│        │                         │
├────────┴─────────────────────────┤
│ Footer                           │
└──────────────────────────────────┘

Content-focused:
┌──────────────────────────────────┐
│ Header                           │
├──────────────────────────────────┤
│     ┌────────────────────┐       │
│     │ Constrained Content│       │
│     │ (max-width: 65ch)  │       │
│     └────────────────────┘       │
├──────────────────────────────────┤
│ Footer                           │
└──────────────────────────────────┘
```

## Spacing System

### Base Unit

Choose 4px or 8px as base. All spacing derives from it.

| Scale | 4px base | 8px base | Common Use |
|-------|----------|----------|------------|
| 1 | 4px | 8px | Inline gaps, icon padding |
| 2 | 8px | 16px | Element spacing, input padding |
| 3 | 12px | 24px | Card padding, group spacing |
| 4 | 16px | 32px | Section spacing |
| 6 | 24px | 48px | Major section breaks |
| 8 | 32px | 64px | Page-level sections |
| 12 | 48px | 96px | Hero sections |

### Spacing Rules

1. **Related elements get less space** — Group label + input tighter than between form groups
2. **Unrelated elements get more space** — Distinct sections need clear visual separation
3. **Nesting reduces spacing** — Inner containers use tighter spacing than outer
4. **Vertical rhythm matters** — Consistent vertical spacing improves scanability

### Margin vs Gap vs Padding

| Property | When to Use |
|----------|-------------|
| `gap` | Between children in flex/grid (preferred) |
| `padding` | Internal spacing within a container |
| `margin` | Spacing between siblings (use sparingly) |

**Prefer `gap` over margin** — avoids margin collapse issues and trailing/leading margin problems.

## Content Width

| Content Type | Max Width | Reason |
|-------------|-----------|--------|
| Prose text | 60-75ch | Optimal line length for readability |
| Forms | 400-600px | Prevent overly wide inputs |
| Cards grid | 1200-1400px | Standard content area |
| Full-bleed | 100% | Hero images, backgrounds |
| Dashboard | No max (with sidebar) | Data density needs space |

## Alignment Principles

1. **Left-align text** — Natural reading direction (LTR languages)
2. **Center-align headings** — Only for hero sections or single-line headings
3. **Right-align numbers** — In tables, for decimal alignment
4. **Align to grid** — All elements should snap to the spacing grid
5. **Reduce alignment points** — Fewer invisible lines = cleaner layout

## Layout Components

In React, prefer reusable layout components over repeating CSS patterns:

```tsx
// Stack: vertical spacing between children
<Stack gap="md">
  <Heading>Title</Heading>
  <Text>Description</Text>
  <Button>Action</Button>
</Stack>

// Cluster: horizontal wrapping group
<Cluster gap="sm">
  <Badge>React</Badge>
  <Badge>TypeScript</Badge>
</Cluster>

// Container: max-width + centered
<Container maxWidth="prose">
  <Article>{content}</Article>
</Container>
```

**Rule:** If you find yourself writing `display: flex; flex-direction: column; gap: ...` repeatedly, extract a `<Stack>` component. Same for `<Cluster>`, `<Container>`, `<Grid>`.

## Box Model Defaults

```css
/* Always set this globally (in your CSS reset / global styles) */
*, *::before, *::after {
  box-sizing: border-box;
}
```

## Common Layout Mistakes

| Mistake | Fix |
|---------|-----|
| Nested scroll containers | One scrollable area per view |
| Content touching edges | Always pad containers |
| Inconsistent gutters | Use spacing tokens, not random values |
| Fixed heights on content | Use min-height; let content breathe |
| Horizontal scroll on mobile | Constrain widths; check overflow |

## See Also

- [react.md](./react.md) — Component hierarchy and structure
- [responsive.md](./responsive.md) — Adapting layout to screen size
- [typography.md](./typography.md) — Content width interacts with line length
- [components.md](./components.md) — Layout within components
