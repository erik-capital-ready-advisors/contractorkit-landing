#!/usr/bin/env bash
# Creates the ContractorKit founding-member Stripe Payment Link ($29, first month).
# Requires: STRIPE_SECRET_KEY in env, outbound access to api.stripe.com (BLOCKED in the
# Designer Agent's container — that's why a human runs this).
# It prints the URL; pipe it straight into inject-stripe-link.sh.
set -euo pipefail
: "${STRIPE_SECRET_KEY:?Set STRIPE_SECRET_KEY}"
api() { curl -s https://api.stripe.com/v1/"$1" -u "$STRIPE_SECRET_KEY:" "${@:2}"; }

PRODUCT_ID=$(api products -d "name=ContractorKit — Founding Member" \
  -d "description=Founding-member access: W-9 + NDA + IP-assignment + payment capture, unlimited contractors. \$29/mo locked forever." \
  | python3 -c "import sys,json;print(json.load(sys.stdin)['id'])")
echo "product: $PRODUCT_ID" >&2

# $29/month recurring; the Payment Link will charge the first month today.
PRICE_ID=$(api prices -d "product=$PRODUCT_ID" -d "unit_amount=2900" -d "currency=usd" \
  -d "recurring[interval]=month" \
  | python3 -c "import sys,json;print(json.load(sys.stdin)['id'])")
echo "price: $PRICE_ID" >&2

LINK_JSON=$(api payment_links \
  -d "line_items[0][price]=$PRICE_ID" -d "line_items[0][quantity]=1" \
  -d "metadata[product]=contractorkit" -d "metadata[tier]=founding" \
  -d "metadata[campaign]=presell-2026-05" \
  -d "subscription_data[metadata][product]=contractorkit" \
  -d "subscription_data[metadata][tier]=founding" \
  -d "allow_promotion_codes=false" \
  -d "after_completion[type]=hosted_confirmation" \
  -d "after_completion[hosted_confirmation][custom_message]=You're a ContractorKit founding member. We'll email you the moment v1 is live (target early June 2026). Full refund if we don't ship within 4 weeks.")
echo "$LINK_JSON" | python3 -c "import sys,json;d=json.load(sys.stdin);print(d.get('url') or d)"
