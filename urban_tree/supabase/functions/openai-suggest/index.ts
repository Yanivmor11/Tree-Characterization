import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const corsHeaders: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

type ChatBody = {
  text?: string;
  image_base64?: string;
  mime_type?: string;
};

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const apiKey = Deno.env.get("OPENAI_API_KEY");
  if (!apiKey) {
    return new Response(
      JSON.stringify({ error: "Server misconfiguration: OPENAI_API_KEY" }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  let body: ChatBody;
  try {
    body = await req.json();
  } catch {
    return new Response(JSON.stringify({ error: "Invalid JSON body" }), {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  const text = (body.text ?? "").trim();
  const imageB64 = (body.image_base64 ?? "").trim();
  const mime = (body.mime_type ?? "image/jpeg").trim() || "image/jpeg";

  if (!text && !imageB64) {
    return new Response(
      JSON.stringify({
        species_common: null,
        species_scientific: null,
        species_confidence: null,
        health_score: null,
        phenological_stage: null,
        notes: null,
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }

  const system =
    'You assist urban tree citizen science. Output ONLY valid JSON with keys: ' +
    'species_common (short common name or null), species_scientific (Latin binomial or null), ' +
    'species_confidence (number 0-1 or null), health_score (integer 1-5 or null), ' +
    'phenological_stage (string "bud", "open", "fruit", or null), ' +
    "notes (short reasoning, Hebrew ok, or null). " +
    "Use null when uncertain. Phenological stage only if clearly visible in the image or text.";

  const userContent: Array<
    | { type: "text"; text: string }
    | { type: "image_url"; image_url: { url: string; detail?: string } }
  > = [];

  if (text.length > 0) {
    userContent.push({ type: "text", text });
  }
  if (imageB64.length > 0) {
    const url = `data:${mime};base64,${imageB64}`;
    userContent.push({
      type: "image_url",
      image_url: { url, detail: "low" },
    });
  }

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
        { role: "system", content: system },
        { role: "user", content: userContent },
      ],
    }),
  });

  if (!openAiRes.ok) {
    const errText = await openAiRes.text();
    return new Response(
      JSON.stringify({ error: `OpenAI error: ${openAiRes.status}`, detail: errText }),
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
    return new Response(JSON.stringify({ error: "OpenAI returned non-JSON content" }), {
      status: 502,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  return new Response(JSON.stringify(parsed), {
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
});
