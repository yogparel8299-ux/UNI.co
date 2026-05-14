export async function createComposioAuthLink({
  userId,
  toolkit,
  redirectUrl
}: {
  userId: string;
  toolkit: string;
  redirectUrl?: string;
}) {
  const apiKey = process.env.COMPOSIO_API_KEY;
  if (!apiKey) throw new Error("COMPOSIO_API_KEY missing.");

  const res = await fetch("https://backend.composio.dev/api/v3.1/connected_accounts/link", {
    method: "POST",
    headers: {
      "x-api-key": apiKey,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      user_id: userId,
      toolkit,
      redirect_url: redirectUrl || process.env.NEXT_PUBLIC_APP_URL || "http://localhost:3000/connectors"
    })
  });

  const data = await res.json();
  if (!res.ok) throw new Error(data.message || "Composio auth link failed.");
  return data;
}

export async function executeComposioTool({
  userId,
  toolkit,
  toolSlug,
  argumentsJson
}: {
  userId: string;
  toolkit: string;
  toolSlug: string;
  argumentsJson: any;
}) {
  const apiKey = process.env.COMPOSIO_API_KEY;
  if (!apiKey) throw new Error("COMPOSIO_API_KEY missing.");

  const res = await fetch("https://backend.composio.dev/api/v3/tools/execute", {
    method: "POST",
    headers: {
      "x-api-key": apiKey,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      user_id: userId,
      toolkit,
      tool_slug: toolSlug,
      arguments: argumentsJson || {}
    })
  });

  const data = await res.json();
  if (!res.ok) throw new Error(data.message || "Composio tool execution failed.");
  return data;
}
