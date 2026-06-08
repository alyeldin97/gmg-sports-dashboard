# GMG Sports — Admin Dashboard

Flutter admin dashboard for the **GMG Sports** gear store, backed by Supabase.
Web/desktop layout with a side navigation. Supports **English + Arabic (RTL)**.

> Companion customer app: **gmg-sports-app** (contains the shared `supabase/schema.sql`).
> Both apps must point at the **same** Supabase project.

## Features
- **Admin-only login** — non-admin accounts (`profiles.is_admin = false`) are rejected
- **Overview** — order / pending / revenue / product stats
- **Products** CRUD — variants editor, multi-collection assignment, featured/active toggles
- **Collections** & **Banners** CRUD (banners support collection/product deep-links)
- **Orders** — list, details, and **status updates** that drive the customer tracking timeline
- **Settings** — delivery fee, free-delivery threshold, InstaPay handle

## Stack
`flutter_bloc` (Cubit) · `supabase_flutter` · `google_fonts` ·
feature-first clean architecture (Cubit → Repository → DataSource → Supabase).

## Getting started
1. Use the same Supabase project as the customer app (run its `supabase/schema.sql`).
2. Promote an admin: `update public.profiles set is_admin = true where email = '…';`
3. Put your project URL + anon key in `lib/core/utils/configurations.dart`
   (currently **dummy placeholders**).
4. `flutter pub get && flutter run -d chrome`
