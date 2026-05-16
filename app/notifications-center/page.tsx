"use client";

import { useEffect, useState } from "react";

export default function NotificationsCenterPage() {
  const [notifications, setNotifications] = useState<any[]>([]);

  useEffect(() => {
    async function load() {
      const res = await fetch("/api/fetch-notifications");
      const data = await res.json();
      setNotifications(data.notifications || []);
    }

    load();
  }, []);

  return (
    <main className="page-shell">
      <section className="main">
        <h1 className="page-title">
          Notifications
        </h1>

        <div className="space-y-4 mt-10">
          {notifications.map((n) => (
            <div
              key={n.id}
              className="glass-card p-5"
            >
              <div className="flex items-center justify-between">
                <h2 className="text-xl font-black">
                  {n.title}
                </h2>

                <span className="text-xs text-gray-400">
                  {n.severity}
                </span>
              </div>

              <p className="text-gray-500 mt-3">
                {n.message}
              </p>
            </div>
          ))}
        </div>
      </section>
    </main>
  );
}
