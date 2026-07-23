// pages/api/fetch-lua.js
// Vercel API Route - GitHub से Lua scripts fetch करेगा

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { key_path } = req.body;

    if (!key_path) {
      return res.status(400).json({ error: 'key_path parameter is required' });
    }

    // Extract file number (e.g., "1.lua" -> 1)
    const fileMatch = key_path.match(/^(\d+)\.lua$/);
    if (!fileMatch) {
      return res.status(400).json({ error: 'Invalid key_path format' });
    }

    const fileNumber = parseInt(fileMatch[1]);

    if (fileNumber < 1 || fileNumber > 8) {
      return res.status(400).json({ error: 'File number must be between 1 and 8' });
    }

    // ⭐ GITHUB SE FETCH करेगा - अपना username और repo name डालो
    const GITHUB_USERNAME = "roxzg56"; // यहाँ अपना GitHub username डालो
    const GITHUB_REPO = "my-lua-scripts"; // Repository का नाम
    const GITHUB_BRANCH = "main";

    const githubUrl = `https://raw.githubusercontent.com/${GITHUB_USERNAME}/${GITHUB_REPO}/${GITHUB_BRANCH}/scripts/${fileNumber}.lua`;

    console.log(`Fetching from: ${githubUrl}`);

    const response = await fetch(githubUrl);

    if (!response.ok) {
      return res.status(404).json({ error: `Script ${fileNumber} not found on GitHub` });
    }

    const scriptContent = await response.text();

    // Return as plain text
    res.setHeader('Content-Type', 'text/plain; charset=utf-8');
    return res.status(200).send(scriptContent);

  } catch (error) {
    console.error('Error:', error);
    return res.status(500).json({ error: 'Internal server error', message: error.message });
  }
}
