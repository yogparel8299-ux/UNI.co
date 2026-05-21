"use client";

import { useEffect, useState } from "react";

export default function RealtimeDashboardPage() {
  const [metrics, setMetrics] = useState<any[]>([]);

  useEffect(() => {
    async function load() {
      const res = await fetch("/api/realtime-dashboard-metrics");
      const data = await res.json();
      setMetrics(data.metrics || []);
    }

    load();

    const interval = setInterval(load, 5000);

    return () => clearInterval(interval);
  }, []);

  return (
    <main className="page-shell">
      <section className="main">
        <h1 className="page-title">
          Realtime Dashboard
        </h1>

        <p className="page-subtitle">
          Live company operations, runtime metrics and execution monitoring.
        </p>

        <div className="grid grid-cols-4 gap-5 mt-10">
          {metrics.map((metric) => (
            <div
              key={metric.id}
              className="glass-card p-6"
            >
              <p className="text-gray-500 text-sm">
                {metric.metric_key}
              </p>

              <h2 className="text-4xl font-black mt-3">
                {metric.metric_value}
              </h2>
            </div>
          ))}
        </div>
      </section>
    </main>
  );
}
