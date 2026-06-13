import "@supabase/functions-js/edge-runtime.d.ts";

type AiRecipe = {
  id: string;
  title: string;
  description: string;
  cooking_time: number;
  servings: number;
  ingredients: string[];
  steps: string[];
  source: "cache" | "gemini";
};

const geminiModel = Deno.env.get("GEMINI_MODEL") ?? "gemini-2.5-flash";
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  try {
    const geminiApiKey = Deno.env.get("GEMINI_API_KEY");
    if (!geminiApiKey) {
      return jsonResponse({ error: "GEMINI_API_KEY is not configured" }, 500);
    }

    const body = await req.json();
    const selectedIngredients = normalizeIngredients(body?.ingredients);

    if (selectedIngredients.length === 0) {
      return jsonResponse({ error: "ingredients must not be empty" }, 400);
    }

    const cachedRecipe = await getCachedRecipe(selectedIngredients);
    if (cachedRecipe) {
      return jsonResponse(cachedRecipe, 200);
    }

    const recipe = await generateRecipeWithGemini(
      geminiApiKey,
      selectedIngredients,
    );

    const savedRecipe = await saveCachedRecipe(recipe, selectedIngredients);

    return jsonResponse(savedRecipe, 200);
  } catch (error) {
    console.error("generate-recipe failed", error);
    const showDetails = Deno.env.get("DEBUG_AI_RECIPE_ERRORS") === "true";
    return jsonResponse(
      {
        error: "Failed to generate recipe",
        ...(showDetails
          ? { details: error instanceof Error ? error.message : String(error) }
          : {}),
      },
      500,
    );
  }
});

function normalizeIngredients(value: unknown): string[] {
  if (!Array.isArray(value)) {
    return [];
  }

  return value
    .map((item) => String(item).trim().toLocaleLowerCase("id-ID"))
    .filter((item, index, items) =>
      item.length > 0 && items.indexOf(item) === index
    )
    .sort((a, b) => a.localeCompare(b, "id-ID"))
}

async function getCachedRecipe(
  selectedIngredients: string[],
): Promise<AiRecipe | null> {
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

  if (!supabaseUrl || !serviceRoleKey) {
    return null;
  }

  const url = new URL(`${supabaseUrl}/rest/v1/ai_generated_recipes`);
  url.searchParams.set(
    "select",
    "id,title,description,cooking_time,servings,ingredients_json,steps_json",
  );
  url.searchParams.set(
    "selected_ingredients_json",
    `eq.${JSON.stringify(selectedIngredients)}`,
  );
  url.searchParams.set("limit", "1");

  const response = await fetch(url, {
    headers: {
      apikey: serviceRoleKey,
      authorization: `Bearer ${serviceRoleKey}`,
    },
  });

  if (!response.ok) {
    console.warn("AI recipe cache lookup failed", await response.text());
    return null;
  }

  const rows = await response.json();
  const row = Array.isArray(rows) ? rows[0] : null;
  if (!row) {
    return null;
  }

  return {
    id: String(row.id ?? ""),
    title: String(row.title ?? ""),
    description: String(row.description ?? ""),
    cooking_time: Number(row.cooking_time ?? 0),
    servings: Number(row.servings ?? 1),
    ingredients: normalizeStringArray(row.ingredients_json),
    steps: normalizeStringArray(row.steps_json),
    source: "cache",
  };
}

