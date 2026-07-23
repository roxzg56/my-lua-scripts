const handler = async (req: Request): Promise<Response> => {
  if (req.method === 'POST') {
    try {
      const body = await req.text();
      const keyMatch = body.match(/key_path=([^&]+)/);
      if (!keyMatch) {
        return new Response('ERROR: key_path required', { 
          status: 400,
          headers: { 'Content-Type': 'text/plain' }
        });
      }

      const key_path = keyMatch[1];
      const fileMatch = key_path.match(/^(\d+)/);
      if (!fileMatch) {
        return new Response('ERROR: Invalid format', { 
          status: 400,
          headers: { 'Content-Type': 'text/plain' }
        });
      }

      const fileNumber = parseInt(fileMatch[1]);
      if (fileNumber < 1 || fileNumber > 8) {
        return new Response('ERROR: 1-8 only', { 
          status: 400,
          headers: { 'Content-Type': 'text/plain' }
        });
      }

      const GITHUB_USERNAME = "roxzg56";
      const githubUrl = `https://raw.githubusercontent.com/${GITHUB_USERNAME}/my-lua-scripts/main/scripts/${fileNumber}.lua`;

      const ghResponse = await fetch(githubUrl);

      if (!ghResponse.ok) {
        return new Response(`Script ${fileNumber} not found`, { 
          status: 404,
          headers: { 'Content-Type': 'text/plain' }
        });
      }

      let content = await ghResponse.text();
      content = content.replace(/\r\n/g, '\n').trim();

      return new Response(content, {
        status: 200,
        headers: {
          'Content-Type': 'text/plain; charset=utf-8',
          'Access-Control-Allow-Origin': '*',
          'Cache-Control': 'no-cache'
        }
      });

    } catch (error) {
      return new Response(`ERROR: ${error.message}`, { 
        status: 500,
        headers: { 'Content-Type': 'text/plain' }
      });
    }
  }

  return new Response('Lua Loader Ready', { 
    status: 200,
    headers: { 'Content-Type': 'text/plain' }
  });
};
