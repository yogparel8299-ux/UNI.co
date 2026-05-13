#!/bin/bash
set -e

echo "Adding Auth + Onboarding + API Key Vault + Model Router..."

mkdir -p app/{auth,onboarding,vault,router,connectors}
mkdir -p app/api/{onboarding,save-secret,model-test,router-run,connector-connect}
mkdir -p lib/auth lib/models components/auth components/vault

cat > lib/supabase-browser.ts <<'TS'
import { createBrowserClient } from "@supabase/ssr";

export function supabaseBrowser() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL || "",
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || ""
  );
}
TS

cat > lib/crypto.ts <<'TS'
import crypto from "crypto";

const key = crypto
  .createHash("sha256")
  .update(process.env.UNIC_SECRET_ENCRYPTION_KEY || "dev-secret-change-this")
  .digest();

export function encryptSecret(value: string) {
  const iv = crypto.randomBytes(16);
  const cipher = crypto.createCipheriv("aes-256-gcm", key, iv);
  const encrypted = Buffer.concat([
    cipher.update(value, "utf8"),
    cipher.final()
  ]);
  const tag = cipher.getAuthTag();

  return [
    iv.toString("hex"),
    tag.toString("hex"),
    encrypted.toString("hex")
  ].join(":");
}

export function decryptSecret(payload: string) {
  const [ivHex, tagHex, encryptedHex] = payload.split(":");

  const decipher = crypto.createDecipheriv(
    "aes-256-gcm",
    key,
    Buffer.from(ivHex, "hex")
  );

  decipher.setAuthTag(Buffer.from(tagHex, "hex"));

  const decrypted = Buffer.concat([
    decipher.update(Buffer.from(encryptedHex, "hex")),
    decipher.final()
  ]);

  return decrypted.toString("utf8");
}
TS

cat > lib/models/model-router.ts <<'TS'
import OpenAI from "openai";
import Anthropic from "@anthropic-ai/sdk";
import { supabaseAdmin } from "@/lib/supabase-admin";
import { decryptSecret } from "@/lib/crypto";

async function getSecret(companyId: string, provider: string) {
  const { data } = await supabaseAdmin
    .from("encrypted_secrets")
    .select("*")
    .eq("company_id", companyId)
    .eq("provider", provider)
    .eq("status", "active")
    .order("created_at", { ascending: false })
    .limit(1)
    .single();

  if (!data?.encrypted_value) return null;

  return decryptSecret(data.encrypted_value);
}

export async function runModelRouter({
  companyId,
  prompt,
  systemPrompt,
  provider,
  model
}: {
  companyId: string;
  prompt: string;
  systemPrompt?: string;
  provider?: string;
  model?: string;
}) {
  let selectedProvider = provider;
  let selectedModel = model;

  if (!selectedProvider || !selectedModel) {
    const { data: rule } = await supabaseAdmin
      .from("model_router_rules")
      .select("*")
      .eq("company_id", companyId)
      .eq("status", "active")
      .order("created_at", { ascending: false })
      .limit(1)
      .single();

    selectedProvider = rule?.primary_provider || "openai";
    selectedModel = rule?.primary_model || "gpt-4o-mini";
  }

  if (selectedProvider === "openai") {
    const apiKey = await getSecret(companyId, "openai") || process.env.OPENAI_API_KEY;

    if (!apiKey) throw new Error("OpenAI key missing.");

    const client = new OpenAI({ apiKey });

    const result = await client.chat.completions.create({
      model: selectedModel || "gpt-4o-mini",
      messages: [
        {
          role: "system",
          content: systemPrompt || "You are a useful UNIC.ai execution agent."
        },
        {
          role: "user",
          content: prompt
        }
      ]
    });

    return {
      provider: "openai",
      model: selectedModel,
      text: result.choices?.[0]?.message?.content || ""
    };
  }

  if (selectedProvider === "anthropic") {
    const apiKey = await getSecret(companyId, "anthropic");

    if (!apiKey) throw new Error("Anthropic Claude key missing.");

    const client = new Anthropic({ apiKey });

    const result = await client.messages.create({
      model: selectedModel || "claude-3-5-sonnet-latest",
      max_tokens: 2000,
      system: systemPrompt || "You are a useful UNIC.ai execution agent.",
      messages: [
        {
          role: "user",
          content: prompt
        }
      ]
    });

    const text = result.content
      .map((part: any) => part.type === "text" ? part.text : "")
      .join("");

    return {
      provider: "anthropic",
      model: selectedModel,
      text
    };
  }

  if (selectedProvider === "openrouter") {
    const apiKey = await getSecret(companyId, "openrouter");

    if (!apiKey) throw new Error("OpenRouter key missing.");

    const client = new OpenAI({
      apiKey,
      baseURL: "https://openrouter.ai/api/v1"
    });

    const result = await client.chat.completions.create({
      model: selectedModel || "openai/gpt-4o-mini",
      messages: [
        {
          role: "system",
          content: systemPrompt || "You are a useful UNIC.ai execution agent."
        },
        {
          role: "user",
          content: prompt
        }
      ]
    });

    return {
      provider: "openrouter",
      model: selectedModel,
      text: result.choices?.[0]?.message?.content || ""
    };
  }

  throw new Error(`Unsupported provider: ${selectedProvider}`);
}
TS

