import Shell from "@/components/Shell";
import Card from "@/components/Card";

export default function Settings() {
  return (
    <Shell title="Settings">
      <div className="grid grid-cols-3 gap-6">
        <Card title="Brand" value="UNIC.ai" />
        <Card title="Theme" value="Light Premium" />
        <Card title="Backend" value="Supabase" />
      </div>
    </Shell>
  );
}
