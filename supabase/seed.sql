truncate table public.recipe_steps restart identity cascade;
truncate table public.recipe_ingredients restart identity cascade;
truncate table public.recipes restart identity cascade;
truncate table public.ingredients restart identity cascade;

insert into public.ingredients (name, category, sort_order, image_url) values
  ('Wortel', 'Sayur', 1, 'https://nvbaxhlexcfaahmzeauq.supabase.co/storage/v1/object/public/ingredient-images/ingredients/wortel.jpg'),
  ('Tempe', 'Protein', 2, 'https://nvbaxhlexcfaahmzeauq.supabase.co/storage/v1/object/public/ingredient-images/ingredients/tempe.jpg'),
  ('Telur', 'Protein', 3, 'https://nvbaxhlexcfaahmzeauq.supabase.co/storage/v1/object/public/ingredient-images/ingredients/telur.jpg'),
  ('Sawi', 'Sayur', 4, 'https://nvbaxhlexcfaahmzeauq.supabase.co/storage/v1/object/public/ingredient-images/ingredients/sawi.jpg'),
  ('Minyak Goreng', 'Bahan Dasar', 5, 'https://nvbaxhlexcfaahmzeauq.supabase.co/storage/v1/object/public/ingredient-images/ingredients/minyak_goreng.jpg'),
  ('Nasi', 'Karbohidrat', 6, 'https://nvbaxhlexcfaahmzeauq.supabase.co/storage/v1/object/public/ingredient-images/ingredients/nasi.jpg'),
  ('Kentang', 'Carb', 7, 'https://nvbaxhlexcfaahmzeauq.supabase.co/storage/v1/object/public/ingredient-images/ingredients/kentang.jpg'),
  ('Ayam', 'Protein', 8, 'https://nvbaxhlexcfaahmzeauq.supabase.co/storage/v1/object/public/ingredient-images/ingredients/ayam.jpg'),
  ('Tahu', 'Sayur/Bumbu', 9, 'https://nvbaxhlexcfaahmzeauq.supabase.co/storage/v1/object/public/ingredient-images/ingredients/tahu.jpg'),
  ('Brokoli', 'Vegetable', 10, 'https://nvbaxhlexcfaahmzeauq.supabase.co/storage/v1/object/public/ingredient-images/ingredients/brokoli.jpg'),
  ('Kol', 'Sayur', 11, 'https://nvbaxhlexcfaahmzeauq.supabase.co/storage/v1/object/public/ingredient-images/ingredients/kol.jpg'),
  ('Mie', 'Karbohidrat', 12, 'https://nvbaxhlexcfaahmzeauq.supabase.co/storage/v1/object/public/ingredient-images/ingredients/mie.jpg'),
  ('Kecap', 'Bumbu', 13, 'https://nvbaxhlexcfaahmzeauq.supabase.co/storage/v1/object/public/ingredient-images/ingredients/kecap.jpg'),
  ('Garam', 'Bumbu', 14, 'https://nvbaxhlexcfaahmzeauq.supabase.co/storage/v1/object/public/ingredient-images/ingredients/garam.jpg'),
  ('Cabai', 'Sayur/Bumbu', 15, 'https://nvbaxhlexcfaahmzeauq.supabase.co/storage/v1/object/public/ingredient-images/ingredients/cabai.jpg'),
  ('Bawang Putih', 'Bumbu', 16, 'https://nvbaxhlexcfaahmzeauq.supabase.co/storage/v1/object/public/ingredient-images/ingredients/bawang_putih.jpg'),
  ('Bawang Merah', 'Bumbu', 17, 'https://nvbaxhlexcfaahmzeauq.supabase.co/storage/v1/object/public/ingredient-images/ingredients/bawang_merah.jpg'),
  ('Bakso', 'Protein', 18, 'https://nvbaxhlexcfaahmzeauq.supabase.co/storage/v1/object/public/ingredient-images/ingredients/bakso.jpg'),
  ('Daun Bawang', 'Sayur', 19, 'https://nvbaxhlexcfaahmzeauq.supabase.co/storage/v1/object/public/ingredient-images/ingredients/daun_bawang.jpg');

