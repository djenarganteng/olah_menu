alter table public.ingredients
add column if not exists sort_order integer not null default 9999;

update public.ingredients
set sort_order = case name
  when 'Wortel' then 1
  when 'Tempe' then 2
  when 'Telur' then 3
  when 'Sawi' then 4
  when 'Minyak Goreng' then 5
  when 'Nasi' then 6
  when 'Kentang' then 7
  when 'Ayam' then 8
  when 'Tahu' then 9
  when 'Brokoli' then 10
  when 'Kol' then 11
  when 'Mie' then 12
  when 'Kecap' then 13
  when 'Garam' then 14
  when 'Cabai' then 15
  when 'Bawang Putih' then 16
  when 'Bawang Merah' then 17
  when 'Bakso' then 18
  when 'Daun Bawang' then 19
  else 9999
end;

create index if not exists ingredients_sort_order_idx
  on public.ingredients(sort_order, name);
