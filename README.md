# MatriX

MatriX is a construction and industrial resource management platform for project teams, warehouses, procurement teams, and factory operations.

## What is included

- Operations dashboard with project health, material flow, approvals, and advisory AI signals
- Construction projects, sites, material requests, approvals, and issue workflows
- Shared inventory and warehouse views with ledger-oriented data modeling
- Construction waste capture with disposition, cost, and approval tracking
- Procurement and supplier performance views
- Industrial production orders, material readiness, quality holds, and output reporting
- Reports, CSV exports, subscription plans, and server-oriented entitlement rules
- Supabase Auth integration boundaries for email/password and Google OAuth
- PostgreSQL migration with organization isolation, RBAC, subscriptions, inventory ledger, audit logs, and RLS policies

## Run locally

Requirements: Node.js 20+ and npm.

```bash
npm install
copy .env.example .env.local
npm run dev
```

Open [http://localhost:3000](http://localhost:3000). The console starts with local preview data and persists workflow changes in browser storage, so it can be reviewed without external credentials.

## Configure Supabase

Add these values to `.env.local` for live authentication and persistence:

```env
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

Apply the database files in order:

1. `supabase/migrations/0001_matrix_schema.sql`
2. `supabase/seed.sql` in a non-production project

Enable email/password authentication and Google OAuth in Supabase Auth. Keep service-role keys server-only. Configure private Storage buckets for waste evidence, reports, invoices, and inspection files before enabling uploads in production.

## Quality checks

```bash
npm run lint
npm run typecheck
npm run test
npm run build
```

The CI workflow in `.github/workflows/ci.yml` runs type checking, unit tests, and the production build.

## Deployment

MatriX is designed for Vercel + Supabase. Set the public Supabase URL/key and app URL in Vercel, apply migrations before the first production release, configure Supabase Auth redirect URLs, and verify authentication, RLS, inventory posting, private Storage access, and plan entitlements in Preview before promoting to Production.

Checkout is intentionally disabled until a billing provider is selected. The subscription screen provides an upgrade-request workflow without claiming payment completion.

## Repository structure

```text
src/app/                 Next.js App Router pages and auth callback
src/components/          Responsive MatriX operations console
src/lib/                 Demo data, entitlements, CSV, and Supabase clients
src/types/               Domain types
supabase/migrations/     PostgreSQL schema, functions, indexes, and RLS
supabase/seed.sql        Idempotent non-production catalog seed
tests/                   Unit tests
```
