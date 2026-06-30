alter table public.ingredients
add column if not exists created_by uuid references auth.users(id);

alter table public.ingredients
add column if not exists is_user_created boolean not null default true;

alter table public.ingredients
alter column created_at set default now();

update public.ingredients
set is_user_created = false
where created_by is null;

drop policy if exists "Allow authenticated insert ingredients" on public.ingredients;
create policy "Allow authenticated insert ingredients"
on public.ingredients
for insert
to authenticated
with check (
  created_by = auth.uid()
  and is_user_created = true
);