insert into public.recipes (name, description, image_url, default_serving, cooking_time) values
  ('Nasi Goreng Telur', 'Nasi goreng gurih dengan telur dan bumbu sederhana.', 'https://loremflickr.com/980/654/meal', 2, 20),
  ('Telur Dadar Cabai', 'Telur dadar pedas praktis untuk lauk cepat.', 'https://loremflickr.com/980/654/egg', 2, 15),
  ('Tahu Goreng Bumbu', 'Tahu goreng renyah dengan bumbu bawang dan kecap.', 'https://loremflickr.com/980/654/tofu', 2, 18),
  ('Mie Goreng Sayur', 'Mie goreng sederhana dengan sayur segar.', 'https://loremflickr.com/980/654/noodle', 2, 20),
  ('Sup Ayam Wortel', 'Sup hangat dengan ayam, wortel, dan kaldu ringan.', 'https://loremflickr.com/980/654/chicken', 3, 35),
  ('Tempe Orek', 'Tempe manis gurih dengan kecap dan bawang.', 'https://loremflickr.com/980/654/food', 3, 20),
  ('Tumis Sawi Bakso', 'Tumis sawi praktis dengan bakso dan bawang.', 'https://loremflickr.com/980/654/vegetable', 2, 18),
  ('Perkedel Kentang', 'Perkedel kentang lembut untuk lauk pendamping.', 'https://loremflickr.com/980/654/potato', 3, 30);

