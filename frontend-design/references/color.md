# Color

Color systems, contrast, theming, and dark mode.

## Color Architecture

### Semantic Color Tokens

Never use raw hex/RGB in components. Map colors to semantic roles:

| Token Category | Examples | Purpose |
|---------------|----------|---------|
| `background` | `bg-primary`, `bg-secondary`, `bg-surface` | Surfaces and containers |
| `foreground` | `fg-primary`, `fg-secondary`, `fg-muted` | Text and icons |
| `border` | `border-default`, `border-subtle` | Boundaries between elements |
| `accent` | `accent-primary`, `accent-success`, `accent-danger` | Interactive/semantic emphasis |
| `state` | `state-hover`, `state-active`, `state-disabled` | Interaction feedback |

### The Three-Layer Model

```
Layer 1: Primitives (raw values)
  blue-500: #3b82f6

Layer 2: Semantic tokens (role-based)
  accent-primary: blue-500

Layer 3: Component tokens (scoped)
  button-bg: accent-primary
```

**Benefits:** Change `accent-primary` once, all components update. Swap themes by remapping Layer 2.

## Contrast Requirements (WCAG)

| Content | Min Ratio | Standard |
|---------|-----------|----------|
| Normal text (<18px) | 4.5:1 | WCAG AA |
| Large text (>=18px bold or >=24px) | 3:1 | WCAG AA |
| UI components & graphics | 3:1 | WCAG AA |
| Enhanced (all text) | 7:1 | WCAG AAA |

### Quick Contrast Reference

| Background | Safe Text Colors |
|-----------|-----------------|
| White `#fff` | `#000`-`#595959` (any dark enough) |
| Light gray `#f5f5f5` | `#000`-`#525252` |
| Dark `#1a1a1a` | `#a3a3a3`-`#fff` |
| Black `#000` | `#757575`-`#fff` |

**Tools:** Use browser DevTools contrast checker, or dedicated tools to verify.

## The 60-30-10 Rule

| Proportion | Role | Application |
|------------|------|-------------|
| 60% | Background/neutral | Page bg, card surfaces, large areas |
| 30% | Secondary | Section bg, borders, secondary text |
| 10% | Accent | Buttons, links, active states, badges |

This creates visual balance without monotony.

## Semantic Colors

| Intent | Color Family | Use For |
|--------|-------------|---------|
| Primary action | Brand color | CTAs, primary buttons, links |
| Success | Green | Confirmations, completed states |
| Warning | Amber/Yellow | Caution states, pending items |
| Danger/Error | Red | Errors, destructive actions, alerts |
| Info | Blue | Informational banners, tooltips |
| Neutral | Gray | Borders, disabled states, muted text |

**Rules:**
- Never rely on color alone to convey meaning (add icons, text, patterns)
- Keep semantic colors consistent throughout the app
- Danger/error should be the most visually urgent

## Dark Mode

### Principles

1. **Don't just invert** — Dark mode is not `filter: invert(1)`
2. **Reduce contrast slightly** — Pure white on pure black causes eye strain; use off-white on dark gray
3. **Elevate with lightness** — Higher elements = slightly lighter background (opposite of light mode shadows)
4. **Desaturate colors** — Saturated colors vibrate on dark backgrounds; reduce saturation 10-20%

### Dark Mode Surface Scale

| Layer | Light Mode | Dark Mode |
|-------|-----------|-----------|
| Page background | `#ffffff` | `#0a0a0a` |
| Card/surface | `#f5f5f5` | `#171717` |
| Elevated surface | `#e5e5e5` | `#262626` |
| Overlay | `rgba(0,0,0,0.5)` | `rgba(0,0,0,0.7)` |

### Implementation

Use CSS custom properties for theming — they work with any styling approach (Tailwind, CSS Modules, etc.):

```css
/* Global CSS or Tailwind @layer base */
:root {
  --bg-primary: #ffffff;
  --fg-primary: #171717;
}

@media (prefers-color-scheme: dark) {
  :root {
    --bg-primary: #0a0a0a;
    --fg-primary: #ededed;
  }
}
```

In React, toggle themes via a class on `<html>` or a context provider:

```tsx
// Class-based (works with Tailwind dark mode)
document.documentElement.classList.toggle("dark", isDark)

// Or use a ThemeProvider context for component-level access
```

## Common Color Mistakes

| Mistake | Fix |
|---------|-----|
| Raw hex in components | Use semantic tokens |
| Color as only indicator | Add icon, text, or pattern |
| Pure black/white in dark mode | Use off-black `#0a0a0a` / off-white `#ededed` |
| Too many accent colors | 1 primary + 4 semantic (success/warning/danger/info) |
| Same color different meanings | Each color = one semantic purpose |
| Insufficient contrast | Test all text/bg combos against WCAG AA |

## See Also

- [accessibility.md](./accessibility.md) — Full contrast and color-blindness guidance
- [typography.md](./typography.md) — Text color hierarchy
- [components.md](./components.md) — Applying color to component states
