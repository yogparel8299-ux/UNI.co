import AppShell from "@/components/layout/AppShell";
import Empty from "@/components/ui/Empty";

export default function AgentsPage() {
  return (
    <AppShell
      title="Agents"
      subtitle="Create AI workers with connected skills and tools."
    >
      <Empty
        title="No agents yet"
        text="Create your first AI worker and assign skills, memory, workflows and connected tools."
        action="Create Agent"
        href="/builder"
      />
    </AppShell>
  );
}
