-- Defensive backfill for auth-scoped report ownership fields.
alter table public.tree_reports
  add column if not exists user_id uuid references auth.users (id);

create index if not exists tree_reports_user_id_idx
  on public.tree_reports (user_id);

notify pgrst, 'reload schema';
