export function envReady(name: string) {
  const value = process.env[name];

  return (
    !!value &&
    value.trim() !== "" &&
    value !== "pending" &&
    value !== "placeholder"
  );
}

export function getProviderStatus() {
  return {
    openai: envReady("OPENAI_API_KEY"),
    stripe: envReady("STRIPE_SECRET_KEY"),
    razorpay:
      envReady("RAZORPAY_KEY_ID") &&
      envReady("RAZORPAY_KEY_SECRET"),
    composio: envReady("COMPOSIO_API_KEY"),
    supabase:
      envReady("NEXT_PUBLIC_SUPABASE_URL") &&
      envReady("NEXT_PUBLIC_SUPABASE_ANON_KEY") &&
      envReady("SUPABASE_SERVICE_ROLE_KEY")
  };
}

export function requireProvider(provider: string) {
  const providers = getProviderStatus();

  const exists =
    provider === "openai"
      ? providers.openai
      : provider === "stripe"
      ? providers.stripe
      : provider === "razorpay"
      ? providers.razorpay
      : provider === "composio"
      ? providers.composio
      : false;

  if (!exists) {
    throw new Error(
      `${provider.toUpperCase()} provider is not configured.`
    );
  }

  return true;
}
