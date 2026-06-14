create policy "Allow authenticated read ingredients"
on public.ingredients
for select
to authenticated
using (true);

create policy "Allow authenticated read recipes"
on public.recipes
for select
to authenticated
using (true);

create policy "Allow authenticated read recipe ingredients"
on public.recipe_ingredients
for select
to authenticated
using (true);

create policy "Allow authenticated read recipe steps"
on public.recipe_steps
for select
to authenticated
using (true);
