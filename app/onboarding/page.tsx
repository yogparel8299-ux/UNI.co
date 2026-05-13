"use client";

import { useState } from "react";
import { supabaseBrowser } from "@/lib/supabase-browser";

export default function OnboardingPage() {
  const [companyName, setCompanyName] = useState("");
  const [loading, setLoading] = useState(false);

  async function createCompany() {
    setLoading(true);

    const supabase = supabaseBrowser();
    const { data: userData } = await supabase.auth.getUser();

    if (!userData.user) {
      alert("Please login first.");
      window.location.href = "/auth";
      return;
    }

    const res = await fetch("/api/onboarding", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        company_name: companyName,
        user_id: userData.user.id,
        email: userData.user.email
      })
    });

    const data = await res.json();

    setLoading(false);

    if (!data.ok) {
      alert(data.error);
      return;
    }

    window.location.href = "/command";
  }

  return (
    <main className="min-h-screen bg-white flex items-center justify-center p-10">
      <div className="glass-card p-10 max-w-xl w-full">
        <p className="text-green-600 font-bold">UNIC.ai onboarding</p>

        <h1 className="text-5xl font-black tracking-[-0.05em] mt-4">
          Create your company workspace.
        </h1>

        <p className="text-gray-500 mt-5 leading-7">
          Everything created in this workspace is registered under company ownership rules.
        </p>

        <input
          className="input-box mt-8"
          placeholder="Company name"
          value={companyName}
          onChange={(e) => setCompanyName(e.target.value)}
        />

        <button
          onClick={createCompany}
          disabled={loading}
          className="primary-button mt-6 w-full"
        >
          {loading ? "Creating..." : "Create Workspace"}
        </button>
      </div>
    </main>
  );
}
