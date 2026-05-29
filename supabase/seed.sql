truncate table public.recipe_steps restart identity cascade;
truncate table public.recipe_ingredients restart identity cascade;
truncate table public.recipes restart identity cascade;
truncate table public.ingredients restart identity cascade;

insert into public.ingredients (name, category) values
  ('Ayam', 'Protein'),
  ('Bakso', 'Protein'),
  ('Bawang Merah', 'Bumbu'),
  ('Bawang Putih', 'Bumbu'),
  ('Cabai', 'Bumbu'),
  ('Daun Bawang', 'Sayur'),
  ('Garam', 'Bumbu'),
  ('Kecap', 'Bumbu'),
  ('Kentang', 'Karbohidrat'),
  ('Kol', 'Sayur'),
  ('Mie', 'Karbohidrat'),
  ('Minyak Goreng', 'Bumbu'),
  ('Nasi', 'Karbohidrat'),
  ('Sawi', 'Sayur'),
  ('Sosis', 'Protein'),
  ('Tahu', 'Protein'),
  ('Telur', 'Protein'),
  ('Tempe', 'Protein'),
  ('Tomat', 'Sayur'),
  ('Wortel', 'Sayur');

insert into public.recipes (name, description, image_url, default_serving, cooking_time) values
  ('Nasi Goreng Telur', 'Nasi goreng gurih dengan telur dan bumbu sederhana.', null, 2, 20),
  ('Telur Dadar Cabai', 'Telur dadar pedas praktis untuk lauk cepat.', null, 2, 15),
  ('Tahu Goreng Bumbu', 'Tahu goreng renyah dengan bumbu bawang dan kecap.', null, 2, 18),
  ('Mie Goreng Sayur', 'Mie goreng sederhana dengan sayur segar.', null, 2, 20),
  ('Sup Ayam Wortel', 'Sup hangat dengan ayam, wortel, dan kaldu ringan.', null, 3, 35),
  ('Tempe Orek', 'Tempe manis gurih dengan kecap dan bawang.', null, 3, 20),
  ('Tumis Sawi Bakso', 'Tumis sawi praktis dengan bakso dan bawang.', null, 2, 18),
  ('Perkedel Kentang', 'Perkedel kentang lembut untuk lauk pendamping.', null, 3, 30);

