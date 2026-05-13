---
name: frontend-design
description: React-oriented UI/UX design principles for frontend development. Covers React patterns, component architecture, hooks, layout, typography, color, accessibility, and responsive design. Use when building React UI, reviewing frontend code, designing components, or making visual/interaction decisions. Assumes React with a meta-framework (TanStack Start, Next.js, Remix, etc.).
---

# Frontend Design

UI/UX principles for building well-designed, accessible, maintainable React interfaces.

**Context:** This skill assumes React as the UI layer, typically with a meta-framework (TanStack Start, Next.js, Remix, etc.) and a styling approach (Tailwind, CSS Modules, etc.). Raw HTML/CSS guidance is provided only where it underpins React patterns.

## Core Principles

1. **Clarity over cleverness** — Users should understand the interface immediately
2. **Consistency over novelty** — Reuse established patterns; deviate only with reason
3. **Accessibility is not optional** — Design for all users from the start
4. **Content drives layout** — Structure follows information hierarchy, not decoration
5. **Composition over configuration** — Prefer `children` and compound components over prop sprawl
6. **Server-first data, client-first interaction** — Load data on the server; keep interactivity on the client

## Decision Tree

```
What are you working on?
├─ React component design / hooks / state  → See react.md
├─ Reusable UI component patterns          → See components.md
├─ Page layout / spacing                   → See layout.md
├─ Text styling / hierarchy                → See typography.md
├─ Colors / theming / contrast             → See color.md
├─ Keyboard / screen reader / a11y         → See accessibility.md
├─ Multi-device / breakpoints              → See responsive.md
└─ Multiple concerns                       → Start with react.md, layer in others
```

## Quick Reference

### Visual Hierarchy Checklist

| Level | Purpose | Techniques |
|-------|---------|------------|
| Primary | Single main action/content | Size, weight, color, position |
| Secondary | Supporting actions/content | Reduced size/weight, muted color |
| Tertiary | Contextual/metadata | Smallest size, lightest weight |

### Spacing System

Use a consistent base unit (4px or 8px). Apply multiples:

| Token | Value (8px base) | Use |
|-------|-------------------|-----|
| `xs` | 4px | Inline elements, icon gaps |
| `sm` | 8px | Tight grouping |
| `md` | 16px | Default element spacing |
| `lg` | 24px | Section padding |
| `xl` | 32px | Major section separation |
| `2xl` | 48px | Page-level separation |

### The 60-30-10 Rule

| Proportion | Role | Example |
|------------|------|---------|
| 60% | Dominant / background | Page background, card surfaces |
| 30% | Secondary / supporting | Section backgrounds, borders |
| 10% | Accent / emphasis | CTAs, active states, highlights |

## Design Review Checklist

When reviewing frontend code or designs:

- [ ] **Hierarchy**: Is the most important content/action visually dominant?
- [ ] **Consistency**: Do similar elements look and behave the same?
- [ ] **Spacing**: Is spacing systematic (not arbitrary pixel values)?
- [ ] **Color contrast**: Do text/background combos meet WCAG AA (4.5:1)?
- [ ] **Interactive states**: Do clickable elements have hover, focus, active, disabled states?
- [ ] **Responsive**: Does the layout work at mobile, tablet, and desktop widths?
- [ ] **Keyboard**: Can all interactive elements be reached and operated via keyboard?
- [ ] **Loading states**: Are empty/loading/error states designed, not just happy path?
- [ ] **Touch targets**: Are tap targets at least 44x44px on mobile?
- [ ] **Content overflow**: Does the layout handle long text, missing images, edge cases?

## Common Anti-Patterns

| Anti-Pattern | Problem | Fix |
|-------------|---------|-----|
| Magic numbers | `margin: 13px` breaks system | Use spacing tokens |
| Color hardcoding | `#3b82f6` everywhere | Use semantic color tokens |
| Hover-only affordance | Hidden from keyboard/touch users | Always show affordance; enhance on hover |
| Fixed dimensions | Breaks on different content/screens | Use min/max + fluid sizing |
| Z-index wars | Escalating `z-index: 9999` | Use a layering system (base, dropdown, modal, toast) |
| Truncation without access | `text-overflow: ellipsis` hides content | Add tooltip or expand mechanism |

## Interaction Principles

1. **Feedback is immediate** — Every user action gets a visible response within 100ms
2. **State is visible** — Users can always tell what state the system is in
3. **Actions are reversible** — Destructive actions require confirmation; prefer undo over "are you sure?"
4. **Errors are recoverable** — Show what went wrong and how to fix it
5. **Transitions are meaningful** — Animation communicates change, not decoration

## React Review Checklist (Addendum)

On top of the design review checklist above, verify for React code:

- [ ] **Component boundaries**: Is each component focused on one concern?
- [ ] **Props**: Are props minimal and well-typed? No boolean prop sprawl?
- [ ] **Composition**: Using `children`/render props instead of mega-config objects?
- [ ] **Effects**: Are effects necessary, or can derived state / event handlers replace them?
- [ ] **Keys**: Are list keys stable and meaningful (not array index)?
- [ ] **Memoization**: Is `useMemo`/`useCallback` used only where measured necessary?
- [ ] **Server vs client**: Is data fetching on the server? Is client JS minimal?
- [ ] **Error boundaries**: Do async/fallible sections have error boundaries?
- [ ] **Suspense**: Are loading states handled with Suspense where appropriate?

## Reading Order

| Task | Files to Read |
|------|---------------|
| React component architecture | react.md |
| Building a page layout | layout.md |
| Designing a reusable UI component | react.md + components.md |
| Styling text content | typography.md |
| Choosing / applying colors | color.md |
| Making UI accessible | accessibility.md |
| Supporting multiple screen sizes | responsive.md |
| Full design review | This file + all references |

## In This Reference

| File | Purpose |
|------|---------|
| [react.md](./references/react.md) | React patterns, hooks, composition, state, meta-frameworks |
| [components.md](./references/components.md) | Common UI component design patterns |
| [layout.md](./references/layout.md) | Spatial organization, grid, flexbox, spacing |
| [typography.md](./references/typography.md) | Type scale, font selection, readability |
| [color.md](./references/color.md) | Color systems, contrast, theming, dark mode |
| [accessibility.md](./references/accessibility.md) | WCAG compliance, keyboard, screen readers |
| [responsive.md](./references/responsive.md) | Breakpoints, mobile-first, fluid design |
