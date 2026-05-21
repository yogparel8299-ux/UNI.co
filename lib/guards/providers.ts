export function envReady(name: string) {
  const value = process.env[name];
  return !!value && value.trim() !== "" && value !== "pending" && value !== "placeholder";
}

export function getProviderStatus() {
  return {
    openai: envReady("OPENAI_API_KEY"),
    stripe: envReady("STRIPE_SECRET_KEY"),
    razorpay: envReady("RAZORPAY_KEY_ID") && envReady("RAZORPAY_KEY_SECRET"),
    composio: envReady("COMPOSIO_API_KEY"),
    supabase:
      envReady("NEXT_PUBLIC_SUPABASE_URL") &&
      envReady("NEXT_PUBLIC_SUPABASE_ANON_KEY") &&
      envReady("SUPABASE_SERVICE_ROLE_KEY")
  };
}

export function requireProvider(provider: "openai" | "stripe" | "razorpay" | "composio") {
  const status = getProviderStatus();

  if (!status[provider]) {
    throw new Error(
      `${provider.toUpperCase()} is not configured yet. This action is disabled until the platform owner adds the required keys.`
    );
  }

  return true;
}
