# Component Patterns

Common UI component design patterns for React applications.

**Note:** For React-specific architecture (hooks, composition, state), see [react.md](./react.md). This file covers the visual/behavioral design of common UI components.

## Component Design Principles

1. **Single responsibility** — One component does one thing well
2. **Composable over configurable** — Prefer `children` and compound patterns over prop flags
3. **Controlled by default** — Parent owns state; component reports changes via callbacks
4. **Accessible by default** — Keyboard, screen reader, and focus built in
5. **Styled by tokens** — Use design tokens, not hardcoded values
6. **Forward refs** — UI components wrapping native elements should use `forwardRef`

## Component Anatomy

Every interactive component needs these states:

| State | Visual | Required |
|-------|--------|----------|
| Default/Rest | Normal appearance | Yes |
| Hover | Subtle background/border change | Yes |
| Focus | Visible focus ring (2px outline) | Yes |
| Active/Pressed | Slight depression or color shift | Yes |
| Disabled | Reduced opacity (0.5), `cursor: not-allowed` | If applicable |
| Loading | Spinner or skeleton replacing content | If applicable |
| Error | Red border/text, error message | If applicable |
| Selected | Accent background or checkmark | If applicable |

## Common Component Patterns

### Button

| Variant | Use For |
|---------|---------|
| Primary (filled) | Single main action per view |
| Secondary (outlined) | Supporting actions |
| Ghost/Tertiary | Low-emphasis actions, inline actions |
| Destructive | Delete, remove, irreversible actions |
| Icon-only | Toolbars, compact spaces (needs `aria-label`) |

**Rules:**
- One primary button per visible area
- Button text is a verb: "Save", "Delete", "Create project" — not "OK", "Yes"
- Destructive buttons use danger color, placed away from safe actions
- Disabled buttons should explain why (tooltip or adjacent text)
- Min width: 80px. Min height: 36px (44px on touch)

### Form Inputs

```
┌─────────────────────────┐
│ Label                   │  ← Always visible, above input
│ ┌─────────────────────┐ │
│ │ Placeholder...      │ │  ← Placeholder is NOT a label
│ └─────────────────────┘ │
│ Helper text             │  ← Optional guidance
│ Error message           │  ← Replaces helper on error
└─────────────────────────┘
```

**Rules:**
- Every input has a visible `<label>` (use `htmlFor` in JSX, not `for`)
- Placeholder disappears on focus — never use as the only label
- Error messages say what's wrong and how to fix it
- Group related fields (name + email) visually
- Mark required fields (asterisk or "(required)"); or mark optional fields if most are required
- Prefer controlled inputs; use form libraries (React Hook Form, Conform) for complex forms
- Use server actions / route actions for form submission when possible

### Modal / Dialog

**Rules:**
- Use the native `<dialog>` element or a headless library (Radix, Ark UI, React Aria)
- Trap focus inside while open
- Close on Escape key
- Return focus to trigger element on close
- Backdrop blocks interaction with page behind
- Max width: 90vw or 600px. Max height: 85vh with scroll
- Title bar with close button
- Actions at bottom: primary right, cancel left
- Manage open/close state in the nearest parent, not global state

### Dropdown / Select

**Rules:**
- `aria-expanded` on trigger
- Arrow key navigation within options
- Escape closes without selection
- Selected item indicated with checkmark or highlight
- Max visible items: 8-10, then scroll
- Type-ahead: typing filters/jumps to matching option

### Toast / Notification

| Type | Duration | Dismissible |
|------|----------|-------------|
| Success | 3-5 seconds | Auto-dismiss |
| Info | 5-8 seconds | Auto-dismiss + manual |
| Warning | Persistent | Manual dismiss |
| Error | Persistent | Manual dismiss |

**Rules:**
- Stack from bottom-right or top-right, max 3 visible
- Use `aria-live="polite"` for non-urgent, `"assertive"` for errors
- Include action when applicable ("Undo", "View", "Retry")
- Don't block page interaction

### Card

```
┌─────────────────────────────┐
│ [Image/Media]               │  ← Optional
├─────────────────────────────┤
│ Title                       │
│ Description text that may   │
│ span multiple lines...      │
│                             │
│ Metadata / Tags             │
├─────────────────────────────┤
│ [Actions]                   │  ← Optional footer
└─────────────────────────────┘
```

**Rules:**
- If the whole card is clickable, use `<a>` or `<article>` with a link
- Consistent card heights in a grid (use `min-height` or flex)
- Truncate long descriptions with "Read more"
- Padding: consistent with spacing system

### Table

**Rules:**
- Header row is sticky on scroll
- Sortable columns show sort indicator (arrow)
- Right-align numeric columns
- Zebra striping or row borders for scanability
- Row actions: inline (icon buttons) or via selection + toolbar
- Responsive: horizontal scroll or card layout on mobile
- Empty state: message with action, not a blank table

## Loading Patterns

| Pattern | Use When | React Approach |
|---------|----------|----------------|
| Skeleton | Layout is known; replacing with content | `<Suspense fallback={<Skeleton />}>` |
| Spinner | Unknown layout; brief wait (<3s) | `<Suspense fallback={<Spinner />}>` |
| Progress bar | Known duration/percentage | Controlled component with progress state |
| Inline spinner | Loading within a specific element | `useTransition` / `isPending` state |
| Optimistic UI | Action likely to succeed | `useOptimistic` or TanStack Query optimistic updates |

**Rules:**
- Always show loading state — never leave the user staring at nothing
- Prefer `<Suspense>` boundaries over manual `isLoading` state
- Place Suspense boundaries around the smallest unit that loads independently
- Use `useTransition` for non-urgent updates to keep UI responsive

## Empty States

Every list/table/view needs an empty state:

```
┌─────────────────────────┐
│                         │
│     [Illustration]      │  ← Optional
│                         │
│   No projects yet       │  ← Clear heading
│   Create your first     │
│   project to get        │
│   started.              │  ← Helpful description
│                         │
│   [Create project]      │  ← Primary action
│                         │
└─────────────────────────┘
```

## See Also

- [react.md](./react.md) — React architecture, hooks, composition patterns
- [accessibility.md](./accessibility.md) — ARIA patterns for each component
- [color.md](./color.md) — State colors (hover, active, disabled)
- [layout.md](./layout.md) — Component spacing and alignment
