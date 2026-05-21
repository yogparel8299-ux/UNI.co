import AppShell from "@/components/layout/AppShell";
import Empty from "@/components/ui/Empty";

export default function DatasetsPage() {
  return (
    <AppShell
      title="Datasets"
      subtitle="Upload files and build company memory for AI execution."
    >
      <Empty
        title="No datasets uploaded"
        text="Upload PDF, CSV, DOCX and structured business data for retrieval and AI memory."
        action="Upload Dataset"
        href="/dataset-lab"
      />
    </AppShell>
  );
}
