"use client";

import { useState } from "react";

export default function SkillAssignmentPanel({
  companyId,
  agentId,
  publicSkills,
  companySkills,
  assignedSkills
}: {
  companyId: string;
  agentId: string;
  publicSkills: any[];
  companySkills: any[];
  assignedSkills: any[];
}) {
  const [result, setResult] = useState("");

  async function assignPublicSkill(skillId: string) {
    const res = await fetch("/api/assign-skill", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        company_id: companyId,
        agent_id: agentId,
        skill_library_id: skillId
      })
    });

    const data = await res.json();
    setResult(JSON.stringify(data, null, 2));
  }

  async function assignCompanySkill(skillId: string) {
    const res = await fetch("/api/assign-skill", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        company_id: companyId,
        agent_id: agentId,
        company_skill_id: skillId
      })
    });

    const data = await res.json();
    setResult(JSON.stringify(data, null, 2));
  }

  async function removeSkill(assignmentId: string) {
    const res = await fetch("/api/remove-agent-skill", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        assignment_id: assignmentId
      })
    });

    const data = await res.json();
    setResult(JSON.stringify(data, null, 2));
  }

  async function runSkill(assignmentId: string) {
    const prompt = window.prompt("What should this skill do?");

    if (!prompt) return;

    const res = await fetch("/api/run-skill", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        company_id: companyId,
        agent_id: agentId,
        skill_assignment_id: assignmentId,
        input: {
          prompt
        }
      })
    });

    const data = await res.json();
    setResult(JSON.stringify(data, null, 2));
  }

  return (
    <div className="space-y-8">
      <div className="glass-card p-8">
        <h2 className="text-3xl font-black tracking-[-0.04em]">
          Assigned Skills
        </h2>

        <div className="grid grid-cols-3 gap-5 mt-6">
          {(assignedSkills || []).map((assignment) => {
            const skill = assignment.company_skills || assignment.skill_library;

            return (
              <div key={assignment.id} className="rounded-3xl border border-black/10 p-5 bg-white">
                <p className="text-green-600 font-bold text-xs uppercase">
                  {skill?.category || "skill"}
                </p>

                <h3 className="text-xl font-black mt-2">
                  {skill?.title || "Unnamed Skill"}
                </h3>

                <p className="text-gray-500 mt-3 text-sm leading-6">
                  {skill?.description || "No description."}
                </p>

                <div className="flex gap-2 mt-5">
                  <button className="primary-button" onClick={() => runSkill(assignment.id)}>
                    Run
                  </button>

                  <button className="secondary-button" onClick={() => removeSkill(assignment.id)}>
                    Disable
                  </button>
                </div>
              </div>
            );
          })}

          {(!assignedSkills || assignedSkills.length === 0) && (
            <p className="text-gray-500 col-span-3">
              No skills assigned yet.
            </p>
          )}
        </div>
      </div>

      <div className="glass-card p-8">
        <h2 className="text-3xl font-black tracking-[-0.04em]">
          Public Skill Library
        </h2>

        <div className="grid grid-cols-4 gap-5 mt-6">
          {(publicSkills || []).map((skill) => (
            <div key={skill.id} className="rounded-3xl border border-black/10 p-5 bg-white">
              <p className="text-green-600 font-bold text-xs uppercase">
                {skill.category}
              </p>

              <h3 className="text-xl font-black mt-2">
                {skill.title}
              </h3>

              <p className="text-gray-500 mt-3 text-sm leading-6">
                {skill.description}
              </p>

              <button className="primary-button mt-5" onClick={() => assignPublicSkill(skill.id)}>
                Add to Agent
              </button>
            </div>
          ))}
        </div>
      </div>

      <div className="glass-card p-8">
        <h2 className="text-3xl font-black tracking-[-0.04em]">
          Company Skills
        </h2>

        <div className="grid grid-cols-4 gap-5 mt-6">
          {(companySkills || []).map((skill) => (
            <div key={skill.id} className="rounded-3xl border border-black/10 p-5 bg-white">
              <p className="text-green-600 font-bold text-xs uppercase">
                {skill.category}
              </p>

              <h3 className="text-xl font-black mt-2">
                {skill.title}
              </h3>

              <p className="text-gray-500 mt-3 text-sm leading-6">
                {skill.description}
              </p>

              <button className="primary-button mt-5" onClick={() => assignCompanySkill(skill.id)}>
                Add to Agent
              </button>
            </div>
          ))}

          {(!companySkills || companySkills.length === 0) && (
            <p className="text-gray-500 col-span-4">
              No company custom skills yet.
            </p>
          )}
        </div>
      </div>

      {result && (
        <pre className="bg-gray-950 text-green-300 p-5 rounded-2xl overflow-auto text-xs">
          {result}
        </pre>
      )}
    </div>
  );
}
