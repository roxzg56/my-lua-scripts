const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = process.env.PORT || 3000;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type",
  "Content-Type": "text/plain; charset=utf-8"
};

const server = http.createServer(async (req, res) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);

  // Handle CORS
  if (req.method === "OPTIONS") {
    res.writeHead(204, corsHeaders);
    return res.end();
  }

  if (req.method === "POST") {
    let body = '';

    req.on('data', chunk => {
      body += chunk.toString();
    });

    req.on('end', () => {
      try {
        console.log("[BODY]", body);

        // Parse key_path from POST body
        let keyPath = "1.lua";
        const match = body.match(/key_path=([^&]+)/);
        if (match) {
          keyPath = decodeURIComponent(match[1]);
        }

        console.log("[KEY_PATH]", keyPath);

        // Validate file number
        const fileMatch = keyPath.match(/^(\d+)/);
        if (!fileMatch) {
          res.writeHead(400, corsHeaders);
          return res.end("ERROR: Invalid key_path format");
        }

        const fileNumber = parseInt(fileMatch[1]);
        if (fileNumber < 1 || fileNumber > 8) {
          res.writeHead(400, corsHeaders);
          return res.end("ERROR: File number 1-8 only");
        }

        // Read file from scripts folder
        const filePath = path.join(__dirname, 'scripts', `${fileNumber}.lua`);
        
        console.log("[READ FILE]", filePath);

        fs.readFile(filePath, 'utf8', (err, data) => {
          if (err) {
            console.error("[FILE ERROR]", err);
            res.writeHead(404, corsHeaders);
            return res.end(`ERROR: Script ${fileNumber} not found`);
          }

          let luaCode = data.replace(/\r\n/g, '\n').trim();

          // Ensure > 50 bytes
          if (luaCode.length < 51) {
            luaCode = luaCode + "\n-- Padding\n".repeat((51 - luaCode.length) / 10);
          }

          console.log("[SUCCESS]", luaCode.length, "bytes");

          res.writeHead(200, corsHeaders);
          res.end(luaCode);
        });

      } catch (error) {
        console.error("[ERROR]", error);
        res.writeHead(500, corsHeaders);
        res.end(`ERROR: ${error.message}`);
      }
    });

  } else {
    res.writeHead(200, corsHeaders);
    res.end('Lua Loader Ready');
  }
});

server.listen(PORT, () => {
  console.log(`🚀 Lua Loader Server running on port ${PORT}`);
  console.log(`📍 https://your-app.up.railway.app`);
});
