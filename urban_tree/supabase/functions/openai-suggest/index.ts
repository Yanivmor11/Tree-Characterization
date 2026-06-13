/**
 * OpenAI vision/text proxy for species and health characterization.
 *
 * Web clients MUST use this Edge Function (no client-side OPENAI_API_KEY).
 * Normalizes multilingual input to species_common_en + species_scientific_latin.
 *
 * Env: OPENAI_API_KEY (Supabase secrets). verify_jwt = false in config.toml.
 */
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { corsHeaders } from "../_shared/cors.ts";

type ChatBody = {
  text?: string;
  image_base64?: string;
  mime_type?: string;
  step?: string;
};

function normalizePhenologicalStage(raw: unknown): string | null {
  if (raw == null) return null;
  const normalized = String(raw).trim().toLowerCase().replace(/\s+/g, "_");
  const synonyms: Record<string, string> = {
    bud: "bud",
    buds: "bud",
    budding: "bud",
    open: "open",
    flower: "open",
    flowers: "open",
    flowering: "open",
    bloom: "open",
    blooming: "open",
    fruit: "fruit",
    fruits: "fruit",
  };
  return synonyms[normalized] ?? null;
}

function buildSystemPrompt(step?: string): string {
  let prompt =
    'You assist urban tree citizen science. Output ONLY valid JSON with keys: ' +
    'species_common_en (canonical English common name or null), ' +
    'species_scientific_latin (canonical Latin binomial or null), ' +
    'translated_display_name (localized display name for UI, matching user language, or null), ' +
    'species_common (same value as species_common_en for backward compatibility), ' +
    'species_scientific (same value as species_scientific_latin for backward compatibility), ' +
    'source_language (BCP-47 code like "he", "ar", "ru", "en", or null), ' +
    'species_confidence (number 0-1 or null), health_score (integer 1-5 or null), ' +
    'stress_symptoms (array with any of: "chlorosis","necrosis","wilting","leaf_spot","defoliation","gummosis","pest_damage","none","other", or null), ' +
    'phenological_stage (exactly one of: "bud", "open", "fruit", or null), ' +
    "notes (short reasoning in user's language when possible, or null). " +
    "Use null when uncertain. Normalize typos in canonical fields. " +
    'If user mentions flowers or blooming, set phenological_stage to "open". ' +
    'If buds only, use "bud". If fruit visible, use "fruit". ' +
    "Phenological stage only if clearly visible in the image or text.";
  if (step === "flower_fruit") {
    prompt +=
      " The reporter is on the flower/fruit step — prioritize phenological_stage and notes.";
  }
  return prompt;
}

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
  const step = (body.step ?? "").trim() || undefined;

  if (!text && !imageB64) {
    return new Response(
      JSON.stringify({
        species_common_en: null,
        species_scientific_latin: null,
        translated_display_name: null,
        species_common: null,
        species_scientific: null,
        source_language: null,
        species_confidence: null,
        health_score: null,
        stress_symptoms: null,
        phenological_stage: null,
        notes: null,
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }

  const system = buildSystemPrompt(step);

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

  const commonEn = typeof parsed.species_common_en === "string"
    ? parsed.species_common_en
    : typeof parsed.species_common === "string"
    ? parsed.species_common
    : null;
  const scientificLatin = typeof parsed.species_scientific_latin === "string"
    ? parsed.species_scientific_latin
    : typeof parsed.species_scientific === "string"
    ? parsed.species_scientific
    : null;

  parsed.species_common_en = commonEn;
  parsed.species_common = commonEn;
  parsed.species_scientific_latin = scientificLatin;
  parsed.species_scientific = scientificLatin;
  parsed.phenological_stage = normalizePhenologicalStage(parsed.phenological_stage);

  if (!Array.isArray(parsed.stress_symptoms)) {
    parsed.stress_symptoms = null;
  }

  return new Response(JSON.stringify(parsed), {
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
});
