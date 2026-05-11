-- ============================================================================
-- ContractorKit — Supabase init for the pre-sell validation landing page
-- Run in the SQL editor:
--   https://supabase.com/dashboard/project/otiwvsflpcambhoqkqfw/sql/new
-- or:  supabase db execute --project-ref otiwvsflpcambhoqkqfw < supabase-init.sql
--
-- SECURITY MODEL
--   anon (the key shipped in index.html) may ONLY:
--     • INSERT into contractorkit_signups   (email capture)
--     • INSERT into contractorkit_analytics (page-view / cta telemetry)
--     • SELECT the single config row contractorkit_founding_spots_remaining
--   anon may NOT SELECT signups/analytics rows back (no email/PII harvesting).
--   The Pre-Sell Validator reads counts via the SECURITY DEFINER RPCs at the
--   bottom (callable by anon, but they return only aggregate numbers).
-- ============================================================================

create extension if not exists "pgcrypto";

-- ---------- config (live counters) ----------
create table if not exists public.config (
  key   text primary key,
  value text not null,
  updated_at timestamptz not null default now()
);

insert into public.config (key, value)
values ('contractorkit_founding_spots_remaining', '50')
on conflict (key) do nothing;

alter table public.config enable row level security;
drop policy if exists "config: anon read" on public.config;
create policy "config: anon read" on public.config
  for select to anon using (true);
-- No INSERT/UPDATE/DELETE policy for anon → the counter can only be changed by
-- the service role (Stripe webhook / Validator / owner).

-- ---------- contractorkit_signups (email capture) ----------
create table if not exists public.contractorkit_signups (
  id         uuid primary key default gen_random_uuid(),
  email      text not null,
  product    text not null default 'contractorkit',
  source     text,
  created_at timestamptz not null default now()
);
create unique index if not exists contractorkit_signups_email_uniq
  on public.contractorkit_signups (lower(email));

alter table public.contractorkit_signups enable row level security;
drop policy if exists "signups: anon insert" on public.contractorkit_signups;
create policy "signups: anon insert" on public.contractorkit_signups
  for insert to anon with check (
    product = 'contractorkit'
    and email ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$'
    and length(email) <= 254
  );
-- No SELECT policy for anon → emails are not readable with the public key.

-- ---------- contractorkit_analytics (page-view / cta telemetry) ----------
create table if not exists public.contractorkit_analytics (
  id         bigint generated always as identity primary key,
  product    text not null default 'contractorkit',
  event      text not null default 'page_view',
  path       text,
  referrer   text,
  ua         text,
  created_at timestamptz not null default now()
);
create index if not exists contractorkit_analytics_created_at_idx
  on public.contractorkit_analytics (created_at);

alter table public.contractorkit_analytics enable row level security;
drop policy if exists "analytics: anon insert" on public.contractorkit_analytics;
create policy "analytics: anon insert" on public.contractorkit_analytics
  for insert to anon with check (product = 'contractorkit' and length(coalesce(ua,'')) <= 300);
-- No SELECT policy for anon.

-- ---------- RPCs the Pre-Sell Validator calls (aggregate reads only) ----------
create or replace function public.contractorkit_signup_count()
  returns bigint language sql security definer set search_path = public as
$$ select count(*)::bigint from public.contractorkit_signups $$;

create or replace function public.contractorkit_pageview_count()
  returns bigint language sql security definer set search_path = public as
$$ select count(*)::bigint from public.contractorkit_analytics where event = 'page_view' $$;

create or replace function public.contractorkit_founding_spots_remaining()
  returns int language sql security definer set search_path = public as
$$ select coalesce((select value::int from public.config
                    where key = 'contractorkit_founding_spots_remaining'), 50) $$;

grant execute on function public.contractorkit_signup_count()              to anon, authenticated;
grant execute on function public.contractorkit_pageview_count()            to anon, authenticated;
grant execute on function public.contractorkit_founding_spots_remaining()  to anon, authenticated;

-- ---------- Optional: decrement the counter on each founding checkout ----------
-- Wire a Stripe webhook (checkout.session.completed where metadata.product='contractorkit')
-- to call this with the service-role key:
create or replace function public.contractorkit_take_founding_spot()
  returns int language plpgsql security definer set search_path = public as
$$
declare v int;
begin
  update public.config
     set value = greatest(0, (value::int) - 1)::text, updated_at = now()
   where key = 'contractorkit_founding_spots_remaining'
   returning value::int into v;
  return v;
end $$;
revoke all on function public.contractorkit_take_founding_spot() from anon, authenticated;
-- (only the service role may call it)

-- ============================================================================
-- SMOKE TEST (run these from a shell after applying — the brief's deliverable #4):
--   SUPA=https://otiwvsflpcambhoqkqfw.supabase.co
--   ANON=<the anon JWT, role=anon>
--   # counter readable?
--   curl -s "$SUPA/rest/v1/config?select=value&key=eq.contractorkit_founding_spots_remaining" -H "apikey: $ANON" -H "Authorization: Bearer $ANON"
--   # anon can INSERT a signup?
--   curl -s -X POST "$SUPA/rest/v1/contractorkit_signups" -H "apikey: $ANON" -H "Authorization: Bearer $ANON" -H "Content-Type: application/json" -H "Prefer: return=minimal" -d '{"email":"smoketest@example.com","product":"contractorkit","source":"smoketest"}'
--   # Validator can COUNT (RPC)?
--   curl -s -X POST "$SUPA/rest/v1/rpc/contractorkit_signup_count"   -H "apikey: $ANON" -H "Authorization: Bearer $ANON" -H "Content-Type: application/json" -d '{}'
--   curl -s -X POST "$SUPA/rest/v1/rpc/contractorkit_pageview_count" -H "apikey: $ANON" -H "Authorization: Bearer $ANON" -H "Content-Type: application/json" -d '{}'
--   # anon must NOT be able to read emails back (expect [] or 401/permission error):
--   curl -s "$SUPA/rest/v1/contractorkit_signups?select=email" -H "apikey: $ANON" -H "Authorization: Bearer $ANON"
--   # cleanup the smoke-test row (service role only):
--   -- delete from public.contractorkit_signups where source = 'smoketest';
-- ============================================================================
