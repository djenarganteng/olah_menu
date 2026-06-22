-- Insert new ingredients if they do not exist
INSERT INTO public.ingredients (name, category, sort_order)
SELECT val.name, val.category, val.sort_order
FROM (VALUES
  ('Pokcoy', 'Sayur', 20),
  ('Kembang Kol', 'Sayur', 21),
  ('Margarin', 'Bahan Dasar', 22),
  ('Air', 'Bahan Dasar', 23),
  ('Bawang Bombay', 'Bumbu', 24),
  ('Saus Tiram', 'Bumbu', 25),
  ('Kecap Ikan', 'Bumbu', 26),
  ('Minyak Wijen', 'Bumbu', 27),
  ('Kaldu Bubuk', 'Bumbu', 28),
  ('Gula', 'Bumbu', 29),
  ('Lada Bubuk', 'Bumbu', 30),
  ('Tepung Maizena', 'Bahan Dasar', 31),
  ('Labu Siam', 'Sayur', 32),
  ('Jagung', 'Sayur', 33),
  ('Kacang Panjang', 'Sayur', 34),
  ('Daun Melinjo', 'Sayur', 35),
  ('Buah Melinjo', 'Sayur', 36),
  ('Asam Jawa', 'Bumbu', 37),
  ('Kemiri', 'Bumbu', 38),
  ('Terasi', 'Bumbu', 39),
  ('Daun Salam', 'Bumbu', 40),
  ('Lengkuas', 'Bumbu', 41),
  ('Serai', 'Bumbu', 42),
  ('Jahe', 'Bumbu', 43),
  ('Kunyit', 'Bumbu', 44)
) AS val(name, category, sort_order)
WHERE NOT EXISTS (
  SELECT 1 FROM public.ingredients WHERE LOWER(name) = LOWER(val.name)
);

-- Seed image URLs for new ingredients (using local assets or generic urls where appropriate, or keeping them null/generic)
UPDATE public.ingredients SET image_url = 'https://nvbaxhlexcfaahmzeauq.supabase.co/storage/v1/object/public/ingredient-images/ingredients/pokcoy.jpg' WHERE LOWER(name) = 'pokcoy' AND image_url IS NULL;
UPDATE public.ingredients SET image_url = 'https://nvbaxhlexcfaahmzeauq.supabase.co/storage/v1/object/public/ingredient-images/ingredients/kembang_kol.jpg' WHERE LOWER(name) = 'kembang kol' AND image_url IS NULL;
UPDATE public.ingredients SET image_url = 'https://nvbaxhlexcfaahmzeauq.supabase.co/storage/v1/object/public/ingredient-images/ingredients/margarin.jpg' WHERE LOWER(name) = 'margarin' AND image_url IS NULL;
UPDATE public.ingredients SET image_url = 'https://nvbaxhlexcfaahmzeauq.supabase.co/storage/v1/object/public/ingredient-images/ingredients/bawang_bombay.jpg' WHERE LOWER(name) = 'bawang bombay' AND image_url IS NULL;

-- 1. Insert Capcay Bakso Saus Gurih
INSERT INTO public.recipes (name, description, image_url, default_serving, cooking_time)
SELECT 
  'Capcay Bakso Saus Gurih',
  'Menu rumahan rasa resto rasa Chinese food dengan sayur crunchy, kuah gurih kental, dan aroma bawang putih minyak wijen.',
  'https://loremflickr.com/980/654/capcay',
  3,
  25
WHERE NOT EXISTS (
  SELECT 1 FROM public.recipes WHERE name = 'Capcay Bakso Saus Gurih'
);

-- Seed Capcay Bakso Saus Gurih Ingredients
WITH r AS (SELECT id FROM public.recipes WHERE name = 'Capcay Bakso Saus Gurih' LIMIT 1)
INSERT INTO public.recipe_ingredients (recipe_id, ingredient_id, amount, unit, is_required)
SELECT (SELECT id FROM r), i.id, val.amount, val.unit, val.is_required
FROM (VALUES
  ('Wortel', 1.0, 'buah', true),
  ('Pokcoy', 3.0, 'lembar', true),
  ('Kembang Kol', 1.0, 'bonggol', true),
  ('Bakso', 10.0, 'buah', true),
  ('Telur', 1.0, 'butir', true),
  ('Margarin', 1.0, 'sdm', false),
  ('Air', 250.0, 'ml', false),
  ('Bawang Putih', 4.0, 'siung', false),
  ('Bawang Bombay', 0.5, 'buah', false),
  ('Saus Tiram', 2.0, 'sdm', false),
  ('Kecap Ikan', 1.0, 'sdm', false),
  ('Minyak Wijen', 1.0, 'sdm', false),
  ('Kaldu Bubuk', 1.0, 'sdm', false),
  ('Gula', 0.25, 'sdt', false),
  ('Garam', 0.5, 'sdt', false),
  ('Lada Bubuk', 0.5, 'sdt', false),
  ('Tepung Maizena', 1.0, 'sdm', false)
) AS val(ing_name, amount, unit, is_required)
JOIN public.ingredients i ON LOWER(i.name) = LOWER(val.ing_name)
WHERE NOT EXISTS (
  SELECT 1 FROM public.recipe_ingredients WHERE recipe_id = (SELECT id FROM r) AND ingredient_id = i.id
);

