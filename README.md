# ContractorKit — Pre-Sell Validation Landing Page

Static, self-contained landing page (one `index.html`, Tailwind via CDN, Inter via Google Fonts, emoji-only — no image dependencies except the rendered `og-image.png`). Built by the Designer Agent on 2026-05-11 from `pipeline/validated/contractorkit-designer-brief.md`.

## Status

| Piece | State |
|---|---|
| Landing page HTML | ✅ Built — all 7 sections, copy verbatim, the dollar-math table is the centerpiece of §5, audit-trail emphasized in §3/§4 |
| OG image (1200×628) | ✅ Rendered → `og-image.png` (~300 KB) |
| Supabase client wiring | ✅ Anon key embedded (role=`anon`, RLS-protected); page-view telemetry + email capture + live spots-counter all wired |
| Supabase schema | ⚠️ **Not yet applied** — run `supabase-init.sql` (creates `config`, `contractorkit_signups`, `contractorkit_analytics` + the Validator's count RPCs) |
| Deployment | ⚠️ **GitHub Pages attempted from the build container** — see `pipeline/validated/contractorkit-page-live.md` for the live URL / status. Vercel + Stripe + Supabase hosts are blocked by the container's network allowlist, so those steps need a human or a networked CI runner. |
| Stripe founding link | ❌ **Not created** — `api.stripe.com` is blocked in the build container. The 3 primary CTAs currently point to `https://buy.stripe.com/REPLACE_WITH_FOUNDING_LINK`. **Do not drive paid traffic until this is replaced.** Run `create-stripe-link.sh` then `inject-stripe-link.sh <url>` (≈30 seconds). |

## Finish & ship (run on any machine with normal outbound network)

```bash
git clone https://github.com/erik-capital-ready-advisors/contractorkit-landing.git
cd contractorkit-landing

# 1) Supabase: paste supabase-init.sql into
#    https://supabase.com/dashboard/project/otiwvsflpcambhoqkqfw/sql/new
#    (or)  supabase db execute --project-ref otiwvsflpcambhoqkqfw < supabase-init.sql
#    Then run the SMOKE TEST block at the bottom of supabase-init.sql — all four
#    checks (counter readable / anon INSERT / Validator COUNT RPC / page-views) must pass.
#    This is the ReportPilot failure mode — do not skip it.

# 2) Stripe: create the $29 founding Payment Link and wire it in
export STRIPE_SECRET_KEY=...        # the live key in the brain env
LINK=$(./create-stripe-link.sh)     # prints https://buy.stripe.com/xxxx  (metadata product=contractorkit, tier=founding)
./inject-stripe-link.sh "$LINK"

# 3a) Deploy via GitHub Pages (already attempted by the agent — push to update):
git add index.html && git commit -m "wire founding Stripe link" && git push
#     URL: https://erik-capital-ready-advisors.github.io/contractorkit-landing/
#     (Settings → Pages → Source: "Deploy from a branch", branch=main, folder=/(root) if not already on)

# 3b) …or deploy via Vercel instead:
export VERCEL_TOKEN=...
./deploy-vercel.sh

# 4) Verify (all four — the brief's deliverable #4):
curl -sI https://<live-url>/                | head -1   # 200
curl -sI https://<live-url>/og-image.png    | head -1   # 200, image/png
#   counter readable by the Validator:
curl -s "https://otiwvsflpcambhoqkqfw.supabase.co/rest/v1/rpc/contractorkit_founding_spots_remaining" \
  -H "apikey: $SUPABASE_ANON_KEY" -H "Authorization: Bearer $SUPABASE_ANON_KEY" -X POST -H "Content-Type: application/json" -d '{}'
#   page-view telemetry readable by the Validator:
curl -s "https://otiwvsflpcambhoqkqfw.supabase.co/rest/v1/rpc/contractorkit_pageview_count" \
  -H "apikey: $SUPABASE_ANON_KEY" -H "Authorization: Bearer $SUPABASE_ANON_KEY" -X POST -H "Content-Type: application/json" -d '{}'
#   Stripe checkout reachable + queryable: open $LINK (should hit Stripe, not 404),
#   then `stripe payment_links list` / dashboard → confirm metadata product=contractorkit.
```

## ⚠️ Heads-up on the Supabase env var

The brain env's `SUPABASE_ANON_KEY` value is **contaminated** — it contains the anon JWT *immediately followed by* `SUPABASE_SERVICE_ROLE_KEY=sb_secret_...` with no separator (looks like two `.env` lines got joined). The Designer Agent stripped everything from `SUPABASE_SERVICE_ROLE_KEY` onward before embedding the anon JWT, so **no service-role secret is in `index.html` or this repo**. But the env var should be fixed at the source, and that service-role secret should be treated as exposed/rotated since it's been sitting in a shared env string.

## Files
- `index.html` — the page (33 KB)
- `og-image.png` / `og-image.html` — social preview + its source
- `404.html`, `.nojekyll` — GitHub Pages plumbing
- `vercel.json`, `package.json` — Vercel static-deploy config
- `supabase-init.sql` — schema + RLS + Validator count RPCs + smoke-test block
- `create-stripe-link.sh` — creates the $29 founding Payment Link via the Stripe API
- `inject-stripe-link.sh` — swaps the placeholder CTA URL for the real one
- `deploy-vercel.sh` — alt deploy path
- `tokens.md` — the design tokens this page (and future ContractorKit assets) are built on

## Design notes (for the future asset-pack run)
- Primary slate `#1f2933`, CTA green `#3ebd64`. Inter. 12 px radius, pill badges, soft shadows.
- Zero nav links (only the CTA). No external images. Mobile CTAs are full-width. Built mobile-first; structure verified, but the *styled* render couldn't be screenshotted from the build container because `cdn.tailwindcss.com` is allowlist-blocked there — eyeball it at 375 px once live.
