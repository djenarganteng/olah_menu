alter table public.recipe_ingredients
add column if not exists is_required boolean not null default true;

create index if not exists idx_recipe_ingredients_recipe_required
on public.recipe_ingredients(recipe_id, is_required);
