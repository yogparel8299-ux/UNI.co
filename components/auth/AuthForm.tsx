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