insert into public.recipe_ingredients (recipe_id, ingredient_id, amount, unit) values
  ((select id from public.recipes where name = 'Nasi Goreng Telur'), (select id from public.ingredients where name = 'Nasi'), 2, 'piring'),
  ((select id from public.recipes where name = 'Nasi Goreng Telur'), (select id from public.ingredients where name = 'Telur'), 2, 'butir'),
  ((select id from public.recipes where name = 'Nasi Goreng Telur'), (select id from public.ingredients where name = 'Bawang Merah'), 3, 'siung'),
  ((select id from public.recipes where name = 'Nasi Goreng Telur'), (select id from public.ingredients where name = 'Bawang Putih'), 2, 'siung'),
  ((select id from public.recipes where name = 'Nasi Goreng Telur'), (select id from public.ingredients where name = 'Cabai'), 2, 'buah'),
  ((select id from public.recipes where name = 'Nasi Goreng Telur'), (select id from public.ingredients where name = 'Kecap'), 2, 'sdm'),
  ((select id from public.recipes where name = 'Nasi Goreng Telur'), (select id from public.ingredients where name = 'Garam'), 0.5, 'sdt'),
  ((select id from public.recipes where name = 'Nasi Goreng Telur'), (select id from public.ingredients where name = 'Minyak Goreng'), 2, 'sdm'),

  ((select id from public.recipes where name = 'Telur Dadar Cabai'), (select id from public.ingredients where name = 'Telur'), 3, 'butir'),
  ((select id from public.recipes where name = 'Telur Dadar Cabai'), (select id from public.ingredients where name = 'Cabai'), 3, 'buah'),
  ((select id from public.recipes where name = 'Telur Dadar Cabai'), (select id from public.ingredients where name = 'Bawang Merah'), 2, 'siung'),
  ((select id from public.recipes where name = 'Telur Dadar Cabai'), (select id from public.ingredients where name = 'Garam'), 0.5, 'sdt'),
  ((select id from public.recipes where name = 'Telur Dadar Cabai'), (select id from public.ingredients where name = 'Minyak Goreng'), 2, 'sdm'),

  ((select id from public.recipes where name = 'Tahu Goreng Bumbu'), (select id from public.ingredients where name = 'Tahu'), 4, 'potong'),
  ((select id from public.recipes where name = 'Tahu Goreng Bumbu'), (select id from public.ingredients where name = 'Bawang Putih'), 2, 'siung'),
  ((select id from public.recipes where name = 'Tahu Goreng Bumbu'), (select id from public.ingredients where name = 'Garam'), 0.5, 'sdt'),
  ((select id from public.recipes where name = 'Tahu Goreng Bumbu'), (select id from public.ingredients where name = 'Kecap'), 1, 'sdm'),
  ((select id from public.recipes where name = 'Tahu Goreng Bumbu'), (select id from public.ingredients where name = 'Minyak Goreng'), 3, 'sdm'),

  ((select id from public.recipes where name = 'Mie Goreng Sayur'), (select id from public.ingredients where name = 'Mie'), 2, 'bungkus'),
  ((select id from public.recipes where name = 'Mie Goreng Sayur'), (select id from public.ingredients where name = 'Kol'), 100, 'gram'),
  ((select id from public.recipes where name = 'Mie Goreng Sayur'), (select id from public.ingredients where name = 'Sawi'), 100, 'gram'),
  ((select id from public.recipes where name = 'Mie Goreng Sayur'), (select id from public.ingredients where name = 'Wortel'), 1, 'buah'),
  ((select id from public.recipes where name = 'Mie Goreng Sayur'), (select id from public.ingredients where name = 'Bawang Putih'), 2, 'siung'),
  ((select id from public.recipes where name = 'Mie Goreng Sayur'), (select id from public.ingredients where name = 'Kecap'), 2, 'sdm'),
  ((select id from public.recipes where name = 'Mie Goreng Sayur'), (select id from public.ingredients where name = 'Minyak Goreng'), 2, 'sdm'),

  ((select id from public.recipes where name = 'Sup Ayam Wortel'), (select id from public.ingredients where name = 'Ayam'), 250, 'gram'),
  ((select id from public.recipes where name = 'Sup Ayam Wortel'), (select id from public.ingredients where name = 'Wortel'), 2, 'buah'),
  ((select id from public.recipes where name = 'Sup Ayam Wortel'), (select id from public.ingredients where name = 'Kentang'), 2, 'buah'),
  ((select id from public.recipes where name = 'Sup Ayam Wortel'), (select id from public.ingredients where name = 'Bawang Merah'), 3, 'siung'),
  ((select id from public.recipes where name = 'Sup Ayam Wortel'), (select id from public.ingredients where name = 'Bawang Putih'), 2, 'siung'),
  ((select id from public.recipes where name = 'Sup Ayam Wortel'), (select id from public.ingredients where name = 'Daun Bawang'), 1, 'batang'),
  ((select id from public.recipes where name = 'Sup Ayam Wortel'), (select id from public.ingredients where name = 'Garam'), 1, 'sdt'),

  ((select id from public.recipes where name = 'Tempe Orek'), (select id from public.ingredients where name = 'Tempe'), 200, 'gram'),
  ((select id from public.recipes where name = 'Tempe Orek'), (select id from public.ingredients where name = 'Bawang Merah'), 3, 'siung'),
  ((select id from public.recipes where name = 'Tempe Orek'), (select id from public.ingredients where name = 'Bawang Putih'), 2, 'siung'),
  ((select id from public.recipes where name = 'Tempe Orek'), (select id from public.ingredients where name = 'Cabai'), 2, 'buah'),
  ((select id from public.recipes where name = 'Tempe Orek'), (select id from public.ingredients where name = 'Kecap'), 2, 'sdm'),
  ((select id from public.recipes where name = 'Tempe Orek'), (select id from public.ingredients where name = 'Minyak Goreng'), 2, 'sdm'),

  ((select id from public.recipes where name = 'Tumis Sawi Bakso'), (select id from public.ingredients where name = 'Sawi'), 150, 'gram'),
  ((select id from public.recipes where name = 'Tumis Sawi Bakso'), (select id from public.ingredients where name = 'Bakso'), 6, 'butir'),
  ((select id from public.recipes where name = 'Tumis Sawi Bakso'), (select id from public.ingredients where name = 'Bawang Putih'), 2, 'siung'),
  ((select id from public.recipes where name = 'Tumis Sawi Bakso'), (select id from public.ingredients where name = 'Cabai'), 2, 'buah'),
  ((select id from public.recipes where name = 'Tumis Sawi Bakso'), (select id from public.ingredients where name = 'Garam'), 0.5, 'sdt'),
  ((select id from public.recipes where name = 'Tumis Sawi Bakso'), (select id from public.ingredients where name = 'Minyak Goreng'), 2, 'sdm'),

  ((select id from public.recipes where name = 'Perkedel Kentang'), (select id from public.ingredients where name = 'Kentang'), 3, 'buah'),
  ((select id from public.recipes where name = 'Perkedel Kentang'), (select id from public.ingredients where name = 'Telur'), 1, 'butir'),
  ((select id from public.recipes where name = 'Perkedel Kentang'), (select id from public.ingredients where name = 'Bawang Putih'), 2, 'siung'),
  ((select id from public.recipes where name = 'Perkedel Kentang'), (select id from public.ingredients where name = 'Daun Bawang'), 1, 'batang'),
  ((select id from public.recipes where name = 'Perkedel Kentang'), (select id from public.ingredients where name = 'Garam'), 0.5, 'sdt'),
  ((select id from public.recipes where name = 'Perkedel Kentang'), (select id from public.ingredients where name = 'Minyak Goreng'), 3, 'sdm');

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
