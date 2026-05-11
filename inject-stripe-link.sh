#!/usr/bin/env bash
# Usage: ./inject-stripe-link.sh https://buy.stripe.com/xxxxxxxxxxxx
# Replaces the placeholder Stripe URL in index.html with the real founding-member link,
# then (optionally) redeploys. Run after creating the Payment Link (see create-stripe-link.sh).
set -euo pipefail
LINK="${1:?Pass the Stripe Payment Link / Checkout URL as the first argument}"
case "$LINK" in https://*) ;; *) echo "Refusing: link must start with https://"; exit 1;; esac
PLACEHOLDER="https://buy.stripe.com/REPLACE_WITH_FOUNDING_LINK"
grep -q "$PLACEHOLDER" index.html || { echo "Placeholder not found — already injected?"; exit 1; }
# portable in-place sed
tmp="$(mktemp)"; sed "s|$PLACEHOLDER|$LINK|g" index.html > "$tmp" && mv "$tmp" index.html
echo "Injected $LINK into $(grep -c "$LINK" index.html) CTA(s) in index.html."
echo "Now redeploy:  git add index.html && git commit -m 'wire founding Stripe link' && git push    (GitHub Pages)"
echo "          or:  vercel --prod --yes --token \$VERCEL_TOKEN                                     (Vercel)"
