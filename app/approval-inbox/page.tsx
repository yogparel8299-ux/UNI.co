import AppShell from "@/components/layout/AppShell";

export default function ApprovalInboxPage() {
  return (
    <AppShell>
      <section className="p-6 lg:p-10">
        <h1 className="text-6xl font-black tracking-[-0.07em]">Approval Inbox</h1>
        <p className="mt-5 max-w-2xl text-slate-500 leading-8">Review sensitive actions before agents execute them.</p>

        <div className="mt-8 space-y-5">
          {["Send customer email", "Publish social post", "Run supplier outreach", "Update CRM record"].map((x) => (
            <div key={x} className="flex items-center justify-between rounded-[28px] border border-slate-200 bg-white p-6 shadow-sm">
              <div>
                <h2 className="text-2xl font-black tracking-[-0.04em]">{x}</h2>
                <p className="mt-2 text-slate-500">Requires human approval before execution.</p>
              </div>
              <div className="flex gap-3">
                <button className="rounded-full border border-slate-200 px-5 py-3 font-bold">Reject</button>
                <button className="rounded-full bg-slate-950 px-5 py-3 font-bold text-white">Approve</button>
              </div>
            </div>
          ))}
        </div>
      </section>
    </AppShell>
  );
}
