create table if not exists public.user_favorite_recipes (
  user_id uuid not null references auth.users(id) on delete cascade,
  recipe_id bigint not null references public.recipes(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, recipe_id)
);

create index if not exists user_favorite_recipes_user_created_idx
  on public.user_favorite_recipes (user_id, created_at desc);

alter table public.user_favorite_recipes enable row level security;

drop policy if exists "Users can read own favorite recipes"
on public.user_favorite_recipes;
create policy "Users can read own favorite recipes"
on public.user_favorite_recipes
for select
to authenticated
using (auth.uid() = user_id);

drop policy if exists "Users can insert own favorite recipes"
on public.user_favorite_recipes;
create policy "Users can insert own favorite recipes"
on public.user_favorite_recipes
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "Users can update own favorite recipes"
on public.user_favorite_recipes;
create policy "Users can update own favorite recipes"
on public.user_favorite_recipes
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users can delete own favorite recipes"
on public.user_favorite_recipes;
create policy "Users can delete own favorite recipes"
on public.user_favorite_recipes
for delete
to authenticated
using (auth.uid() = user_id);

create table if not exists public.user_favorite_ai_recipes (
  user_id uuid not null references auth.users(id) on delete cascade,
  recipe_id text not null,
  title text not null,
  description text not null default '',
  cooking_time int not null default 0,
  servings int not null default 1,
  ingredients jsonb not null default '[]'::jsonb,
  steps jsonb not null default '[]'::jsonb,
  source text not null default 'gemini',
  created_at timestamptz not null default now(),
  primary key (user_id, recipe_id)
);

create index if not exists user_favorite_ai_recipes_user_created_idx
  on public.user_favorite_ai_recipes (user_id, created_at desc);

alter table public.user_favorite_ai_recipes enable row level security;

drop policy if exists "Users can read own favorite AI recipes"
on public.user_favorite_ai_recipes;
create policy "Users can read own favorite AI recipes"
on public.user_favorite_ai_recipes
for select
to authenticated
using (auth.uid() = user_id);

drop policy if exists "Users can insert own favorite AI recipes"
on public.user_favorite_ai_recipes;
create policy "Users can insert own favorite AI recipes"
on public.user_favorite_ai_recipes
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "Users can update own favorite AI recipes"
on public.user_favorite_ai_recipes;
create policy "Users can update own favorite AI recipes"
on public.user_favorite_ai_recipes
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users can delete own favorite AI recipes"
on public.user_favorite_ai_recipes;
create policy "Users can delete own favorite AI recipes"
on public.user_favorite_ai_recipes
for delete
to authenticated
using (auth.uid() = user_id);
