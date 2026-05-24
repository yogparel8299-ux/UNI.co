import PublicHeroShell from "@/components/unic/PublicHeroShell";

export default function Page() {
  return (
    <PublicHeroShell
      badge="Pricing for AI-native teams"
      title="Clear credits, clean plans, no confusing infrastructure."
      subtext="Choose the runtime that fits your company."
      cta="Open billing"
      ctaHref="/billing"
    />
  );
}
