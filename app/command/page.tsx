import Shell from "@/components/Shell";
import CommandCenter from "@/components/CommandCenter";

export default function CommandPage() {
  return (
    <Shell
      title="AI Command Center"
      subtitle="Talk to UNIC.ai like an operating system. Ask it to build companies, agents, workflows and outputs."
    >
      <CommandCenter />
    </Shell>
  );
}
