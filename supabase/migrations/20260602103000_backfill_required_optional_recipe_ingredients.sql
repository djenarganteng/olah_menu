update public.recipe_ingredients ri
set is_required = case
  when r.name = 'Nasi Goreng Telur' and i.name in ('Nasi', 'Telur', 'Bawang Merah', 'Garam', 'Minyak Goreng') then true
  when r.name = 'Nasi Goreng Telur' then false
  when r.name = 'Telur Dadar Cabai' and i.name in ('Telur', 'Bawang Merah', 'Garam', 'Minyak Goreng') then true
  when r.name = 'Telur Dadar Cabai' then false
  when r.name = 'Tahu Goreng Bumbu' and i.name in ('Tahu', 'Bawang Putih', 'Garam', 'Minyak Goreng') then true
  when r.name = 'Tahu Goreng Bumbu' then false
  when r.name = 'Mie Goreng Sayur' and i.name in ('Mie', 'Bawang Putih', 'Minyak Goreng') then true
  when r.name = 'Mie Goreng Sayur' then false
  when r.name = 'Sup Ayam Wortel' and i.name in ('Ayam', 'Wortel', 'Bawang Merah', 'Bawang Putih', 'Garam') then true
  when r.name = 'Sup Ayam Wortel' then false
  when r.name = 'Tempe Orek' and i.name in ('Tempe', 'Bawang Merah', 'Bawang Putih', 'Minyak Goreng') then true
  when r.name = 'Tempe Orek' then false
  when r.name = 'Tumis Sawi Bakso' and i.name in ('Sawi', 'Bakso', 'Bawang Putih', 'Garam', 'Minyak Goreng') then true
  when r.name = 'Tumis Sawi Bakso' then false
  when r.name = 'Perkedel Kentang' and i.name in ('Kentang', 'Telur', 'Bawang Putih', 'Garam', 'Minyak Goreng') then true
  when r.name = 'Perkedel Kentang' then false
  else ri.is_required
end
from public.recipes r, public.ingredients i
where ri.recipe_id = r.id
  and ri.ingredient_id = i.id;
