create extension if not exists pgcrypto;

create table if not exists public.ai_generated_recipes (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text not null default '',
  cooking_time integer not null default 0 check (cooking_time >= 0),
  servings integer not null default 1 check (servings > 0),
  ingredients_json jsonb not null default '[]'::jsonb,
  steps_json jsonb not null default '[]'::jsonb,
  selected_ingredients_json jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);

do $$
begin
  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'ai_generated_recipes'
      and column_name = 'id'
      and data_type <> 'uuid'
  ) then
    alter table public.ai_generated_recipes drop constraint if exists ai_generated_recipes_pkey;
    alter table public.ai_generated_recipes add column if not exists uuid_id uuid default gen_random_uuid();
    update public.ai_generated_recipes set uuid_id = gen_random_uuid() where uuid_id is null;
    alter table public.ai_generated_recipes alter column uuid_id set not null;
    alter table public.ai_generated_recipes drop column id;
    alter table public.ai_generated_recipes rename column uuid_id to id;
    alter table public.ai_generated_recipes add primary key (id);
  end if;
end $$;

alter table public.ai_generated_recipes
  add column if not exists title text not null default '',
  add column if not exists description text not null default '',
  add column if not exists cooking_time integer not null default 0,
  add column if not exists servings integer not null default 1,
  add column if not exists ingredients_json jsonb not null default '[]'::jsonb,
  add column if not exists steps_json jsonb not null default '[]'::jsonb,
  add column if not exists selected_ingredients_json jsonb not null default '[]'::jsonb,
  add column if not exists created_at timestamptz not null default now();

alter table public.ai_generated_recipes
  alter column id set default gen_random_uuid();

alter table public.ai_generated_recipes
  drop column if exists selected_ingredients_key;

-- Normalize any existing cache rows so equality lookup is stable.
update public.ai_generated_recipes
set selected_ingredients_json = coalesce(
  (
    select jsonb_agg(value order by value)
    from (
      select distinct lower(trim(value)) as value
      from jsonb_array_elements_text(selected_ingredients_json)
      where trim(value) <> ''
    ) normalized
  ),
  '[]'::jsonb
);

create unique index if not exists ai_generated_recipes_selected_ingredients_json_key
  on public.ai_generated_recipes (selected_ingredients_json);

create index if not exists ai_generated_recipes_created_at_idx
  on public.ai_generated_recipes (created_at desc);

alter table public.ai_generated_recipes enable row level security;
