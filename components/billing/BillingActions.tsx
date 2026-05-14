"use client";

export default function BillingActions({ companyId, packId, amount, credits }: { companyId: string; packId?: string; amount: number; credits: number; }) {
  async function stripeCheckout() {
    const res = await fetch("/api/stripe-checkout", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ company_id: companyId, pack_id: packId, amount, credits, currency: "usd", name: "UNIC.ai Credit Pack" })
    });
    const data = await res.json();
    if (data.url) window.location.href = data.url;
    else alert(JSON.stringify(data, null, 2));
  }

  async function razorpayOrder() {
    const res = await fetch("/api/razorpay-order", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ company_id: companyId, pack_id: packId, amount, credits, currency: "INR" })
    });
    alert(JSON.stringify(await res.json(), null, 2));
  }

  return (
    <div className="flex gap-3 mt-6">
      <button className="primary-button" onClick={stripeCheckout}>Pay with Stripe</button>
      <button className="secondary-button" onClick={razorpayOrder}>Razorpay Order</button>
    </div>
  );
}
