import Shell from "@/components/Shell";
import VisualWorkflowEditor from "@/components/workflow/VisualWorkflowEditor";

export default function WorkflowStudioPage() {
  return (
    <Shell
      title="Workflow Studio"
      subtitle="Drag-and-drop AI workflows, tools, memory, approvals and runtime steps."
    >
      <VisualWorkflowEditor />
    </Shell>
  );
}
