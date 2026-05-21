"use client";

import { useEffect, useState } from "react";

export default function ApprovalInboxPage() {
  const [items, setItems] = useState<any[]>([]);

  useEffect(() => {
    async function load() {
      const res = await fetch("/api/fetch-approval-inbox");
      const data = await res.json();
      setItems(data.items || []);
    }

    load();
  }, []);

  async function approve(id: string) {
    await fetch("/api/approve-action", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        approval_id: id
      })
    });

    location.reload();
  }

  return (
    <main className="page-shell">
      <section className="main">
        <h1 className="page-title">
          Approval Inbox
        </h1>

        <div className="space-y-5 mt-10">
          {items.map((item) => (
            <div
              key={item.id}
              className="glass-card p-6"
            >
              <p className="text-green-600 text-xs font-bold uppercase">
                {item.approval_type}
              </p>

              <h2 className="text-2xl font-black mt-2">
                {item.title}
              </h2>

              <p className="text-gray-500 mt-4">
                {item.description}
              </p>

              <button
                className="primary-button mt-5"
                onClick={() => approve(item.id)}
              >
                Approve
              </button>
            </div>
          ))}
        </div>
      </section>
    </main>
  );
}
