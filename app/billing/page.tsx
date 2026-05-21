import AppShell from "@/components/unic/AppShell";
import { getProviderStatus } from "@/lib/guards/providers";

export default function BillingPage() {
  const status = getProviderStatus();
  const paymentsReady = status.stripe || status.razorpay;

  return (
    <AppShell title="Billing" subtitle="Plans, credits and payment status.">
      {!paymentsReady && (
        <div className="mb-6 rounded-2xl border border-amber-200 bg-amber-50 p-5">
          <p className="font-black text-amber-800">Payments are not active yet</p>
          <p className="mt-2 text-sm text-amber-700">
            Stripe/Razorpay keys are not configured. Checkout, starter packs and credit purchases are disabled until the owner adds payment keys.
          </p>
        </div>
      )}

      <div className="grid gap-4 md:grid-cols-4">
        {["Starter", "Builder", "Company", "Enterprise"].map((plan) => (
          <div key={plan} className="rounded-2xl border border-neutral-200 bg-white p-6">
            <h2 className="text-2xl font-black">{plan}</h2>
            <p className="mt-4 text-sm text-neutral-500">Credit-based workspace plan.</p>
            <button
              disabled={!paymentsReady}
              className={
                paymentsReady
                  ? "mt-6 rounded-xl bg-black px-5 py-3 text-sm font-bold text-white"
                  : "mt-6 rounded-xl bg-neutral-200 px-5 py-3 text-sm font-bold text-neutral-500"
              }
            >
              {paymentsReady ? "Select" : "Disabled"}
            </button>
          </div>
        ))}
      </div>
    </AppShell>
  );
}