node - <<'NODE'
const fs = require("fs");
const pkg = JSON.parse(fs.readFileSync("package.json", "utf8"));
pkg.dependencies = pkg.dependencies || {};
pkg.dependencies["@anthropic-ai/sdk"] = "latest";
fs.writeFileSync("package.json", JSON.stringify(pkg, null, 2));
NODE

cat > components/auth/AuthForm.tsx <<'TSX'
"use client";

import { useState } from "react";
import { supabaseBrowser } from "@/lib/supabase-browser";

export default function AuthForm() {
  const [mode, setMode] = useState<"login" | "signup">("signup");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  async function submit() {
    const supabase = supabaseBrowser();

    if (mode === "signup") {
      const { error } = await supabase.auth.signUp({
        email,
        password
      });

      if (error) return alert(error.message);

      alert("Signup created. Check email if confirmation is enabled.");
      window.location.href = "/onboarding";
    } else {
      const { error } = await supabase.auth.signInWithPassword({
        email,
        password
      });

      if (error) return alert(error.message);

      window.location.href = "/dashboard";
    }
  }

  return (
    <div className="glass-card p-10 w-full max-w-md">
      <h1 className="text-4xl font-black tracking-[-0.04em]">
        {mode === "signup" ? "Create account" : "Login"}
      </h1>

      <input
        className="input-box mt-8"
        placeholder="Email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
      />

      <input
        className="input-box mt-4"
        placeholder="Password"
        type="password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
      />

      <button onClick={submit} className="primary-button mt-6 w-full">
        {mode === "signup" ? "Signup" : "Login"}
      </button>

      <button
        className="mt-5 text-gray-500"
        onClick={() => setMode(mode === "signup" ? "login" : "signup")}
      >
        {mode === "signup" ? "Already have account? Login" : "Need account? Signup"}
      </button>
    </div>
  );
}
TSX

cat > app/auth/page.tsx <<'TSX'
import AuthForm from "@/components/auth/AuthForm";

export default function AuthPage() {
  return (
    <main className="min-h-screen flex items-center justify-center bg-white p-10">
      <AuthForm />
    </main>
  );
}
TSX

cat > app/login/page.tsx <<'TSX'
import AuthForm from "@/components/auth/AuthForm";

export default function LoginPage() {
  return (
    <main className="min-h-screen flex items-center justify-center bg-white p-10">
      <AuthForm />
    </main>
  );
}
TSX

cat > app/signup/page.tsx <<'TSX'
import AuthForm from "@/components/auth/AuthForm";

export default function SignupPage() {
  return (
    <main className="min-h-screen flex items-center justify-center bg-white p-10">
      <AuthForm />
    </main>
  );
}
TSX

cat > app/onboarding/page.tsx <<'TSX'
"use client";

