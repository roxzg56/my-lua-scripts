const fs = require('fs');
const path = require('path');

export default async function handler(req, res) {
  // CORS headers (optional but safe)
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  if (req.method !== 'POST') {
    return res.status(405).send('Method Not Allowed');
  }

  // Parse key_path from body
  let keyPath = '1.lua';
  try {
    const body = req.body;
    if (body && body.key_path) {
      keyPath = body.key_path;
    } else {
      // fallback if body is raw string
      const raw = typeof body === 'string' ? body : JSON.stringify(body);
      const match = raw.match(/key_path=([^&]+)/);
      if (match) keyPath = match[1];
    }
  } catch (e) {
    return res.status(400).send('Invalid body');
  }

  // Basic validation
  if (!/^[1-5]\.lua$/.test(keyPath)) {
    return res.status(400).send('Invalid key_path (1.lua to 5.lua only)');
  }

  try {
    // Path to scripts/ folder inside project
    const filePath = path.join(process.cwd(), 'scripts', keyPath);
    let luaCode = fs.readFileSync(filePath, 'utf8');

    // Ensure >50 bytes (original requirement)
    if (luaCode.length < 51) {
      luaCode = luaCode.padEnd(51, '\n');
    }

    res.setHeader('Content-Type', 'text/plain; charset=utf-8');
    return res.status(200).send(luaCode);
  } catch (err) {
    return res.status(404).send('File not found');
  }
}
