export async function callComposioTool({
  connectedAccountId,
  action,
  payload
}: {
  connectedAccountId?: string;
  action: string;
  payload?: any;
}) {
  if (!process.env.COMPOSIO_API_KEY) {
    throw new Error("COMPOSIO_API_KEY missing.");
  }

  const res = await fetch(
    "https://backend.composio.dev/api/v3/tools/execute",
    {
      method: "POST",
      headers: {
        "x-api-key": process.env.COMPOSIO_API_KEY!,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        connected_account_id: connectedAccountId,
        tool_slug: action,
        arguments: payload || {}
      })
    }
  );

  const text = await res.text();

  let json: any;

  try {
    json = JSON.parse(text);
  } catch {
    json = { raw: text };
  }

  if (!res.ok) {
    throw new Error(
      json?.message ||
        json?.error ||
        "Composio execution failed."
    );
  }

  return json;
}

export async function executeComposioTool(args: any) {
  return callComposioTool(args);
}

export async function createComposioAuthLink({
  userId,
  toolkit
}: {
  userId: string;
  toolkit: string;
}) {
  if (!process.env.COMPOSIO_API_KEY) {
    throw new Error("COMPOSIO_API_KEY missing.");
  }

  const appUrl =
    process.env.NEXT_PUBLIC_APP_URL ||
    "http://localhost:3000";

  const res = await fetch(
    "https://backend.composio.dev/api/v3/connected_accounts/initiate",
    {
      method: "POST",
      headers: {
        "x-api-key": process.env.COMPOSIO_API_KEY!,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        toolkit,
        user_id: userId,
        callback_url:
          `${appUrl}/connection-layer`
      })
    }
  );

  const text = await res.text();

  let json: any;

  try {
    json = JSON.parse(text);
  } catch {
    json = { raw: text };
  }

  if (!res.ok) {
    throw new Error(
      json?.message ||
        json?.error ||
        "Composio auth failed."
    );
  }

  return json;
}