-- Seed Capcay Bakso Saus Gurih Steps
WITH r AS (SELECT id FROM public.recipes WHERE name = 'Capcay Bakso Saus Gurih' LIMIT 1)
INSERT INTO public.recipe_steps (recipe_id, step_number, instruction)
SELECT (SELECT id FROM r), val.step_number, val.instruction
FROM (VALUES
  (1, 'Panaskan sedikit minyak dan margarin dalam wajan.'),
  (2, 'Tuang telur lalu buat orak-arik hingga matang. Sisihkan di pinggir wajan 🥚'),
  (3, 'Masukkan bawang putih dan bawang bombay, tumis hingga harum dan layu 🤤'),
  (4, 'Masukkan bakso lalu tumis 2–3 menit hingga setengah matang 🍡'),
  (5, 'Tambahkan ini https://s.shopee.co.id/6AiklMzaDq ya, kemudian saus tiram, minyak wijen, gula, dan sedikit kaldu bubuk. Aduk rata ✨'),
  (6, 'Masukkan wortel lalu tumis hingga mulai empuk 🥕'),
  (7, 'Masukkan kembang kol dan pokcoy 🥬🥦'),
  (8, 'Tuang air lalu masak hingga mendidih.'),
  (9, 'Tambahkan garam, lada bubuk, dan sisa kaldu ayam bubuk.'),
  (10, 'Larutkan pengental ini https://s.shopee.co.id/8ATp98XsVR dengan air lalu tuang perlahan sambil diaduk cepat.'),
  (11, 'Masak hingga kuah mengental dan semua sayuran matang.'),
  (12, 'Koreksi rasa lalu angkat 😩❤️')
) AS val(step_number, instruction)
WHERE NOT EXISTS (
  SELECT 1 FROM public.recipe_steps WHERE recipe_id = (SELECT id FROM r) AND step_number = val.step_number
);


-- 2. Insert Sayur Asam Sunda
INSERT INTO public.recipes (name, description, image_url, default_serving, cooking_time)
SELECT 
  'Sayur Asam Sunda',
  'Sayur asam khas Sunda dengan kuah segar yang asam gurih, melinjo, jagung manis, dan labu siam.',
  'https://loremflickr.com/980/654/soup',
  4,
  30
WHERE NOT EXISTS (
  SELECT 1 FROM public.recipes WHERE name = 'Sayur Asam Sunda'
);

-- Seed Sayur Asam Sunda Ingredients
WITH r AS (SELECT id FROM public.recipes WHERE name = 'Sayur Asam Sunda' LIMIT 1)
INSERT INTO public.recipe_ingredients (recipe_id, ingredient_id, amount, unit, is_required)
SELECT (SELECT id FROM r), i.id, val.amount, val.unit, val.is_required
FROM (VALUES
  ('Labu Siam', 1.0, 'buah', true),
  ('Jagung', 2.0, 'buah', true),
  ('Kacang Panjang', 6.0, 'lonjor', true),
  ('Daun Melinjo', 2.0, 'ikat', true),
  ('Buah Melinjo', 100.0, 'gr', true),
  ('Asam Jawa', 1.0, 'sejempol', true),
  ('Air', 600.0, 'ml', false),
  ('Bawang Merah', 7.0, 'butir', false),
  ('Bawang Putih', 3.0, 'siung', false),
  ('Kemiri', 4.0, 'butir', false),
  ('Cabai', 4.0, 'buah', false),
  ('Terasi', 0.5, 'sdt', false),
  ('Daun Salam', 2.0, 'lembar', false),
  ('Lengkuas', 1.0, 'ruas', false),
  ('Serai', 1.0, 'batang', false),
  ('Gula', 1.0, 'sdt', false),
  ('Garam', 0.5, 'sdt', false),
  ('Kaldu Bubuk', 0.5, 'sdt', false)
) AS val(ing_name, amount, unit, is_required)
JOIN public.ingredients i ON LOWER(i.name) = LOWER(val.ing_name)
WHERE NOT EXISTS (
  SELECT 1 FROM public.recipe_ingredients WHERE recipe_id = (SELECT id FROM r) AND ingredient_id = i.id
);