import { useState } from "react";
import { supabaseBrowser } from "@/lib/supabase-browser";

export default function OnboardingPage() {
  const [companyName, setCompanyName] = useState("");
  const [loading, setLoading] = useState(false);

  async function createCompany() {
    setLoading(true);

    const supabase = supabaseBrowser();
    const { data: userData } = await supabase.auth.getUser();

    if (!userData.user) {
      alert("Please login first.");
      window.location.href = "/auth";
      return;
    }

    const res = await fetch("/api/onboarding", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        company_name: companyName,
        user_id: userData.user.id,
        email: userData.user.email
      })
    });

    const data = await res.json();

    setLoading(false);

    if (!data.ok) {
      alert(data.error);
      return;
    }

    window.location.href = "/command";
  }

  return (
    <main className="min-h-screen bg-white flex items-center justify-center p-10">
      <div className="glass-card p-10 max-w-xl w-full">
        <p className="text-green-600 font-bold">UNIC.ai onboarding</p>

        <h1 className="text-5xl font-black tracking-[-0.05em] mt-4">
          Create your company workspace.
        </h1>

        <p className="text-gray-500 mt-5 leading-7">
          Everything created in this workspace is registered under company ownership rules.
        </p>

        <input
          className="input-box mt-8"
          placeholder="Company name"
          value={companyName}
          onChange={(e) => setCompanyName(e.target.value)}
        />

        <button
          onClick={createCompany}
          disabled={loading}
          className="primary-button mt-6 w-full"
        >
          {loading ? "Creating..." : "Create Workspace"}
        </button>
      </div>
    </main>
  );
}
TSX

cat > app/api/onboarding/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

function slugify(input: string) {
  return input.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/(^-|-$)/g, "");
}

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    if (!body.company_name || !body.user_id) {
      return NextResponse.json({ ok: false, error: "company_name and user_id required." }, { status: 400 });
    }

    const slug = `${slugify(body.company_name)}-${Date.now().toString().slice(-5)}`;

    const { data: company, error: companyError } = await supabaseAdmin
      .from("companies")
      .insert({
        name: body.company_name,
        slug,
        owner_id: body.user_id,
        plan: "free"
      })
      .select()
      .single();

    if (companyError) throw companyError;

    await supabaseAdmin.from("company_members").insert({
      company_id: company.id,
      user_id: body.user_id,
      role: "owner"
    });

    await supabaseAdmin.from("profiles").upsert({
      id: body.user_id,
      email: body.email,
      default_company_id: company.id
    });

    await supabaseAdmin.from("billing_accounts").insert({
      company_id: company.id,
      plan: "free",
      monthly_limit: 100,
      current_usage: 0
    });

    await supabaseAdmin.from("company_credit_wallets").insert({
      company_id: company.id,
      balance: 100,
      lifetime_purchased: 100
    });

    await supabaseAdmin.from("model_router_rules").insert({
      company_id: company.id,
      rule_name: "Default Model Router",
      primary_provider: "openai",
      primary_model: "gpt-4o-mini",
      fallback_provider: "openrouter",
      fallback_model: "openai/gpt-4o-mini",
      max_cost_per_run: 0.05,
      status: "active"
    });

    await supabaseAdmin.from("activity_logs").insert({
      company_id: company.id,
      actor_id: body.user_id,
      action: "company_onboarded",
      entity_type: "company",
      entity_id: company.id,
      metadata: { source: "onboarding" }
    });

    return NextResponse.json({ ok: true, company });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
TS

cat > app/vault/page.tsx <<'TSX'
"use client";

import { useState } from "react";

