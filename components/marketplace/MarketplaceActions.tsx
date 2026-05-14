"use client";

export default function MarketplaceActions({ listingId, buyerCompanyId }: { listingId: string; buyerCompanyId: string; }) {
  async function rent() {
    const res = await fetch("/api/marketplace-rent", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ listing_id: listingId, buyer_company_id: buyerCompanyId })
    });
    alert(JSON.stringify(await res.json(), null, 2));
  }

  return (
    <div className="flex gap-3 mt-6">
      <button className="primary-button" onClick={rent}>Rent / Buy</button>
      <button className="secondary-button">Details</button>
    </div>
  );
}