-- Seed Sayur Asam Sunda Steps
WITH r AS (SELECT id FROM public.recipes WHERE name = 'Sayur Asam Sunda' LIMIT 1)
INSERT INTO public.recipe_steps (recipe_id, step_number, instruction)
SELECT (SELECT id FROM r), val.step_number, val.instruction
FROM (VALUES
  (1, 'Didihkan air dalam panci.'),
  (2, 'Masukkan jagung dan buah melinjo lalu rebus hingga mulai empuk 🌽'),
  (3, 'Masukkan bumbu halus, daun salam, lengkuas, serai, dan jangan lupa tambahkan ini https://s.shopee.co.id/4qDMn1nQTi ya 🍲'),
  (4, 'Aduk rata lalu masukkan potongan labu siam.'),
  (5, 'Masak hingga mendidih dan sayuran mulai matang 🤤'),
  (6, 'Tambahkan gula pasir, garam, dan kaldu bubuk.'),
  (7, 'Aduk lalu koreksi rasa.'),
  (8, 'Masukkan kacang panjang dan daun melinjo 🫛🌿'),
  (9, 'Masak sebentar hingga daun melinjo layu tetapi masih hijau segar.'),
  (10, 'Cicipi kuahnya, pastikan rasa asam segarnya terasa pas. Jika kurang asam, tambahkan sedikit air asam jawa lagi 🍋✨'),
  (11, 'Angkat dan sajikan selagi hangat 😩❤️')
) AS val(step_number, instruction)
WHERE NOT EXISTS (
  SELECT 1 FROM public.recipe_steps WHERE recipe_id = (SELECT id FROM r) AND step_number = val.step_number
);


-- 3. Insert Ayam Bakar Bumbu Meresap
INSERT INTO public.recipes (name, description, image_url, default_serving, cooking_time)
SELECT 
  'Ayam Bakar Bumbu Meresap',
  'Ayam bakar yang dagingnya super juicy dengan bumbu yang meresap sampai ke tulang.',
  'https://loremflickr.com/980/654/chicken',
  4,
  45
WHERE NOT EXISTS (
  SELECT 1 FROM public.recipes WHERE name = 'Ayam Bakar Bumbu Meresap'
);

-- Seed Ayam Bakar Bumbu Meresap Ingredients
WITH r AS (SELECT id FROM public.recipes WHERE name = 'Ayam Bakar Bumbu Meresap' LIMIT 1)
INSERT INTO public.recipe_ingredients (recipe_id, ingredient_id, amount, unit, is_required)
SELECT (SELECT id FROM r), i.id, val.amount, val.unit, val.is_required
FROM (VALUES
  ('Ayam', 1.0, 'ekor', true),
  ('Bawang Merah', 8.0, 'siung', false),
  ('Bawang Putih', 5.0, 'siung', false),
  ('Kemiri', 4.0, 'butir', false),
  ('Cabai', 3.0, 'buah', false),
  ('Jahe', 2.0, 'cm', false),
  ('Kunyit', 2.0, 'cm', false),
  ('Daun Salam', 2.0, 'lembar', false),
  ('Serai', 1.0, 'batang', false),
  ('Air', 300.0, 'ml', false),
  ('Kecap', 3.0, 'sdm', false),
  ('Garam', 1.0, 'sdt', false),
  ('Kaldu Bubuk', 1.0, 'sdt', false),
  ('Gula', 1.0, 'sdt', false),
  ('Margarin', 1.0, 'sdm', false)
) AS val(ing_name, amount, unit, is_required)
JOIN public.ingredients i ON LOWER(i.name) = LOWER(val.ing_name)
WHERE NOT EXISTS (
  SELECT 1 FROM public.recipe_ingredients WHERE recipe_id = (SELECT id FROM r) AND ingredient_id = i.id
);

-- Seed Ayam Bakar Bumbu Meresap Steps
WITH r AS (SELECT id FROM public.recipes WHERE name = 'Ayam Bakar Bumbu Meresap' LIMIT 1)
INSERT INTO public.recipe_steps (recipe_id, step_number, instruction)
SELECT (SELECT id FROM r), val.step_number, val.instruction
FROM (VALUES
  (1, 'Haluskan bawang merah, bawang putih, kemiri, cabai merah, jahe, dan kunyit 🌶️'),
  (2, 'Tumis bumbu halus sampai harum dan matang 😍'),
  (3, 'Masukkan daun salam dan serai, aduk sebentar 🌿'),
  (4, 'Masukkan ayam, lalu aduk sampai terbalut bumbu 🍗'),
  (5, 'Tambahkan air, garam, kaldu bubuk, gula, dan kecap manis 🥢'),
  (6, 'Ungkep dengan api kecil sampai ayam matang dan air menyusut 🔥'),
  (7, 'Campurkan sedikit sisa bumbu ungkep dengan kecap manis dan mentega 🧈'),
  (8, 'Oleskan ke seluruh permukaan ayam ✨'),
  (9, 'Bakar atau panggang sampai permukaan ayam kecokelatan dan mengilap 🤤🔥 karena aku gak pakai arang, jadi aku pakai ini ya bund https://s.shopee.co.id/60P9MpqEcE 🤭'),
  (10, 'Sajikan dengan nasi hangat, sambal, dan lalapan 🍚🌶️')
) AS val(step_number, instruction)
WHERE NOT EXISTS (
  SELECT 1 FROM public.recipe_steps WHERE recipe_id = (SELECT id FROM r) AND step_number = val.step_number
);
