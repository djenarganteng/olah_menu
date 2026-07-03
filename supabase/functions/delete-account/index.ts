import "@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "@supabase/supabase-js";

type CleanupTarget = {
  table: string;
  column: string;
};

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const cleanupTargets: CleanupTarget[] = [
  { table: "ingredients", column: "created_by" },
  { table: "user_favorite_recipes", column: "user_id" },
  { table: "user_favorite_ai_recipes", column: "user_id" },
  { table: "favorite_recipes", column: "user_id" },
  { table: "favorite_ingredients", column: "user_id" },
  { table: "shopping_list", column: "user_id" },
  { table: "history", column: "user_id" },
  { table: "profiles", column: "id" },
];

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    if (!supabaseUrl || !serviceRoleKey) {
      return jsonResponse(
        { error: "Server configuration is incomplete" },
        500,
      );
    }

    const accessToken = getAccessToken(req);
    if (!accessToken) {
      return jsonResponse({ error: "Unauthorized" }, 401);
    }

    const admin = createClient(supabaseUrl, serviceRoleKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    });

    const user = await resolveCurrentUser(admin, accessToken);
    const userId = user.id;

    const avatarUrl = await fetchAvatarUrl(admin, userId);
    await deleteUserData(admin, userId);
    await deleteAvatars(admin, avatarUrl, userId);
    await deleteAuthUser(admin, userId);

    return jsonResponse({ message: "Account deleted successfully" }, 200);
  } catch (error) {
    console.error("delete-account failed", error);
    return jsonResponse(
      {
        error: "Failed to delete account",
        details: error instanceof Error ? error.message : String(error),
      },
      500,
    );
  }
});

async function fetchAvatarUrl(
  admin: ReturnType<typeof createClient>,
  userId: string,
): Promise<string | null> {
  const { data, error } = await admin
    .from("profiles")
    .select("avatar_url")
    .eq("id", userId)
    .maybeSingle();

  if (error) {
    const message = error.message.toLowerCase();
    if (message.includes("does not exist")) {
      return null;
    }
    throw error;
  }

  return typeof data?.avatar_url === "string" ? data.avatar_url : null;
}

async function deleteUserData(
  admin: ReturnType<typeof createClient>,
  userId: string,
): Promise<void> {
  for (const target of cleanupTargets) {
    const { error } = await admin
      .from(target.table)
      .delete()
      .eq(target.column, userId);
    if (!error) {
      continue;
    }

    const message = `${error.code ?? ""} ${error.message ?? ""}`.toLowerCase();
    if (
      message.includes("does not exist") ||
      message.includes("could not find the table") ||
      message.includes("42p01")
    ) {
      continue;
    }

    throw error;
  }
}

async function deleteAvatars(
  admin: ReturnType<typeof createClient>,
  avatarUrl: string | null,
  userId: string,
): Promise<void> {
  const storage = admin.storage.from("profile-avatars");
  const paths = new Set<string>();

  const listed = await storage.list(userId, { limit: 100 });
  for (const item of listed.data ?? []) {
    if (item?.name) {
      paths.add(`${userId}/${item.name}`);
    }
  }

  const extractedPath = extractStoragePath(avatarUrl);
  if (extractedPath) {
    paths.add(extractedPath);
  }

  if (paths.size === 0) {
    return;
  }

  const { error } = await storage.remove([...paths]);
  if (!error) {
    return;
  }

  const message = error.message.toLowerCase();
  if (message.includes("not found") || message.includes("does not exist")) {
    return;
  }

  throw error;
}

async function deleteAuthUser(
  admin: ReturnType<typeof createClient>,
  userId: string,
): Promise<void> {
  const { error } = await admin.auth.admin.deleteUser(userId);
  if (!error) {
    return;
  }

  const message = error.message.toLowerCase();
  if (message.includes("not found") || message.includes("does not exist")) {
    return;
  }

  throw error;
}

async function resolveCurrentUser(
  admin: ReturnType<typeof createClient>,
  accessToken: string,
): Promise<{ id: string }> {
  const { data, error } = await admin.auth.getUser(accessToken);
  if (error || !data.user?.id) {
    throw new Error("User session is no longer valid.");
  }

  return { id: data.user.id };
}

function getAccessToken(req: Request): string | null {
  const authHeader = req.headers.get("authorization");
  if (!authHeader) {
    return null;
  }

  const token = authHeader.replace(/^Bearer\s+/i, "").trim();
  if (token.length === 0) {
    return null;
  }

  return token;
}

function extractStoragePath(avatarUrl: string | null): string | null {
  if (!avatarUrl) {
    return null;
  }

  try {
    const url = new URL(avatarUrl);
    const marker = "/storage/v1/object/public/profile-avatars/";
    const index = url.pathname.indexOf(marker);
    if (index === -1) {
      return null;
    }

    return url.pathname.slice(index + marker.length);
  } catch {
    return null;
  }
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
