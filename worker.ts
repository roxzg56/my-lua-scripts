// ============================================
// DENO DEPLOY WORKER - PUBG Mod Loader
// ============================================

const kv = await Deno.openKv();

function ensureMinLength(code: string, minLen = 51): string {
  if (code.length >= minLen) return code;
  return code + "\n".repeat(minLen - code.length);
}

Deno.serve(async (request: Request) => {
  const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET, POST, PUT, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, Authorization",
    "Content-Type": "text/plain; charset=utf-8",
  };

  // CORS preflight
  if (request.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders });
  }

  const url = new URL(request.url);

  // ---------- ADMIN UPLOAD (POST /admin/upload?key=1.lua) ----------
  if (url.pathname === "/admin/upload" && request.method === "POST") {
    // सिक्योरिटी: Authorization header चेक करो (URL से secret हटाया)
    const auth = request.headers.get("Authorization");
    const expectedToken = "Bearer mysecrettoken123";  // ⚠️ इसे बदल देना
    if (auth !== expectedToken) {
      return new Response("Unauthorized", { status: 401, headers: corsHeaders });
    }

    const key = url.searchParams.get("key");
    if (!key) {
      return new Response("Missing ?key=filename.lua", { status: 400, headers: corsHeaders });
    }

    const luaCode = await request.text();
    if (!luaCode) {
      return new Response("Empty body", { status: 400, headers: corsHeaders });
    }

    await kv.set(["mods", key], luaCode);
    return new Response(`✅ Uploaded ${key} (${luaCode.length} bytes)`, {
      status: 200,
      headers: corsHeaders,
    });
  }

  // ---------- MAIN SCRIPT FETCHER (POST with key_path) ----------
  if (request.method === "POST") {
    let keyPath = "1.lua";
    try {
      const body = await request.text();
      const params = new URLSearchParams(body);
      keyPath = params.get("key_path") || "1.lua";
    } catch (_) { /* ignore */ }

    console.log("Loading:", keyPath);

    let luaCode: string | null = null;
    try {
      const result = await kv.get<string>(["mods", keyPath]);
      luaCode = result.value;
    } catch (_) { /* ignore */ }

    if (!luaCode) {
      luaCode = `-- Fallback for ${keyPath}\nprint("[Mod] KV empty")`;
    }

    luaCode = ensureMinLength(luaCode);
    return new Response(luaCode, { status: 200, headers: corsHeaders });
  }

  // ---------- Health check (GET) ----------
  if (request.method === "GET") {
    return new Response("PUBG Mod Loader Deno Worker 🟢", {
      status: 200,
      headers: corsHeaders,
    });
  }

  return new Response("Method not allowed", { status: 405, headers: corsHeaders });
});
