import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { corsHeaders } from "../_shared/cors.ts";

type InsightContext = {
  species?: string | null;
  species_scientific?: string | null;
  health_score?: number | null;
  leaf_condition?: string | null;
  damage_extent?: string | null;
  phenological_stage?: string | null;
  month?: number | null;
};

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const apiKey = Deno.env.get("OPENAI_API_KEY");
  if (!apiKey) {
    return new Response(
      JSON.stringify({
        error:
          "Missing OPENAI_API_KEY secret in Supabase Edge Functions environment (set your OpenAI key, not a Supabase access token).",
      }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  let body: { context?: InsightContext };
  try {
    body = await req.json();
  } catch {
    return new Response(JSON.stringify({ error: "Invalid JSON body" }), {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  const ctx = body.context ?? {};
  const userPayload = JSON.stringify({
    species: ctx.species ?? null,
    species_scientific: ctx.species_scientific ?? null,
    health_score: ctx.health_score ?? null,
    leaf_condition: ctx.leaf_condition ?? null,
    damage_extent: ctx.damage_extent ?? null,
    phenological_stage: ctx.phenological_stage ?? null,
    month: ctx.month ?? null,
  });

  const openAiRes = await fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: "gpt-4o-mini",
      response_format: { type: "json_object" },
      messages: [
        {
          role: "system",
          content:
            "You assist urban tree citizen science. Given structured report fields as JSON, output ONLY valid JSON with key: tip (one short actionable sentence for the resident, any language matching the context if Hebrew hints present, else English). Focus on irrigation, pests, soil, or when to involve an arborist. No medical claims.",
        },
        {
          role: "user",
          content: `Context JSON:\n${userPayload}`,
        },
      ],
    }),
  });

  if (!openAiRes.ok) {
    const errText = await openAiRes.text();
    return new Response(
      JSON.stringify({
        error: `OpenAI error: ${openAiRes.status}`,
        detail: errText,
      }),
      {
        status: 502,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  const decoded = await openAiRes.json() as {
    choices?: Array<{ message?: { content?: string } }>;
  };
  const content = decoded.choices?.[0]?.message?.content;
  if (!content) {
    return new Response(JSON.stringify({ error: "Empty OpenAI content" }), {
      status: 502,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  let parsed: Record<string, unknown>;
  try {
    parsed = JSON.parse(content) as Record<string, unknown>;
  } catch {
    return new Response(JSON.stringify({ error: "OpenAI returned non-JSON" }), {
      status: 502,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  const tip = typeof parsed.tip === "string" ? parsed.tip : "";
  return new Response(JSON.stringify({ tip }), {
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
});
