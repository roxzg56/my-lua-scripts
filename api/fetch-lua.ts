import { serve } from "https://deno.land/std@0.208.0/http/server.ts";

const handler = (req: Request): Response => {
  if (req.method === "POST") {
    return handlePost(req);
  }
  
  return new Response("Lua Loader Ready", { 
    status: 200,
    headers: { "Content-Type": "text/plain" }
  });
};

async function handlePost(req: Request): Promise<Response> {
  try {
    const body = await req.text();
    console.log("[REQUEST]", body);

    const keyMatch = body.match(/key_path=([^&]+)/);
    if (!keyMatch) {
      return new Response("ERROR: key_path required", { status: 400 });
    }

    const key_path = keyMatch[1];
    console.log("[KEY_PATH]", key_path);

    const fileMatch = key_path.match(/^(\d+)/);
    if (!fileMatch) {
      return new Response("ERROR: Invalid format", { status: 400 });
    }

    const fileNumber = parseInt(fileMatch[1]);
    if (fileNumber < 1 || fileNumber > 8) {
      return new Response("ERROR: 1-8 only", { status: 400 });
    }

    const GITHUB_USERNAME = "roxzg56";
    const githubUrl = `https://raw.githubusercontent.com/${GITHUB_USERNAME}/my-lua-scripts/main/scripts/${fileNumber}.lua`;

    console.log("[FETCH]", githubUrl);

    const response = await fetch(githubUrl);

    if (!response.ok) {
      return new Response(`Script ${fileNumber} not found`, { status: 404 });
    }

    let content = await response.text();
    content = content.replace(/\r\n/g, "\n").trim();

    console.log("[SUCCESS]", content.length, "bytes");

    return new Response(content, {
      status: 200,
      headers: {
        "Content-Type": "text/plain; charset=utf-8",
        "Access-Control-Allow-Origin": "*",
        "Cache-Control": "no-cache",
      },
    });
  } catch (error) {
    console.error("[ERROR]", error);
    return new Response(`ERROR: ${error.message}`, { status: 500 });
  }
}

serve(handler, { port: 8000 });
