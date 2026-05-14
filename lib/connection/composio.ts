export async function createConnectionLink({
  userId,
  toolkit,
  redirectUrl
}: {
  userId: string;
  toolkit: string;
  redirectUrl: string;
}) {
  const apiKey = process.env.COMPOSIO_API_KEY;

  if (!apiKey) {
    throw new Error("COMPOSIO_API_KEY is missing.");
  }

  const response = await fetch("https://backend.composio.dev/api/v3.1/connected_accounts/link", {
    method: "POST",
    headers: {
      "x-api-key": apiKey,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      user_id: userId,
      toolkit,
      redirect_url: redirectUrl
    })
  });

  const data = await response.json();

  if (!response.ok) {
    throw new Error(data.message || "Failed to create Composio connection link.");
  }

  return data;
}

export async function executeTool({
  userId,
  toolkit,
  toolSlug,
  args
}: {
  userId: string;
  toolkit: string;
  toolSlug: string;
  args: any;
}) {
  const apiKey = process.env.COMPOSIO_API_KEY;

  if (!apiKey) {
    throw new Error("COMPOSIO_API_KEY is missing.");
  }

  const response = await fetch("https://backend.composio.dev/api/v3/tools/execute", {
    method: "POST",
    headers: {
      "x-api-key": apiKey,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      user_id: userId,
      toolkit,
      tool_slug: toolSlug,
      arguments: args || {}
    })
  });

  const data = await response.json();

  if (!response.ok) {
    throw new Error(data.message || "Tool execution failed.");
  }

  return data;
}
