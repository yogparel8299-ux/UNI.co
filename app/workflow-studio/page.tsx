import AppShell from "@/components/unic/AppShell";
import DraggableWorkflowCanvas from "@/components/workflow/DraggableWorkflowCanvas";
import { getWorkspace } from "@/lib/server/workspace";

export default async function WorkflowStudioPage() {
  const { user, companyId } = await getWorkspace();
  if (!user) return <main className="grid min-h-screen place-items-center bg-[#f7f7f8] p-6"><div className="rounded-3xl border border-neutral-200 bg-white p-10 text-center"><h1 className="text-4xl font-black">Login required</h1><p className="mt-3 text-neutral-500">Login to access Workflow Studio.</p></div></main>;

  return (
    <AppShell title="Workflow Studio" subtitle="Drag, save and execute workflow graphs." right={<div className="p-5"><p className="text-xs font-black uppercase tracking-[.16em] text-neutral-400">Canvas</p><h2 className="mt-3 text-xl font-black">Drag + Save Enabled</h2><p className="mt-4 text-sm leading-6 text-neutral-500">Nodes can be moved with the mouse. Save Graph persists node positions to Supabase.</p><p className="mt-4 break-all text-xs text-neutral-400">company_id: {companyId || "missing"}</p></div>}>
      <DraggableWorkflowCanvas companyId={companyId} />
    </AppShell>
  );
}
