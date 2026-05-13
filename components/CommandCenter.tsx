"use client";

import { useState } from "react";

export default function CommandCenter() {
  const [command, setCommand] = useState("");
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<any>(null);

  async function runCommand() {
    if (!command.trim()) return;

    setLoading(true);
    setResult(null);

    try {
      const res = await fetch("/api/command", {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify({ command })
      });

      const data = await res.json();
      setResult(data);
    } catch (err: any) {
      setResult({
        ok: false,
        error: err.message || "Command failed"
      });
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="glass-card p-8">
      <div className="flex items-start justify-between gap-8">
        <div>
          <p className="text-green-600 font-bold mb-3">
            UNIC.ai Command Center
          </p>

          <h2 className="text-4xl font-black tracking-[-0.045em]">
            Tell UNIC.ai what to build.
          </h2>

          <p className="text-gray-500 mt-4 max-w-3xl leading-7">
            Create companies, agents, workflows, tasks and queued execution jobs from one natural-language command.
          </p>
        </div>

        <div className="status-pill">
          AI Builder Active
        </div>
      </div>

      <textarea
        value={command}
        onChange={(e) => setCommand(e.target.value)}
        placeholder="Example: Build me a company for an AI sales agency. Create a CEO agent, sales closer agent, email marketing agent, workflow and run the first output."
        className="input-box mt-8 min-h-[180px] text-lg"
      />

      <div className="mt-5 flex gap-4">
        <button
          onClick={runCommand}
          disabled={loading}
          className="primary-button disabled:opacity-60"
        >
          {loading ? "Building..." : "Run Command"}
        </button>

        <button
          onClick={() =>
            setCommand(
              "Build me a company for an AI sales agency. Create a CEO agent, sales closer agent, email marketing agent, a workflow to find leads and send outreach, and run the first output."
            )
          }
          className="secondary-button"
        >
          Use Example
        </button>
      </div>

      {result && (
        <div className="mt-8 rounded-[28px] border border-black/10 bg-white p-6">
          <p className="font-bold text-lg">
            Result
          </p>

          {result.ok ? (
            <div className="mt-4 space-y-4">
              <p className="text-gray-700">
                {result.response}
              </p>

              <div className="grid grid-cols-4 gap-4">
                <div className="rounded-2xl bg-gray-50 p-4">
                  <p className="text-gray-500 text-sm">Company</p>
                  <p className="font-bold">{result.company ? "Created" : "Used"}</p>
                </div>

                <div className="rounded-2xl bg-gray-50 p-4">
                  <p className="text-gray-500 text-sm">Agents</p>
                  <p className="font-bold">{result.agents?.length || 0}</p>
                </div>

                <div className="rounded-2xl bg-gray-50 p-4">
                  <p className="text-gray-500 text-sm">Workflows</p>
                  <p className="font-bold">{result.workflows?.length || 0}</p>
                </div>

                <div className="rounded-2xl bg-gray-50 p-4">
                  <p className="text-gray-500 text-sm">Queued Jobs</p>
                  <p className="font-bold">{result.queued_jobs?.length || 0}</p>
                </div>
              </div>

              <pre className="overflow-auto rounded-2xl bg-gray-950 text-green-300 p-5 text-xs max-h-[420px]">
                {JSON.stringify(result, null, 2)}
              </pre>
            </div>
          ) : (
            <p className="mt-4 text-red-600">
              {result.error}
            </p>
          )}
        </div>
      )}
    </div>
  );
}
