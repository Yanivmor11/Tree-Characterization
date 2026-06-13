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
  locale?: string;
};

function normalizeLocale(locale?: string): string {
  const code = (locale ?? "en").trim().toLowerCase();
  const supported = new Set(["he", "en", "ar", "ru"]);
  return supported.has(code) ? code : "en";
}

function languageName(code: string): string {
  switch (code) {
    case "he":
      return "Hebrew";
    case "ar":
      return "Arabic";
    case "ru":
      return "Russian";
    default:
      return "English";
  }
}

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

function buildSystemPrompt(options: {
  step?: string;
  locale?: string;
  hasImage?: boolean;
}): string {
  const languageCode = normalizeLocale(options.locale);
  const langName = languageName(languageCode);

  let prompt =
    "You assist urban tree citizen science. The user interface language is " +
    `"${languageCode}" (${langName}). ` +
    "Output ONLY valid JSON with keys: " +
    "species_common_en (canonical English common name or null), " +
    "species_scientific_latin (canonical Latin binomial or null), " +
    `translated_display_name (species common name in ${langName} for the UI — required when identifiable), ` +
    "species_common (same value as species_common_en for backward compatibility), " +
    "species_scientific (same value as species_scientific_latin for backward compatibility), " +
    `source_language (BCP-47 code "${languageCode}"), ` +
    "species_confidence (number 0-1 or null), " +
    "health_score (integer 1-5 — provide your best estimate when the tree is visible; typical healthy urban trees are 3-5), " +
    'hazard_assessment (exactly one of: "low", "medium", "high" — structural/public safety risk from visible defects), ' +
    'canopy_density (exactly one of: "sparse", "moderate", "dense"), ' +
    'structural_issues (array with any of: "dead_branches","leaning","cracks","exposed_roots","cavity","other", or empty array if none visible), ' +
    'stress_symptoms (array with any of: "chlorosis","necrosis","wilting","leaf_spot","defoliation","gummosis","pest_damage","none","other", or null), ' +
    'phenological_stage (exactly one of: "bud", "open", "fruit", or null), ' +
    'flower_abundance (exactly one of: "low", "medium", "high", or null — estimate from visible flower/fruit density), ' +
    'leaf_condition (exactly one of: "healthy", "stressed", or null), ' +
    'damage_extent (exactly one of: "minimal", "low", "moderate", "high", or null — foliar damage area), ' +
    `notes (10-20 words in ${langName} describing the tree: species cues, crown, leaf condition, and visible health — required when the image or text is usable). ` +
    `Write translated_display_name and notes ONLY in ${langName}. ` +
    "Keep species_common_en and species_scientific_latin in English/Latin. " +
    "Fill every field you can infer; use null only when truly uncertain or not visible. " +
    "Normalize typos in canonical fields. " +
    'If user mentions flowers or blooming, set phenological_stage to "open". ' +
    'If buds only, use "bud". If fruit visible, use "fruit". ' +
    "Phenological stage only if clearly visible in the image or text.";

  if (options.hasImage) {
    prompt +=
      " Analyze the tree photo carefully: identify species from leaves, bark, crown, and fruit if visible; " +
      "assess overall health (1=very poor, 5=excellent), hazard_assessment, canopy_density, and visible structural_issues; " +
      "note stress symptoms; infer phenological stage when clear. " +
      "Always fill species, notes, health_score, hazard_assessment, and canopy_density when the tree is visible.";
  }

  if (options.step === "flower_fruit") {
    prompt +=
      " The reporter is on the flower/fruit step — prioritize phenological_stage, flower_abundance, and notes.";
  }

  if (options.step === "leaves") {
    prompt +=
      " The reporter is on the leaves step — prioritize leaf_condition, stress_symptoms, and damage_extent; " +
      'set leaf_condition to "stressed" when any stress symptom is visible.';
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
  const locale = (body.locale ?? "").trim() || undefined;

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

  const system = buildSystemPrompt({
    step,
    locale,
    hasImage: imageB64.length > 0,
  });

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
      image_url: { url, detail: "high" },
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

  const hazard = typeof parsed.hazard_assessment === "string"
    ? parsed.hazard_assessment.trim().toLowerCase()
    : "";
  parsed.hazard_assessment = ["low", "medium", "high"].includes(hazard)
    ? hazard
    : null;

  const canopy = typeof parsed.canopy_density === "string"
    ? parsed.canopy_density.trim().toLowerCase()
    : "";
  parsed.canopy_density = ["sparse", "moderate", "dense"].includes(canopy)
    ? canopy
    : null;

  if (Array.isArray(parsed.structural_issues)) {
    const allowed = new Set([
      "dead_branches",
      "leaning",
      "cracks",
      "exposed_roots",
      "cavity",
      "other",
    ]);
    parsed.structural_issues = parsed.structural_issues
      .map((e) => String(e).trim().toLowerCase().replace(/\s+/g, "_"))
      .filter((e) => allowed.has(e));
    if ((parsed.structural_issues as string[]).length === 0) {
      parsed.structural_issues = null;
    }
  } else {
    parsed.structural_issues = null;
  }

  return new Response(JSON.stringify(parsed), {
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
});