async function saveCachedRecipe(
  recipe: AiRecipe,
  selectedIngredients: string[],
): Promise<AiRecipe> {
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

  if (!supabaseUrl || !serviceRoleKey) {
    return { ...recipe, id: crypto.randomUUID(), source: "gemini" };
  }

  const url = new URL(`${supabaseUrl}/rest/v1/ai_generated_recipes`);
  url.searchParams.set("on_conflict", "selected_ingredients_json");
  url.searchParams.set(
    "select",
    "id,title,description,cooking_time,servings,ingredients_json,steps_json",
  );

  const response = await fetch(url, {
    method: "POST",
    headers: {
      apikey: serviceRoleKey,
      authorization: `Bearer ${serviceRoleKey}`,
      "Content-Type": "application/json",
      Prefer: "resolution=merge-duplicates,return=representation",
    },
    body: JSON.stringify({
      title: recipe.title,
      description: recipe.description,
      cooking_time: recipe.cooking_time,
      servings: recipe.servings,
      ingredients_json: recipe.ingredients,
      steps_json: recipe.steps,
      selected_ingredients_json: selectedIngredients,
    }),
  });

  if (!response.ok) {
    console.warn("AI recipe cache save failed", await response.text());
    return { ...recipe, id: crypto.randomUUID(), source: "gemini" };
  }

  const rows = await response.json();
  const row = Array.isArray(rows) ? rows[0] : null;
  if (!row) {
    return { ...recipe, id: crypto.randomUUID(), source: "gemini" };
  }

  return {
    id: String(row.id ?? crypto.randomUUID()),
    title: String(row.title ?? recipe.title),
    description: String(row.description ?? recipe.description),
    cooking_time: Number(row.cooking_time ?? recipe.cooking_time),
    servings: Number(row.servings ?? recipe.servings),
    ingredients: normalizeStringArray(row.ingredients_json),
    steps: normalizeStringArray(row.steps_json),
    source: "gemini",
  };
}

async function generateRecipeWithGemini(
  apiKey: string,
  ingredients: string[],
): Promise<AiRecipe> {
  const prompt = `Kamu adalah chef profesional Indonesia.

Buat resep masakan berdasarkan bahan yang diberikan.

Gunakan sebanyak mungkin bahan yang tersedia.

Tambahkan bumbu dapur umum jika diperlukan.

Berikan resep yang realistis dan dapat dimasak di rumah.

Jawab HANYA dalam JSON valid tanpa markdown dan tanpa penjelasan tambahan.

Format JSON:

{
  "title": "",
  "description": "",
  "cooking_time": 0,
  "servings": 0,
  "ingredients": [],
  "steps": []
}

Bahan yang tersedia:
${ingredients.map((item) => `- ${item}`).join("\n")}`;

  const url =
    `https://generativelanguage.googleapis.com/v1beta/models/${geminiModel}:generateContent?key=${apiKey}`;
  const response = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      contents: [
        {
          role: "user",
          parts: [{ text: prompt }],
        },
      ],
      generationConfig: {
        temperature: 0.7,
        responseMimeType: "application/json",
      },
    }),
  });

  if (!response.ok) {
    throw new Error(
      `Gemini API failed: ${response.status} ${await response.text()}`,
    );
  }

  const data = await response.json();
  const text = data?.candidates?.[0]?.content?.parts?.[0]?.text;
  if (typeof text !== "string" || text.trim().length === 0) {
    throw new Error("Gemini response is empty");
  }

  return validateRecipe(JSON.parse(cleanJsonText(text)));
}

function cleanJsonText(text: string): string {
  return text
    .trim()
    .replace(/^```json\s*/i, "")
    .replace(/^```\s*/i, "")
    .replace(/\s*```$/i, "")
    .trim();
}

function validateRecipe(value: unknown): AiRecipe {
  if (!value || typeof value !== "object") {
    throw new Error("Recipe response is not an object");
  }

  const map = value as Record<string, unknown>;
  const recipe: AiRecipe = {
    id: "",
    title: stringOrFallback(map.title, "Resep AI"),
    description: stringOrFallback(map.description, ""),
    cooking_time: positiveIntegerOrFallback(map.cooking_time, 30),
    servings: positiveIntegerOrFallback(map.servings, 2),
    ingredients: normalizeStringArray(map.ingredients),
    steps: normalizeStringArray(map.steps),
    source: "gemini",
  };

  if (recipe.ingredients.length === 0 || recipe.steps.length === 0) {
    throw new Error("Recipe response is missing ingredients or steps");
  }

  return recipe;
}

function stringOrFallback(value: unknown, fallback: string): string {
  if (typeof value !== "string") {
    return fallback;
  }
  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : fallback;
}

function positiveIntegerOrFallback(value: unknown, fallback: number): number {
  const parsed = Number(value);
  if (!Number.isFinite(parsed) || parsed <= 0) {
    return fallback;
  }
  return Math.round(parsed);
}

function normalizeStringArray(value: unknown): string[] {
  if (!Array.isArray(value)) {
    return [];
  }

  return value
    .map((item) => String(item).trim())
    .filter((item) => item.length > 0);
}

function jsonResponse(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}
