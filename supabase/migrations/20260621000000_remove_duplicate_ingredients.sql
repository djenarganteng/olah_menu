-- Migration to remove duplicate ingredients (case-insensitive) and fix recipe references
DO $$ 
DECLARE
    ing_record RECORD;
    min_id INT;
BEGIN
    FOR ing_record IN 
        SELECT LOWER(name) as lower_name, MIN(id) as keep_id
        FROM public.ingredients
        GROUP BY LOWER(name)
        HAVING COUNT(*) > 1
    LOOP
        min_id := ing_record.keep_id;
        
        -- Update recipe_ingredients to point to the kept ingredient ID
        UPDATE public.recipe_ingredients
        SET ingredient_id = min_id
        WHERE ingredient_id IN (
            SELECT id FROM public.ingredients 
            WHERE LOWER(name) = ing_record.lower_name 
            AND id != min_id
        );
        
        -- Delete the duplicate ingredients
        DELETE FROM public.ingredients 
        WHERE LOWER(name) = ing_record.lower_name 
        AND id != min_id;
    END LOOP;
END $$;
