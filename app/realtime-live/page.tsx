"use client";

import { useEffect, useState } from "react";
import { supabaseBrowser } from "@/lib/supabase-browser";

export default function RealtimeLivePage() {
  const [events, setEvents] = useState<any[]>([]);

  useEffect(() => {
    const supabase = supabaseBrowser();
    const channel = supabase
      .channel("unic-realtime-streams")
      .on("postgres_changes", { event: "INSERT", schema: "public", table: "realtime_streams" }, (payload) => {
        setEvents((current) => [payload.new, ...current].slice(0, 100));
      })
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, []);

  return (
    <main className="page-shell">
      <section className="main">
        <h1 className="page-title">Realtime Live</h1>
        <p className="page-subtitle">Live Supabase realtime subscription for runtime events.</p>
        <div className="glass-card p-8 mt-10">
          {events.length === 0 && <p className="text-gray-500">Waiting for realtime events...</p>}
          <div className="space-y-4">
            {events.map((event, index) => (
              <div key={event.id || index} className="rounded-2xl border border-black/10 p-4 bg-white">
                <p className="font-bold">{event.event}</p>
                <pre className="text-xs text-gray-500 mt-2 overflow-auto">{JSON.stringify(event.payload, null, 2)}</pre>
              </div>
            ))}
          </div>
        </div>
      </section>
    </main>
  );
}
