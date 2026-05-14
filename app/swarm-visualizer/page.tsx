import Shell from "@/components/Shell";
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function SwarmVisualizerPage() {
  const { data: swarms } = await supabaseAdmin
    .from("swarms")
    .select("*")
    .order("created_at", {
      ascending: false
    })
    .limit(20);

  const { data: messages } = await supabaseAdmin
    .from("swarm_messages")
    .select("*")
    .order("created_at", {
      ascending: false
    })
    .limit(50);

  return (
    <Shell
      title="Swarm Visualizer"
      subtitle="Visualize AI teams, messages, delegation and agent-to-agent collaboration."
    >
      <div className="grid grid-cols-3 gap-6">
        {(swarms || []).map((swarm) => (
          <div key={swarm.id} className="glass-card p-6">
            <h2 className="text-2xl font-black">
              {swarm.name}
            </h2>

            <p className="text-gray-500 mt-3">
              {swarm.goal || "No goal set."}
            </p>

            <p className="status-pill mt-6">
              {swarm.status}
            </p>
          </div>
        ))}
      </div>

      <div className="glass-card p-8 mt-10">
        <h2 className="text-3xl font-black tracking-[-0.04em] mb-5">
          Swarm Messages
        </h2>

        <div className="space-y-4">
          {(messages || []).map((message) => (
            <div key={message.id} className="rounded-2xl border border-black/10 p-4">
              <p className="font-bold">
                {message.message}
              </p>

              <p className="text-gray-500 text-sm mt-2">
                {new Date(message.created_at).toLocaleString()}
              </p>
            </div>
          ))}
        </div>
      </div>
    </Shell>
  );
}
