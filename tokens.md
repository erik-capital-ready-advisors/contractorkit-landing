# Design Tokens: ContractorKit Validation Landing Page
*Issued by Designer Agent — 2026-05-11. Source of truth for landing page, OG image, future emails, social assets.*

## Product context
- Category: B2B / Ops / People-ops tooling for marketing agencies
- Tone: confident, no-nonsense, "this is plumbing you should have had years ago"
- Direction from Pre-Sell Validator brief: clean, minimal, fast; emoji + typography only, NO images; dollar-math table mandatory and prominent; lead with audit-trail + template-library as ongoing value (not just onboarding speed).

## Color system
| Token | Hex | Use |
|---|---|---|
| `primary` (slate) | `#1f2933` | Headlines, dark surfaces, nav text, "result" panel, footer |
| `primary-700` | `#27313c` | Slightly lighter slate for gradients / hover on dark |
| `primary-tint` | `#f3f5f7` | Section background washes (alternating bands) |
| `accent` (green) | `#3ebd64` | ALL CTA buttons, "After" labels, checkmarks, live-dot, counter highlight |
| `accent-700` | `#34a857` | CTA hover/active |
| `bg` | `#ffffff` | Page background |
| `text` | `#1f2933` | Body text (= primary slate) |
| `text-muted` | `#5b6670` | Secondary copy |
| `text-faint` | `#8a929b` | Captions, strike-through, footer |
| `danger` | `#dc2626` | "Before" labels (used sparingly) |
| `border` | `#e5e8eb` | Card borders, dividers |

CTA contrast check: `#3ebd64` on white = 2.3:1 (large/bold button text only — white text ON the green button is the readable pair: white `#ffffff` on `#3ebd64` ≈ 2.4:1, so button label uses **bold 18px+** which passes WCAG AA for large text; non-button green text is only used at ≥18px bold). Headlines `#1f2933` on white = 14.5:1. ✓

## Typography
- Family: `Inter` (Google Fonts `wght@400;500;600;700;800`), fallback `system-ui, -apple-system, "Segoe UI", Roboto, sans-serif`
- Antialiased everywhere.

| Element | Desktop | Mobile |
|---|---|---|
| h1 | 56px / 1.05 / 800 / -0.02em | 34px / 1.1 |
| h2 | 36px / 1.15 / 700 | 28px |
| h3 | 22px / 1.3 / 600 | 20px |
| body | 18px / 1.7 / 400–500 | 17px / 1.6 |
| eyebrow/label | 13px / 600 / uppercase / 0.14em tracking | same |
| small/caption | 14px / 400 | 13px |

## Spacing
- Section vertical padding: 80px (desktop) / 48px (mobile)
- Container max-width: 1080px; inner content blocks 720–840px; horizontal page padding 24px
- Standard gap 24px; major separation 48px
- Pricing card / math-table card max-width: 640px (math table allowed to span 760px on desktop)

## Shape & elevation
- Border radius: 12px cards & buttons; 9999px pills/badges; 20–24px on the hero pricing card
- Card shadow: `0 4px 6px -1px rgba(15,23,32,0.08), 0 2px 4px -2px rgba(15,23,32,0.08)`
- CTA shadow: `0 8px 24px rgba(62,189,100,0.28)` on hover; lift `translateY(-1px)`
- Sticky nav: `bg-white/90` + `backdrop-blur` + 1px bottom border `#e5e8eb`

## Motion
- Buttons: `transform 0.15s ease, box-shadow 0.15s ease`
- Trust-badge dot: subtle pulse
- Counter: fade-up `countUp 0.6s ease` when populated from Supabase
- FAQ chevron: `rotate-180` on `[open]`, 200ms

## Layout rules (non-negotiable)
1. ZERO navigation links. Nav has product name (left) + single CTA pill (right). Nothing else.
2. NO external images. Emoji, CSS gradients, inline SVG favicon only. (OG image is the one rendered PNG, hosted alongside the page.)
3. CTA copy is fixed: **"Reserve a Founding Spot — $29/mo"** (verbatim from brief). Appears in nav, hero, pricing card, final CTA.
4. Mobile: every CTA is full-width. Tested at 375px.
5. The Section-5 dollar-math table is the visual centerpiece of the pricing section — full card, prominent, ContractorKit row highlighted in slate with the green price.
6. Section 3 bullet #2 (audit trail) and the Section 4 "it stays done" step get visual emphasis (badge/icon/contrasting card) — ongoing value, not just onboarding speed.

## Asset dimensions (for this run + future asset-pack run)
- `og-image.png`: 1200×628, slate→slate-700 gradient bg, white type, green accent badge + price
- favicon: inline SVG emoji `📋`
