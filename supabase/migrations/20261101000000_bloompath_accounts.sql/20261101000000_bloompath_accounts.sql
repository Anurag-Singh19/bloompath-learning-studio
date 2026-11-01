-- Bloompath accounts and cross-device progress storage.
-- Run this migration in Supabase SQL Editor before enabling account sign-up.
create table if not exists public.bloompath_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.bloompath_user_progress (
  user_id uuid primary key references auth.users(id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  constraint bloompath_progress_object check (jsonb_typeof(data) = 'object')
);
-- Add owner UUIDs with SQL Editor only; browser clients have no write policy.
create table if not exists public.bloompath_admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);
alter table public.bloompath_profiles enable row level security;
alter table public.bloompath_user_progress enable row level security;
alter table public.bloompath_admins enable row level security;
revoke all on public.bloompath_profiles from anon, authenticated;
revoke all on public.bloompath_user_progress from anon, authenticated;
revoke all on public.bloompath_admins from anon, authenticated;
grant select, insert, update on public.bloompath_profiles to authenticated;
grant select, insert, update, delete on public.bloompath_user_progress to authenticated;
grant select on public.bloompath_admins to authenticated;
drop policy if exists "profiles_select_self" on public.bloompath_profiles;
drop policy if exists "profiles_insert_self" on public.bloompath_profiles;
drop policy if exists "profiles_update_self" on public.bloompath_profiles;
drop policy if exists "profiles_admin_select" on public.bloompath_profiles;
drop policy if exists "progress_owner_all" on public.bloompath_user_progress;
drop policy if exists "progress_admin_all" on public.bloompath_user_progress;
drop policy if exists "admins_select_self" on public.bloompath_admins;
create policy "profiles_select_self" on public.bloompath_profiles for select to authenticated using ((select auth.uid()) = id);
create policy "profiles_insert_self" on public.bloompath_profiles for insert to authenticated with check ((select auth.uid()) = id);
create policy "profiles_update_self" on public.bloompath_profiles for update to authenticated using ((select auth.uid()) = id) with check ((select auth.uid()) = id);
create policy "profiles_admin_select" on public.bloompath_profiles for select to authenticated using (exists (select 1 from public.bloompath_admins a where a.user_id = (select auth.uid())));
create policy "progress_owner_all" on public.bloompath_user_progress for all to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "progress_admin_all" on public.bloompath_user_progress for all to authenticated using (exists (select 1 from public.bloompath_admins a where a.user_id = (select auth.uid()))) with check (exists (select 1 from public.bloompath_admins a where a.user_id = (select auth.uid())));
create policy "admins_select_self" on public.bloompath_admins for select to authenticated using ((select auth.uid()) = user_id);
comment on table public.bloompath_profiles is 'Account email/profile records. Readable by the account owner and allowlisted site admins.';
comment on table public.bloompath_user_progress is 'Per-account Bloompath checklist, reminders, flashcards and resume draft data.';
comment on table public.bloompath_admins is 'Owner allowlist. Add owner UUID with SQL Editor; clients cannot write this table.';
