# Typography

Type scale, font selection, and readability principles.

## Type Scale

Use a modular scale for consistent sizing. Common ratio: 1.25 (Major Third).

| Level | Scale | Size (16px base) | Use |
|-------|-------|-------------------|-----|
| `xs` | 0.75 | 12px | Captions, fine print |
| `sm` | 0.875 | 14px | Secondary text, metadata |
| `base` | 1.0 | 16px | Body text |
| `lg` | 1.125 | 18px | Lead paragraphs |
| `xl` | 1.25 | 20px | H4, card titles |
| `2xl` | 1.5 | 24px | H3, section headings |
| `3xl` | 1.875 | 30px | H2, major headings |
| `4xl` | 2.25 | 36px | H1, page titles |
| `5xl` | 3.0 | 48px | Display, hero text |

**Rule:** No more than 4-5 distinct sizes per page. Fewer sizes = stronger hierarchy.

## Font Selection

### Font Pairing Rules

| Rule | Example |
|------|---------|
| Max 2-3 fonts per project | 1 heading + 1 body (+ 1 mono) |
| Contrast in style | Sans heading + serif body |
| Match x-height | Fonts should visually align at body size |
| System fonts are fine | `-apple-system, system-ui, sans-serif` |

### System Font Stack

```css
/* Sans-serif (UI text) */
font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto,
  "Helvetica Neue", Arial, sans-serif;

/* Monospace (code) */
font-family: ui-monospace, "SF Mono", "Cascadia Code", "Fira Code",
  Menlo, monospace;
```

System fonts load instantly and match OS conventions.

## Line Height (Leading)

| Content Type | Line Height | Reason |
|-------------|-------------|--------|
| Body text | 1.5-1.75 | Optimal reading comfort |
| Headings | 1.1-1.3 | Tighter for large text |
| UI labels | 1.25-1.5 | Compact but readable |
| Code | 1.5-1.7 | Scan-friendly |

**Rule:** As font size increases, line height ratio decreases.

## Line Length

| Measure | Ideal | Acceptable |
|---------|-------|------------|
| Characters per line | 55-65 | 45-75 |
| `max-width` for prose | `65ch` | `45ch`-`75ch` |

Lines too long = eye fatigue. Too short = excessive line breaks.

## Font Weight

| Weight | Name | Use |
|--------|------|-----|
| 400 | Regular | Body text, default |
| 500 | Medium | Subtle emphasis, labels |
| 600 | Semibold | Subheadings, nav items |
| 700 | Bold | Headings, strong emphasis |

**Rules:**
- Use weight to create hierarchy, not just size
- Max 2-3 weights per page
- Don't use bold for long passages — it reduces readability

## Letter Spacing (Tracking)

| Context | Tracking | Reason |
|---------|----------|--------|
| All-caps text | +0.05em to +0.1em | Improves legibility |
| Large display text | -0.02em to -0.01em | Tightens loose appearance |
| Body text | 0 (default) | Font's built-in spacing is optimal |
| Small text (<12px) | +0.02em | Compensates for reduced clarity |

## Hierarchy Techniques

Combine these to establish clear hierarchy (don't rely on size alone):

| Technique | Effect |
|-----------|--------|
| Size | Larger = more important |
| Weight | Bolder = more important |
| Color | Higher contrast = more important |
| Position | Top/left = read first (LTR) |
| Whitespace | More space = more emphasis |
| Case | Uppercase = label/category (use sparingly) |

## Common Typography Mistakes

| Mistake | Fix |
|---------|-----|
| Too many font sizes | Stick to 4-5 from the scale |
| Centered body text | Left-align; center only short headings |
| Low contrast text | Body text needs 4.5:1 minimum |
| All-caps body text | Reserve uppercase for short labels |
| Underline for emphasis | Underline implies links; use bold/italic |
| Orphan/widow lines | Adjust width or content |

## See Also

- [color.md](./color.md) — Text color and contrast
- [layout.md](./layout.md) — Content width constraints
- [accessibility.md](./accessibility.md) — Minimum text sizes, contrast
