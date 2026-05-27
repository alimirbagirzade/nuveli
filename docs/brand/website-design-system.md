# Nuveli — Website Design System

> Captured 2026-05-27 from the **live** site (`nuveli.com.tr`, page
> `gizlilik.html`). Purpose: when the website is **rebuilt or extended** (new
> pages, redesign, a real CMS/framework), reuse this exact visual language so
> pages don't drift. The full live stylesheet is saved verbatim at
> **`docs/brand/nuveli-web.css`**.

## How the live site is built (important)
- Plain **static HTML** on **LiteSpeed** shared hosting (cPanel). No framework.
- CSS is **inline in a `<style>` block in each page's `<head>`** — there is NO
  external stylesheet. So every page carries its own copy of the CSS.
- **Lesson / why this matters:** any NEW page (or a legal-page edit) must reuse
  the same inline CSS + markup classes, or it will look off-brand. When the
  Health Connect section was first drafted as a standalone GitHub Pages doc it
  did NOT match — the fix was to inject into the real page so it inherits this
  CSS. A future rebuild should move this CSS to ONE shared stylesheet so this
  can't happen again.
- Page structure for legal pages: `.site-header` → `.legal-hero`
  (`<h1>` + `<p class="meta">` date) → `.legal-content .container-narrow`
  (numbered `<h2>` sections + `<p>`/`<ul>`) → `.site-footer`.

## Typography
- **Headings:** `Plus Jakarta Sans` (500/600/700) → CSS var `--font-h`
- **Body:** `Inter` (400/500/600/700) → CSS var `--font-b`
- Loaded from Google Fonts:
  `https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Plus+Jakarta+Sans:wght@500;600;700&display=swap`
- Fallback stack: `system-ui, -apple-system, sans-serif`

## Color palette (CSS variables)
Brand is a **teal / aqua + deep navy** wellness palette.

| Token | Hex | Use |
|---|---|---|
| `--primary-700` | `#062B45` | deepest navy (text on light, "pro" gradient) |
| `--primary-600` | `#0A6C8C` | primary brand blue |
| `--primary-500` | `#0C7AA0` | primary blue (lighter) |
| `--accent-aqua` | `#14C8D8` | aqua accent |
| `--accent-seafoam` | `#7BE6D5` | seafoam accent |
| `--surface-soft` | `#F2FCFB` | softest surface / page bg |
| `--surface-muted` | `#E6F7F6` | muted surface |
| `--surface-deeper` | `#D8F6F5` | deeper surface |
| `--white` | `#FFFFFF` | |
| `--text-primary` | `#0B2231` | body text |
| `--text-secondary` | `#4A6472` | secondary text |
| `--text-tertiary` | `#7A8C97` | meta / muted text |
| `--text-on-dark` | `#F2FCFB` | text on dark/gradient |
| `--border` | `#CFE7E6` | hairline border |
| `--border-strong` | `#A8D4D2` | stronger border |
| `--success` | `#1AA38C` | |
| `--warning` | `#B87911` | |
| `--error` | `#C84D5B` | |

## Gradients
- `--gradient-hero`: `linear-gradient(135deg, #F2FCFB 0%, #E6F7F6 42%, #D8F6F5 100%)`
- `--gradient-cta`: `linear-gradient(135deg, #0A6C8C 0%, #0C7AA0 100%)`
- `--gradient-aqua`: `linear-gradient(135deg, #14C8D8 0%, #7BE6D5 100%)`
- `--gradient-pro`: `linear-gradient(135deg, #062B45 0%, #0A6C8C 100%)`

## Radii / shadows / motion
- Radii: `--radius-sm 14px`, `--radius-md 20px`, `--radius-lg 28px`, `--radius-pill 999px`
- Shadows: `--shadow-sm`, `--shadow-card`, `--shadow-lg`, `--shadow-cta`
  (all tinted `rgba(6,43,69,…)` / cta `rgba(10,108,140,.28)`)
- Easing: `--ease: cubic-bezier(0.22, 1, 0.36, 1)`
- `theme-color` meta: `#062B45`; `color-scheme: light` (no dark variant on site)

## Pages currently on the site
- `/` (home), `/sss` (FAQ), `/iletisim` or contact, `/sartlar.html` (Terms),
  `/gizlilik.html` (TR privacy), `/privacy/{en,de,fr,es,ru,it}.html` (privacy),
  assets: `/logo.png`, `/favicon.png`, `/apple-touch-icon.png`.
- Privacy is **7-language** (TR/EN/DE/FR/ES/RU/IT), KVKK (Law 6698) + GDPR.

## Relationship to the app brand
The app's own brand marks live in `nuveli/logo/` (water-flourish wordmark,
512² icon, 1024×500 feature graphic). The website palette above is consistent
with those (teal/aqua). Keep store assets, app theme, and website in the same
palette family.