insert into public.recipe_ingredients (recipe_id, ingredient_id, amount, unit, is_required) values
  ((select id from public.recipes where name = 'Nasi Goreng Telur'), (select id from public.ingredients where name = 'Nasi'), 2, 'piring', true),
  ((select id from public.recipes where name = 'Nasi Goreng Telur'), (select id from public.ingredients where name = 'Telur'), 2, 'butir', true),
  ((select id from public.recipes where name = 'Nasi Goreng Telur'), (select id from public.ingredients where name = 'Bawang Merah'), 3, 'siung', true),
  ((select id from public.recipes where name = 'Nasi Goreng Telur'), (select id from public.ingredients where name = 'Bawang Putih'), 2, 'siung', false),
  ((select id from public.recipes where name = 'Nasi Goreng Telur'), (select id from public.ingredients where name = 'Cabai'), 2, 'buah', false),
  ((select id from public.recipes where name = 'Nasi Goreng Telur'), (select id from public.ingredients where name = 'Kecap'), 2, 'sdm', false),
  ((select id from public.recipes where name = 'Nasi Goreng Telur'), (select id from public.ingredients where name = 'Garam'), 0.5, 'sdt', true),
  ((select id from public.recipes where name = 'Nasi Goreng Telur'), (select id from public.ingredients where name = 'Minyak Goreng'), 2, 'sdm', true),

  ((select id from public.recipes where name = 'Telur Dadar Cabai'), (select id from public.ingredients where name = 'Telur'), 3, 'butir', true),
  ((select id from public.recipes where name = 'Telur Dadar Cabai'), (select id from public.ingredients where name = 'Cabai'), 3, 'buah', false),
  ((select id from public.recipes where name = 'Telur Dadar Cabai'), (select id from public.ingredients where name = 'Bawang Merah'), 2, 'siung', true),
  ((select id from public.recipes where name = 'Telur Dadar Cabai'), (select id from public.ingredients where name = 'Garam'), 0.5, 'sdt', true),
  ((select id from public.recipes where name = 'Telur Dadar Cabai'), (select id from public.ingredients where name = 'Minyak Goreng'), 2, 'sdm', true),

  ((select id from public.recipes where name = 'Tahu Goreng Bumbu'), (select id from public.ingredients where name = 'Tahu'), 4, 'potong', true),
  ((select id from public.recipes where name = 'Tahu Goreng Bumbu'), (select id from public.ingredients where name = 'Bawang Putih'), 2, 'siung', true),
  ((select id from public.recipes where name = 'Tahu Goreng Bumbu'), (select id from public.ingredients where name = 'Garam'), 0.5, 'sdt', true),
  ((select id from public.recipes where name = 'Tahu Goreng Bumbu'), (select id from public.ingredients where name = 'Kecap'), 1, 'sdm', false),
  ((select id from public.recipes where name = 'Tahu Goreng Bumbu'), (select id from public.ingredients where name = 'Minyak Goreng'), 3, 'sdm', true),

  ((select id from public.recipes where name = 'Mie Goreng Sayur'), (select id from public.ingredients where name = 'Mie'), 2, 'bungkus', true),
  ((select id from public.recipes where name = 'Mie Goreng Sayur'), (select id from public.ingredients where name = 'Kol'), 100, 'gram', false),
  ((select id from public.recipes where name = 'Mie Goreng Sayur'), (select id from public.ingredients where name = 'Sawi'), 100, 'gram', false),
  ((select id from public.recipes where name = 'Mie Goreng Sayur'), (select id from public.ingredients where name = 'Wortel'), 1, 'buah', false),
  ((select id from public.recipes where name = 'Mie Goreng Sayur'), (select id from public.ingredients where name = 'Bawang Putih'), 2, 'siung', true),
  ((select id from public.recipes where name = 'Mie Goreng Sayur'), (select id from public.ingredients where name = 'Kecap'), 2, 'sdm', false),
  ((select id from public.recipes where name = 'Mie Goreng Sayur'), (select id from public.ingredients where name = 'Minyak Goreng'), 2, 'sdm', true),

  ((select id from public.recipes where name = 'Sup Ayam Wortel'), (select id from public.ingredients where name = 'Ayam'), 250, 'gram', true),
  ((select id from public.recipes where name = 'Sup Ayam Wortel'), (select id from public.ingredients where name = 'Wortel'), 2, 'buah', true),
  ((select id from public.recipes where name = 'Sup Ayam Wortel'), (select id from public.ingredients where name = 'Kentang'), 2, 'buah', false),
  ((select id from public.recipes where name = 'Sup Ayam Wortel'), (select id from public.ingredients where name = 'Bawang Merah'), 3, 'siung', true),
  ((select id from public.recipes where name = 'Sup Ayam Wortel'), (select id from public.ingredients where name = 'Bawang Putih'), 2, 'siung', true),
  ((select id from public.recipes where name = 'Sup Ayam Wortel'), (select id from public.ingredients where name = 'Daun Bawang'), 1, 'batang', false),
  ((select id from public.recipes where name = 'Sup Ayam Wortel'), (select id from public.ingredients where name = 'Garam'), 1, 'sdt', true),

  ((select id from public.recipes where name = 'Tempe Orek'), (select id from public.ingredients where name = 'Tempe'), 200, 'gram', true),
  ((select id from public.recipes where name = 'Tempe Orek'), (select id from public.ingredients where name = 'Bawang Merah'), 3, 'siung', true),
  ((select id from public.recipes where name = 'Tempe Orek'), (select id from public.ingredients where name = 'Bawang Putih'), 2, 'siung', true),
  ((select id from public.recipes where name = 'Tempe Orek'), (select id from public.ingredients where name = 'Cabai'), 2, 'buah', false),
  ((select id from public.recipes where name = 'Tempe Orek'), (select id from public.ingredients where name = 'Kecap'), 2, 'sdm', false),
  ((select id from public.recipes where name = 'Tempe Orek'), (select id from public.ingredients where name = 'Minyak Goreng'), 2, 'sdm', true),

  ((select id from public.recipes where name = 'Tumis Sawi Bakso'), (select id from public.ingredients where name = 'Sawi'), 150, 'gram', true),
  ((select id from public.recipes where name = 'Tumis Sawi Bakso'), (select id from public.ingredients where name = 'Bakso'), 6, 'butir', true),
  ((select id from public.recipes where name = 'Tumis Sawi Bakso'), (select id from public.ingredients where name = 'Bawang Putih'), 2, 'siung', true),
  ((select id from public.recipes where name = 'Tumis Sawi Bakso'), (select id from public.ingredients where name = 'Cabai'), 2, 'buah', false),
  ((select id from public.recipes where name = 'Tumis Sawi Bakso'), (select id from public.ingredients where name = 'Garam'), 0.5, 'sdt', true),
  ((select id from public.recipes where name = 'Tumis Sawi Bakso'), (select id from public.ingredients where name = 'Minyak Goreng'), 2, 'sdm', true),

  ((select id from public.recipes where name = 'Perkedel Kentang'), (select id from public.ingredients where name = 'Kentang'), 3, 'buah', true),
  ((select id from public.recipes where name = 'Perkedel Kentang'), (select id from public.ingredients where name = 'Telur'), 1, 'butir', true),
  ((select id from public.recipes where name = 'Perkedel Kentang'), (select id from public.ingredients where name = 'Bawang Putih'), 2, 'siung', true),
  ((select id from public.recipes where name = 'Perkedel Kentang'), (select id from public.ingredients where name = 'Daun Bawang'), 1, 'batang', false),
  ((select id from public.recipes where name = 'Perkedel Kentang'), (select id from public.ingredients where name = 'Garam'), 0.5, 'sdt', true),
  ((select id from public.recipes where name = 'Perkedel Kentang'), (select id from public.ingredients where name = 'Minyak Goreng'), 3, 'sdm', true);