export default function VaultPage() {
  const [companyId, setCompanyId] = useState("");
  const [provider, setProvider] = useState("openai");
  const [secret, setSecret] = useState("");
  const [result, setResult] = useState("");

  async function saveSecret() {
    const res = await fetch("/api/save-secret", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        company_id: companyId,
        provider,
        secret_name: `${provider}_api_key`,
        secret_value: secret
      })
    });

    const data = await res.json();
    setResult(JSON.stringify(data, null, 2));
  }

  return (
    <main className="page-shell">
      <section className="main">
        <h1 className="page-title">API Key Vault</h1>
        <p className="page-subtitle">
          Store user-owned OpenAI, Claude and OpenRouter keys securely for routing.
        </p>

        <div className="glass-card p-8 mt-10 max-w-2xl">
          <input className="input-box" placeholder="Company ID" value={companyId} onChange={(e) => setCompanyId(e.target.value)} />

          <select className="input-box mt-4" value={provider} onChange={(e) => setProvider(e.target.value)}>
            <option value="openai">OpenAI / ChatGPT</option>
            <option value="anthropic">Anthropic / Claude</option>
            <option value="openrouter">OpenRouter</option>
          </select>

          <input className="input-box mt-4" placeholder="API Key" value={secret} onChange={(e) => setSecret(e.target.value)} />

          <button className="primary-button mt-6" onClick={saveSecret}>
            Save Key
          </button>

          {result && <pre className="mt-6 bg-gray-950 text-green-300 p-5 rounded-2xl overflow-auto text-xs">{result}</pre>}
        </div>
      </section>
    </main>
  );
}
TSX

cat > app/api/save-secret/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";
import { encryptSecret } from "@/lib/crypto";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    if (!body.company_id || !body.provider || !body.secret_value) {
      return NextResponse.json({ ok: false, error: "company_id, provider and secret_value required." }, { status: 400 });
    }

    const encrypted = encryptSecret(body.secret_value);

    const { data, error } = await supabaseAdmin
      .from("encrypted_secrets")
      .insert({
        company_id: body.company_id,
        provider: body.provider,
        secret_name: body.secret_name || `${body.provider}_key`,
        encrypted_value: encrypted,
        secret_type: "api_key",
        status: "active"
      })
      .select()
      .single();

    if (error) throw error;

    return NextResponse.json({
      ok: true,
      secret_id: data.id,
      provider: data.provider
    });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
TS

cat > app/router/page.tsx <<'TSX'
"use client";

import { useState } from "react";

export default function RouterPage() {
  const [companyId, setCompanyId] = useState("");
  const [provider, setProvider] = useState("openai");
  const [model, setModel] = useState("gpt-4o-mini");
  const [prompt, setPrompt] = useState("");
  const [result, setResult] = useState("");

  async function run() {
    const res = await fetch("/api/router-run", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        company_id: companyId,
        provider,
        model,
        prompt
      })
    });

    const data = await res.json();
    setResult(JSON.stringify(data, null, 2));
  }

  return (
    <main className="page-shell">
      <section className="main">
        <h1 className="page-title">Model Router</h1>
        <p className="page-subtitle">
          Route tasks between OpenAI, Claude and OpenRouter using user-owned keys.
        </p>

        <div className="glass-card p-8 mt-10 max-w-3xl">
          <input className="input-box" placeholder="Company ID" value={companyId} onChange={(e) => setCompanyId(e.target.value)} />

          <select className="input-box mt-4" value={provider} onChange={(e) => setProvider(e.target.value)}>
            <option value="openai">OpenAI</option>
            <option value="anthropic">Claude</option>
            <option value="openrouter">OpenRouter</option>
          </select>

          <input className="input-box mt-4" placeholder="Model" value={model} onChange={(e) => setModel(e.target.value)} />

          <textarea className="input-box mt-4 min-h-[160px]" placeholder="Prompt" value={prompt} onChange={(e) => setPrompt(e.target.value)} />

          <button className="primary-button mt-6" onClick={run}>
            Run Model
          </button>

          {result && <pre className="mt-6 bg-gray-950 text-green-300 p-5 rounded-2xl overflow-auto text-xs">{result}</pre>}
        </div>
      </section>
    </main>
  );
}
TSX

