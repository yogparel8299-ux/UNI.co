import OpenAI from "openai";

export type CommandPlan = {
  company?: {
    name: string;
    slug: string;
  };
  agents?: {
    name: string;
    description: string;
    system_prompt: string;
    model?: string;
  }[];
  workflows?: {
    name: string;
    graph: any;
  }[];
  tasks?: {
    title: string;
    input: string;
    agent_name?: string;
  }[];
  response: string;
};

function slugify(input: string) {
  return input
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/(^-|-$)/g, "")
    .slice(0, 50);
}

export async function createCommandPlan(command: string): Promise<CommandPlan> {
  const apiKey = process.env.OPENAI_API_KEY;

  if (!apiKey) {
    const name = command.slice(0, 48) || "New AI Company";

    return {
      company: {
        name,
        slug: slugify(name) || "new-ai-company"
      },
      agents: [
        {
          name: "CEO Agent",
          description: "Defines company strategy, goals, operating model and execution roadmap.",
          system_prompt: "You are a CEO agent. Build strategy, priorities, plans and operating decisions.",
          model: "gpt-4o-mini"
        },
        {
          name: "Research Agent",
          description: "Researches markets, customers, competitors and useful data.",
          system_prompt: "You are a research agent. Produce structured research with assumptions and next actions.",
          model: "gpt-4o-mini"
        },
        {
          name: "Execution Agent",
          description: "Executes tasks and creates business outputs.",
          system_prompt: "You are an execution agent. Complete the task with practical, ready-to-use output.",
          model: "gpt-4o-mini"
        }
      ],
      workflows: [
        {
          name: "Company Build Workflow",
          graph: {
            nodes: [
              { id: "ceo", type: "agent", label: "CEO Agent" },
              { id: "research", type: "agent", label: "Research Agent" },
              { id: "execution", type: "agent", label: "Execution Agent" }
            ],
            edges: [
              { from: "ceo", to: "research" },
              { from: "research", to: "execution" }
            ]
          }
        }
      ],
      tasks: [
        {
          title: "Create company operating plan",
          input: command,
          agent_name: "CEO Agent"
        },
        {
          title: "Create first execution output",
          input: command,
          agent_name: "Execution Agent"
        }
      ],
      response: "Created a fallback AI company plan because OPENAI_API_KEY is not configured."
    };
  }

  const openai = new OpenAI({ apiKey });

  const completion = await openai.chat.completions.create({
    model: "gpt-4o-mini",
    temperature: 0.2,
    messages: [
      {
        role: "system",
        content: `
You are the UNIC.ai command planner.

Convert the user command into JSON only.

Return this exact shape:
{
  "company": { "name": "...", "slug": "..." },
  "agents": [
    {
      "name": "...",
      "description": "...",
      "system_prompt": "...",
      "model": "gpt-4o-mini"
    }
  ],
  "workflows": [
    {
      "name": "...",
      "graph": {
        "nodes": [],
        "edges": []
      }
    }
  ],
  "tasks": [
    {
      "title": "...",
      "input": "...",
      "agent_name": "..."
    }
  ],
  "response": "short explanation"
}

Rules:
- If the user asks to build a company, create company, agents, workflow and tasks.
- If the user asks to create an agent, include agents.
- If the user asks to create a workflow, include workflows.
- If the user asks to run work, include tasks.
- Always make useful agents.
- Slug must be lowercase and URL safe.
- Return JSON only. No markdown.
`
      },
      {
        role: "user",
        content: command
      }
    ]
  });

  const raw = completion.choices[0]?.message?.content || "{}";

  try {
    return JSON.parse(raw);
  } catch {
    return {
      response: "Planner returned invalid JSON.",
      tasks: [
        {
          title: "Manual command review",
          input: command
        }
      ]
    };
  }
}