insert into public.recipe_steps (recipe_id, step_number, instruction) values
  ((select id from public.recipes where name = 'Nasi Goreng Telur'), 1, 'Panaskan minyak, lalu tumis bawang merah, bawang putih, dan cabai sampai harum.'),
  ((select id from public.recipes where name = 'Nasi Goreng Telur'), 2, 'Masukkan telur dan orak-arik hingga matang.'),
  ((select id from public.recipes where name = 'Nasi Goreng Telur'), 3, 'Tambahkan nasi, kecap, dan garam, lalu aduk hingga tercampur rata.'),
  ((select id from public.recipes where name = 'Nasi Goreng Telur'), 4, 'Masak hingga nasi panas merata, kemudian sajikan.'),

  ((select id from public.recipes where name = 'Telur Dadar Cabai'), 1, 'Iris cabai dan bawang merah, lalu campur bersama telur dan garam.'),
  ((select id from public.recipes where name = 'Telur Dadar Cabai'), 2, 'Panaskan minyak di wajan datar.'),
  ((select id from public.recipes where name = 'Telur Dadar Cabai'), 3, 'Tuang adonan telur dan masak hingga kedua sisi matang.'),

  ((select id from public.recipes where name = 'Tahu Goreng Bumbu'), 1, 'Haluskan bawang putih dan garam, lalu balurkan ke potongan tahu.'),
  ((select id from public.recipes where name = 'Tahu Goreng Bumbu'), 2, 'Panaskan minyak, goreng tahu hingga keemasan.'),
  ((select id from public.recipes where name = 'Tahu Goreng Bumbu'), 3, 'Angkat dan sajikan dengan kecap sebagai pelengkap.'),

  ((select id from public.recipes where name = 'Mie Goreng Sayur'), 1, 'Rebus mie hingga setengah matang lalu tiriskan.'),
  ((select id from public.recipes where name = 'Mie Goreng Sayur'), 2, 'Tumis bawang putih sampai harum, lalu masukkan wortel, kol, dan sawi.'),
  ((select id from public.recipes where name = 'Mie Goreng Sayur'), 3, 'Masukkan mie dan kecap, lalu aduk hingga bumbu rata.'),
  ((select id from public.recipes where name = 'Mie Goreng Sayur'), 4, 'Masak sebentar sampai sayur layu dan mie siap disajikan.'),

  ((select id from public.recipes where name = 'Sup Ayam Wortel'), 1, 'Tumis bawang merah dan bawang putih hingga harum.'),
  ((select id from public.recipes where name = 'Sup Ayam Wortel'), 2, 'Masukkan ayam, aduk sampai berubah warna.'),
  ((select id from public.recipes where name = 'Sup Ayam Wortel'), 3, 'Tambahkan air, wortel, kentang, dan garam, lalu masak hingga empuk.'),
  ((select id from public.recipes where name = 'Sup Ayam Wortel'), 4, 'Masukkan daun bawang sesaat sebelum diangkat.'),

  ((select id from public.recipes where name = 'Tempe Orek'), 1, 'Potong tempe kecil-kecil lalu goreng setengah kering.'),
  ((select id from public.recipes where name = 'Tempe Orek'), 2, 'Tumis bawang merah, bawang putih, dan cabai sampai harum.'),
  ((select id from public.recipes where name = 'Tempe Orek'), 3, 'Masukkan tempe dan kecap, aduk hingga meresap.'),

  ((select id from public.recipes where name = 'Tumis Sawi Bakso'), 1, 'Iris bakso dan potong sawi sesuai selera.'),
  ((select id from public.recipes where name = 'Tumis Sawi Bakso'), 2, 'Tumis bawang putih dan cabai sampai harum.'),
  ((select id from public.recipes where name = 'Tumis Sawi Bakso'), 3, 'Masukkan bakso, lalu sawi, garam, dan sedikit air.'),
  ((select id from public.recipes where name = 'Tumis Sawi Bakso'), 4, 'Masak hingga sawi layu dan bakso panas merata.'),

  ((select id from public.recipes where name = 'Perkedel Kentang'), 1, 'Kupas kentang, potong-potong, lalu goreng atau rebus hingga empuk.'),
  ((select id from public.recipes where name = 'Perkedel Kentang'), 2, 'Haluskan kentang dan campur dengan bawang putih, daun bawang, garam, dan telur.'),
  ((select id from public.recipes where name = 'Perkedel Kentang'), 3, 'Bentuk bulat pipih sesuai selera.'),
  ((select id from public.recipes where name = 'Perkedel Kentang'), 4, 'Goreng dalam minyak panas hingga kedua sisi kecokelatan.');
