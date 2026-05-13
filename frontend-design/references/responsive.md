# Responsive Design

Breakpoints, mobile-first approach, and fluid design.

## Mobile-First Approach

Write base styles for mobile, then layer on complexity for larger screens.

```css
/* Base: mobile styles (no media query) */
.container { padding: 16px; }

/* Tablet and up */
@media (min-width: 768px) {
  .container { padding: 24px; }
}

/* Desktop and up */
@media (min-width: 1024px) {
  .container { padding: 32px; max-width: 1200px; }
}
```

**Why mobile-first:**
- Forces content prioritization
- Simpler base styles, progressive enhancement
- Mobile users don't download desktop-only CSS
- Easier to add complexity than remove it

## Breakpoints

### Standard Breakpoints

| Name | Min Width | Target |
|------|-----------|--------|
| `sm` | 640px | Large phones (landscape) |
| `md` | 768px | Tablets |
| `lg` | 1024px | Small desktops / landscape tablets |
| `xl` | 1280px | Desktops |
| `2xl` | 1536px | Large desktops |

### Rules

1. **Content determines breakpoints** — Adjust when layout breaks, not at device sizes
2. **Use ranges, not points** — Design for between breakpoints, not at them
3. **Max 3-4 breakpoints** — More creates maintenance burden
4. **Test at odd sizes** — 900px, 1100px, 375px — not just breakpoint boundaries

## Layout Adaptation Patterns

### Content Reflow

```
Desktop (3 col):        Tablet (2 col):       Mobile (1 col):
┌───┬───┬───┐           ┌───┬───┐             ┌───┐
│ 1 │ 2 │ 3 │           │ 1 │ 2 │             │ 1 │
└───┴───┴───┘           ├───┴───┤             ├───┤
                        │   3   │             │ 2 │
                        └───────┘             ├───┤
                                              │ 3 │
                                              └───┘
```

### Navigation

| Screen | Pattern |
|--------|---------|
| Desktop | Horizontal top nav with dropdowns |
| Tablet | Condensed top nav or horizontal scroll |
| Mobile | Hamburger menu or bottom tab bar |

**Mobile nav rules:**
- Hamburger menus hide navigation — use for secondary nav
- Bottom tab bar for primary navigation (max 5 items)
- Ensure hamburger trigger is 44x44px minimum

### Sidebar

| Screen | Approach |
|--------|----------|
| Desktop | Persistent sidebar |
| Tablet | Collapsible sidebar (icon-only or drawer) |
| Mobile | Off-canvas drawer or separate page |

### Tables

| Screen | Approach |
|--------|----------|
| Desktop | Full table |
| Tablet | Horizontal scroll with sticky first column |
| Mobile | Card layout per row, or priority columns only |

## Fluid Design

### Fluid Typography

```css
/* Scales from 16px at 320px viewport to 20px at 1200px */
font-size: clamp(1rem, 0.9rem + 0.5vw, 1.25rem);
```

| Element | Min | Fluid | Max |
|---------|-----|-------|-----|
| Body | 16px | `clamp(1rem, 0.9rem + 0.5vw, 1.25rem)` | 20px |
| H1 | 28px | `clamp(1.75rem, 1.5rem + 1.5vw, 3rem)` | 48px |
| H2 | 22px | `clamp(1.375rem, 1.2rem + 1vw, 2.25rem)` | 36px |

### Fluid Spacing

```css
/* Padding scales with viewport */
padding: clamp(1rem, 2vw + 0.5rem, 3rem);
```

**Rules:**
- Always set min and max bounds with `clamp()`
- Test at extreme sizes (320px and 2560px)
- Don't use `vw` for body text without `clamp()` — breaks zoom

## Touch Considerations

| Element | Min Size | Recommended |
|---------|----------|-------------|
| Tap target | 44x44px | 48x48px |
| Spacing between targets | 8px | 12px |
| Input height | 44px | 48px |
| Button height | 44px | 48px |

**Rules:**
- Visible element can be smaller if tap area extends via padding
- Thumb-zone: primary actions in bottom half of mobile screen
- Avoid hover-dependent interactions on touch
- Add `:active` styles for touch feedback

## Images and Media

```css
/* Responsive images */
img {
  max-width: 100%;
  height: auto;
}

/* Responsive video/embed */
.video-container {
  aspect-ratio: 16 / 9;
  width: 100%;
}
```

**Rules:**
- Use `srcset` and `sizes` for resolution-appropriate images
- Lazy load below-fold images (`loading="lazy"`)
- Set explicit `width` and `height` to prevent layout shift
- Use `aspect-ratio` for responsive containers

## Testing

| Check | Method |
|-------|--------|
| Mobile layout | Chrome DevTools device toolbar |
| Touch targets | Measure with DevTools ruler |
| Orientation | Rotate in device emulator |
| Real devices | Test on actual phone + tablet |
| Zoom 200% | Ctrl/Cmd + scroll or browser zoom |
| Reduced motion | Toggle in OS settings |
| Print | `@media print` styles |

## Common Responsive Mistakes

| Mistake | Fix |
|---------|-----|
| Desktop-first styles | Start mobile, enhance up |
| Fixed widths | Use `%`, `fr`, `max-width`, `min-width` |
| Hidden content on mobile | Reorganize, don't hide |
| Tiny tap targets | Minimum 44x44px |
| Hover-only interactions | Provide touch/keyboard alternatives |
| `overflow: hidden` on body | Causes scroll issues on iOS |
| 100vh on mobile | Use `100dvh` or JS for dynamic viewport |

## See Also

- [layout.md](./layout.md) — Grid and flexbox for responsive layouts
- [typography.md](./typography.md) — Fluid type scales
- [accessibility.md](./accessibility.md) — Zoom, touch targets, reduced motion