cat > app/api/router-run/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import { runModelRouter } from "@/lib/models/model-router";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    if (!body.company_id || !body.prompt) {
      return NextResponse.json({ ok: false, error: "company_id and prompt required." }, { status: 400 });
    }

    const result = await runModelRouter({
      companyId: body.company_id,
      provider: body.provider,
      model: body.model,
      prompt: body.prompt,
      systemPrompt: body.system_prompt
    });

    return NextResponse.json({
      ok: true,
      result
    });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
TS

cat > app/connectors/page.tsx <<'TSX'
"use client";

import { useState } from "react";

export default function ConnectorsPage() {
  const [companyId, setCompanyId] = useState("");
  const [provider, setProvider] = useState("slack");
  const [connectionId, setConnectionId] = useState("");
  const [result, setResult] = useState("");

  async function saveConnection() {
    const res = await fetch("/api/connector-connect", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        company_id: companyId,
        provider,
        connection_id: connectionId,
        auth_provider: "composio"
      })
    });

    const data = await res.json();
    setResult(JSON.stringify(data, null, 2));
  }

  return (
    <main className="page-shell">
      <section className="main">
        <h1 className="page-title">Connectors</h1>
        <p className="page-subtitle">
          Store Composio/OAuth connection IDs so agents can use connected tools.
        </p>

        <div className="grid grid-cols-3 gap-6 mt-10">
          {["slack", "gmail", "notion", "github", "google_drive", "zapier", "hubspot", "calendar", "stripe"].map((p) => (
            <button key={p} onClick={() => setProvider(p)} className="glass-card p-6 text-left">
              <h2 className="text-2xl font-black capitalize">{p.replace("_", " ")}</h2>
              <p className="text-gray-500 mt-3">Connect via Composio/OAuth.</p>
            </button>
          ))}
        </div>

        <div className="glass-card p-8 mt-10 max-w-2xl">
          <input className="input-box" placeholder="Company ID" value={companyId} onChange={(e) => setCompanyId(e.target.value)} />
          <input className="input-box mt-4" placeholder="Provider" value={provider} onChange={(e) => setProvider(e.target.value)} />
          <input className="input-box mt-4" placeholder="Composio connection ID" value={connectionId} onChange={(e) => setConnectionId(e.target.value)} />

          <button className="primary-button mt-6" onClick={saveConnection}>
            Save Connector
          </button>

          {result && <pre className="mt-6 bg-gray-950 text-green-300 p-5 rounded-2xl overflow-auto text-xs">{result}</pre>}
        </div>
      </section>
    </main>
  );
}
TSX

cat > app/api/connector-connect/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    if (!body.company_id || !body.provider) {
      return NextResponse.json({ ok: false, error: "company_id and provider required." }, { status: 400 });
    }

    const { data, error } = await supabaseAdmin
      .from("connector_accounts")
      .insert({
        company_id: body.company_id,
        provider: body.provider,
        connection_id: body.connection_id,
        auth_provider: body.auth_provider || "composio",
        status: "connected",
        scopes: body.scopes || [],
        metadata: body.metadata || {},
        connected_at: new Date().toISOString()
      })
      .select()
      .single();

    if (error) throw error;

    return NextResponse.json({
      ok: true,
      connector: data
    });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
TS

python3 - <<'PY'
from pathlib import Path

p = Path("components/Nav.tsx")
s = p.read_text()

items = [
  '["Auth", "/auth"],',
  '["Onboarding", "/onboarding"],',
  '["Vault", "/vault"],',
  '["Router", "/router"],',
  '["Connectors", "/connectors"],'
]

for item in items:
    if item not in s:
        s = s.replace('["Settings", "/settings"]', item + '\n  ["Settings", "/settings"]')

p.write_text(s)
PY

python3 - <<'PY'
from pathlib import Path

worker = Path("workers/runtime-worker.js")
s = worker.read_text()

if "runModelRouter" not in s:
    s = s.replace(
        'const OpenAI = require("openai");',
        'const OpenAI = require("openai");\n// Model router exists in app runtime. Worker keeps OpenAI fallback for now.'
    )

worker.write_text(s)
PY

npm install

git add .
git commit -m "Add auth onboarding API key vault and model router" || true

echo "DONE: Auth + Onboarding + Vault + Router added."
