# Accessibility

WCAG compliance, keyboard navigation, screen reader support, and inclusive design in React applications.

## Guiding Principle

Accessibility is not a feature — it is a quality attribute. Build it in from the start; retrofitting is 5-10x more expensive.

## WCAG 2.1 AA Checklist (Essential)

### Perceivable

| Requirement | How |
|------------|-----|
| Text alternatives | All `<img>` have meaningful `alt` (or `alt=""` for decorative) |
| Color independence | Never use color alone to convey information |
| Contrast | 4.5:1 for normal text, 3:1 for large text and UI components |
| Resize | Content usable at 200% zoom without horizontal scroll |
| Motion | Respect `prefers-reduced-motion`; no auto-playing animation |

### Operable

| Requirement | How |
|------------|-----|
| Keyboard access | All interactive elements reachable via Tab/Shift+Tab |
| Focus visible | Clear, high-contrast focus indicator on every focusable element |
| No keyboard traps | User can always Tab away from a component |
| Skip links | "Skip to main content" link at top of page |
| Touch targets | Minimum 44x44px for mobile tap targets |
| No time limits | Or provide way to extend/disable |

### Understandable

| Requirement | How |
|------------|-----|
| Language | `<html lang="en">` set correctly |
| Labels | Every form input has a visible `<label>` |
| Error messages | Identify what's wrong and how to fix it |
| Predictable | Same UI patterns behave the same way throughout |
| Help available | Instructions before complex interactions |

### Robust

| Requirement | How |
|------------|-----|
| Valid HTML | Proper semantic elements, no broken nesting |
| ARIA when needed | Use native HTML elements first; ARIA as supplement |
| Name/role/value | All components have accessible name and role |

## Keyboard Navigation

### Focus Order

```
Tab:        Move to next focusable element
Shift+Tab:  Move to previous focusable element
Enter:      Activate button/link
Space:      Toggle checkbox, activate button
Escape:     Close modal/dropdown/popover
Arrow keys: Navigate within composite widgets (tabs, menus, listbox)
```

### Focus Management Rules

1. **Logical tab order** — Follows visual layout (top-left to bottom-right for LTR)
2. **Modal focus trap** — Tab stays within open modal; Escape closes it
3. **Focus restoration** — When closing modal/dropdown, return focus to trigger element
4. **No `tabindex` > 0** — Only use `tabindex="0"` (in order) or `tabindex="-1"` (programmatic only)
5. **Visible focus ring** — Never `outline: none` without a replacement

### Focus Indicator Style

```css
/* Visible, high-contrast focus ring */
:focus-visible {
  outline: 2px solid var(--accent-primary);
  outline-offset: 2px;
}

/* Remove default only when custom provided */
:focus:not(:focus-visible) {
  outline: none;
}
```

## Semantic HTML

### Choose the Right Element

| Need | Use | Not |
|------|-----|-----|
| Navigation | `<nav>` | `<div class="nav">` |
| Button action | `<button>` | `<div onclick>`, `<a href="#">` |
| Link to page | `<a href="...">` | `<button>` for navigation |
| Form input | `<input>` + `<label>` | `<div contenteditable>` |
| Heading | `<h1>`-`<h6>` | `<div class="heading">` |
| List | `<ul>/<ol>` + `<li>` | Nested `<div>`s |
| Table data | `<table>` | CSS grid of `<div>`s |
| Section | `<section>`, `<article>`, `<main>` | Generic `<div>` |

**Rule:** If an HTML element does what you need, use it. ARIA is for bridging gaps, not replacing HTML.

## ARIA Essentials

### Common Patterns

| Pattern | Key ARIA | Notes |
|---------|----------|-------|
| Modal dialog | `role="dialog"`, `aria-modal="true"`, `aria-labelledby` | Trap focus, restore on close |
| Tab panel | `role="tablist"`, `role="tab"`, `role="tabpanel"`, `aria-selected` | Arrow key navigation |
| Dropdown menu | `role="menu"`, `role="menuitem"`, `aria-expanded` | Arrow keys + Escape |
| Live region | `aria-live="polite"` or `"assertive"` | Dynamic content updates |
| Loading state | `aria-busy="true"` | On container being updated |
| Toggle | `aria-pressed="true/false"` | For toggle buttons |
| Error | `aria-invalid="true"`, `aria-describedby` | Link input to error message |

### ARIA Rules

1. **Don't use ARIA if native HTML works** — `<button>` over `<div role="button">`
2. **All interactive ARIA elements need keyboard support** — Role alone is not enough
3. **Don't change native semantics** — `<h2 role="button">` is wrong
4. **Visible labels > `aria-label`** — Sighted users benefit from visible labels too
5. **Test with actual screen readers** — ARIA bugs are invisible without one

## React-Specific Accessibility

### JSX Gotchas

| HTML | JSX | Notes |
|------|-----|-------|
| `for` | `htmlFor` | On `<label>` elements |
| `class` | `className` | Standard JSX |
| `tabindex` | `tabIndex` | camelCase in JSX |
| `aria-*` | `aria-*` | Same as HTML (hyphenated) |
| `role` | `role` | Same as HTML |

### Focus Management in React

- Use `useRef` + `useEffect` for programmatic focus after state changes
- Use `autoFocus` sparingly — only when the user clearly expects focus to move
- After client navigation, move focus to the new page's `<h1>` or main content

### Headless UI Libraries

Prefer headless libraries that handle a11y correctly out of the box:

| Library | Approach |
|---------|----------|
| Radix UI | Unstyled primitives, full keyboard + ARIA |
| React Aria (Adobe) | Hooks-based, comprehensive a11y |
| Ark UI | Headless, state-machine driven |

**Rule:** Don't re-implement modal focus traps, comboboxes, or tab panels from scratch — use a headless library.

### Live Regions for Dynamic Content

Use a visually hidden `aria-live` region to announce toast content, form results, loading completion, and client-side route changes.

## Reduced Motion

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

In React, you can also use a hook:

```tsx
const prefersReducedMotion = useMediaQuery("(prefers-reduced-motion: reduce)")
```

## Testing

| Method | Catches |
|--------|---------|
| Keyboard-only navigation | Focus traps, missing interactions |
| Screen reader (VoiceOver/NVDA) | Missing labels, broken announcements |
| Browser DevTools a11y audit | Contrast, missing alt text, ARIA errors |
| `eslint-plugin-jsx-a11y` | Static a11y issues in JSX at lint time |
| Zoom to 200% | Overflow, broken layouts |
| `prefers-reduced-motion` toggle | Motion-sensitive issues |

**Rule:** Add `eslint-plugin-jsx-a11y` to every React project. It catches missing `alt`, invalid ARIA, and more at build time.

## See Also

- [react.md](./react.md) — React component architecture
- [color.md](./color.md) — Contrast ratios and color-blindness
- [components.md](./components.md) — Accessible component patterns
- [responsive.md](./responsive.md) — Touch targets and zoom
