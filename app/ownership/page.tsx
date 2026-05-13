import Shell from "@/components/Shell";

export default function Ownership() {
  return (
    <Shell title="Ownership & Licensing" subtitle="UNIC.ai keeps platform-level ownership by default. Enterprise customers can negotiate ownership transfer.">
      <div className="grid grid-cols-3 gap-6">
        <div className="glass-card p-8">
          <h2 className="text-2xl font-black">Starter to Company</h2>
          <p className="text-gray-500 mt-4 leading-7">
            Agents, workflows, templates, runtime systems, generated structures and platform assets are owned by UNIC.ai. Users receive a usage license inside their workspace.
          </p>
        </div>

        <div className="glass-card p-8">
          <h2 className="text-2xl font-black">Enterprise</h2>
          <p className="text-gray-500 mt-4 leading-7">
            Enterprise contracts can include custom ownership terms, private infrastructure, data isolation, SSO, audit controls and asset-transfer rights.
          </p>
        </div>

        <div className="glass-card p-8">
          <h2 className="text-2xl font-black">Marketplace</h2>
          <p className="text-gray-500 mt-4 leading-7">
            Marketplace assets can be rented, licensed or sold based on listing terms. UNIC.ai keeps platform control and marketplace fee rights.
          </p>
        </div>
      </div>
    </Shell>
  );
}
