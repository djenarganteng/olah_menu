import "@supabase/functions-js/edge-runtime.d.ts";

type AiRecipe = {
  id: string;
  title: string;
  description: string;
  cooking_time: number;
  estimated_time: string;
  difficulty: string;
  servings: number;
  tips: string[];
  main_ingredients: string[];
  seasonings: string[];
  ingredients: string[];
  step_details: AiRecipeStep[];
  steps: string[];
  image_url: string | null;
  image_prompt: string | null;
  image_source: string;
  source: "cache" | "gemini";
};

type AiRecipeStep = {
  step: number;
  title: string;
  description: string;
};

const geminiModel = Deno.env.get("GEMINI_MODEL") ?? "gemini-2.5-pro";
const geminiFallbackModel =
  Deno.env.get("GEMINI_FALLBACK_MODEL") ?? "gemini-2.5-flash";
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
    estimated_time: `${Number(row.cooking_time ?? 0) || 30} menit`,
    difficulty: "Mudah",
    servings: Number(row.servings ?? 1),
    tips: [],
    main_ingredients: normalizeStringArray(row.ingredients_json),
    seasonings: [],
    ingredients: normalizeStringArray(row.ingredients_json),
    step_details: normalizeStepDetails(row.steps_json),
    steps: normalizeStepStrings(row.steps_json),
    image_url: null,
    image_prompt: null,
    image_source: "placeholder",
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
    return {
      ...recipe,
      id: crypto.randomUUID(),
      source: "gemini",
    };
  }

  const rows = await response.json();
  const row = Array.isArray(rows) ? rows[0] : null;
  if (!row) {
    return {
      ...recipe,
      id: crypto.randomUUID(),
      source: "gemini",
    };
  }

  return {
    ...recipe,
    id: String(row.id ?? crypto.randomUUID()),
    title: String(row.title ?? recipe.title),
    description: String(row.description ?? recipe.description),
    cooking_time: Number(row.cooking_time ?? recipe.cooking_time),
    estimated_time: recipe.estimated_time,
    difficulty: recipe.difficulty,
    servings: Number(row.servings ?? recipe.servings),
    tips: recipe.tips,
    main_ingredients: recipe.main_ingredients,
    seasonings: recipe.seasonings,
    ingredients: normalizeStringArray(row.ingredients_json),
    step_details: recipe.step_details,
    steps: normalizeStringArray(row.steps_json),
    image_url: recipe.image_url,
    image_prompt: recipe.image_prompt,
    image_source: recipe.image_source,
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

Berikan resep yang realistis, detail, dan dapat dimasak di rumah.

Jawab HANYA dalam JSON valid tanpa markdown dan tanpa penjelasan tambahan.

Format JSON:

{
  "title": "",
  "description": "",
  "cooking_time": 0,
  "estimated_time": "",
  "difficulty": "",
  "servings": 2,
  "tips": [],
  "main_ingredients": [],
  "seasonings": [],
  "ingredients": [],
  "step_details": [
    {
      "step": 1,
      "title": "",
      "description": ""
    }
  ],
  "steps": [],
  "image_url": null,
  "image_prompt": null,
  "image_source": "placeholder"
}

Bahan yang tersedia:
${ingredients.map((item) => `- ${item}`).join("\n")}`;

  const modelCandidates = [geminiModel, geminiFallbackModel].filter(
    (model, index, models) => model.length > 0 && models.indexOf(model) === index,
  );
  const errors: string[] = [];

  for (const model of modelCandidates) {
    try {
      console.info(`Generating AI recipe with Gemini model: ${model}`);
      return await generateRecipeWithModel(apiKey, prompt, model);
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      errors.push(`${model}: ${message}`);
      console.warn(`Gemini model ${model} failed`, message);
    }
  }

  throw new Error(
    `All Gemini models failed: ${errors.join(" | ") || "unknown error"}`,
  );
}

async function generateRecipeWithModel(
  apiKey: string,
  prompt: string,
  model: string,
): Promise<AiRecipe> {
  const url =
    `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`;
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
  const cookingTime = positiveIntegerOrFallback(
    map["cooking_time"] ?? map["waktu_memasak"],
    30,
  );
  const mainIngredients = normalizeStringArray(
    map["main_ingredients"] ?? map["bahan_utama"],
  );
  const seasonings = normalizeStringArray(
    map["seasonings"] ?? map["bumbu_dan_pelengkap"],
  );
  const stepDetails = normalizeStepDetails(
    map["step_details"] ?? map["langkah_memasak"],
  );
  const steps = normalizeStepStrings(map.steps, stepDetails);
  const ingredients = normalizeStringArray(map.ingredients);
  const normalizedIngredients = ingredients.length > 0
    ? ingredients
    : [...mainIngredients, ...seasonings];
  const imageUrl = stringOrNull(map.image_url ?? map.imageUrl);
  const imagePrompt = stringOrNull(map.image_prompt ?? map.imagePrompt);
  const imageSource = stringOrFallback(
    map["image_source"] ?? map["imageSource"],
    imageUrl ? "generated" : "placeholder",
  );
  const estimatedTime = stringOrFallback(
    map["estimated_time"] ?? map["estimasi_waktu"],
    `${cookingTime} menit`,
  );
  const recipe: AiRecipe = {
    id: "",
    title: stringOrFallback(map["title"] ?? map["nama_masakan"], "Resep AI"),
    description: stringOrFallback(map["description"] ?? map["deskripsi"], ""),
    cooking_time: cookingTime,
    estimated_time: estimatedTime,
    difficulty: stringOrFallback(
      map["difficulty"] ?? map["tingkat_kesulitan"],
      "Mudah",
    ),
    servings: positiveIntegerOrFallback(
      map["servings"] ?? map["jumlah_porsi"],
      2,
    ),
    tips: normalizeStringArray(map["tips"] ?? map["tips_memasak"]),
    main_ingredients: mainIngredients,
    seasonings,
    ingredients: normalizedIngredients,
    step_details: stepDetails,
    steps,
    image_url: imageUrl,
    image_prompt: imagePrompt,
    image_source: imageSource,
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

function normalizeStepDetails(value: unknown): AiRecipeStep[] {
  if (!Array.isArray(value)) {
    return [];
  }

  return value
    .map((item, index) => {
      if (typeof item === "string") {
        return parseStepFromText(item, index + 1);
      }

      if (!item || typeof item !== "object") {
        return parseStepFromText(String(item), index + 1);
      }

      const map = item as Record<string, unknown>;
      const fallbackStep = positiveIntegerOrFallback(map.step, index + 1);
      return {
        step: fallbackStep,
        title: stringOrFallback(map.title ?? map.judul, `Langkah ${fallbackStep}`),
        description: stringOrFallback(
          map.description ?? map.deskripsi,
          "",
        ),
      };
    })
    .filter((item) => item.title.length > 0 || item.description.length > 0)
    .sort((a, b) => a.step - b.step);
}

function normalizeStepStrings(
  value: unknown,
  stepDetails: AiRecipeStep[] = [],
): string[] {
  if (!Array.isArray(value)) {
    return stepDetails.map((step) => {
      const title = step.title.trim();
      const description = step.description.trim();
      if (title.length === 0) {
        return description;
      }
      if (description.length === 0) {
        return title;
      }
      return `${title}: ${description}`;
    });
  }

  const items = value
    .map((item) => {
      if (typeof item === "string") {
        return item.trim();
      }

      if (!item || typeof item !== "object") {
        return String(item).trim();
      }

      const map = item as Record<string, unknown>;
      const title = stringOrFallback(map["title"] ?? map["judul"], "");
      const description = stringOrFallback(
        map["description"] ?? map["deskripsi"],
        "",
      );
      if (title.length === 0) {
        return description;
      }
      if (description.length === 0) {
        return title;
      }
      return `${title}: ${description}`;
    })
    .filter((item) => item.length > 0);
  if (items.length > 0) {
    return items;
  }

  return stepDetails.map((step) => {
    const title = step.title.trim();
    const description = step.description.trim();
    if (title.length === 0) {
      return description;
    }
    if (description.length === 0) {
      return title;
    }
    return `${title}: ${description}`;
  });
}

function parseStepFromText(text: string, fallbackStep: number): AiRecipeStep {
  const normalized = text.trim();
  if (normalized.length === 0) {
    return {
      step: fallbackStep,
      title: `Langkah ${fallbackStep}`,
      description: "",
    };
  }

  const numberedMatch = normalized.match(/^(?:Langkah\s*)?(\d+)[\.\:\-]\s*(.+)$/i);
  if (numberedMatch) {
    const step = positiveIntegerOrFallback(numberedMatch[1], fallbackStep);
    return parseStepBody(numberedMatch[2] ?? normalized, step);
  }

  return parseStepBody(normalized, fallbackStep);
}

function parseStepBody(text: string, step: number): AiRecipeStep {
  const normalized = text.trim();
  const separators = [": ", " - ", " — ", " · "];

  for (const separator of separators) {
    const index = normalized.indexOf(separator);
    if (index > 0) {
      const title = normalized.slice(0, index).trim();
      const description = normalized.slice(index + separator.length).trim();
      if (title.length > 0 && description.length > 0) {
        return { step, title, description };
      }
    }
  }

  if (normalized.length > 80) {
    return {
      step,
      title: `Langkah ${step}`,
      description: normalized,
    };
  }

  return {
    step,
    title: normalized,
    description: "",
  };
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

function stringOrNull(value: unknown): string | null {
  if (typeof value !== "string") {
    return null;
  }
  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : null;
}
