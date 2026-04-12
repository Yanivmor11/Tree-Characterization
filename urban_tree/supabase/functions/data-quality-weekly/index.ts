import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

type Report = {
  id: string;
  latitude: number;
  longitude: number;
  health_score: number;
  phenological_stage: string | null;
  created_at: string;
  species: string | null;
};

function clusterKey(lat: number, lon: number): string {
  return `${lat.toFixed(5)}_${lon.toFixed(5)}`;
}

function stddev(values: number[]): number {
  if (values.length < 2) return 0;
  const mean = values.reduce((a, b) => a + b, 0) / values.length;
  const v =
    values.reduce((s, x) => s + (x - mean) * (x - mean), 0) / values.length;
  return Math.sqrt(v);
}

function daysApart(a: string, b: string): number {
  return Math.abs(
    (new Date(a).getTime() - new Date(b).getTime()) / (1000 * 60 * 60 * 24),
  );
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const url = Deno.env.get("SUPABASE_URL");
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const cronSecret = Deno.env.get("DATA_QUALITY_CRON_SECRET");
  if (!url || !serviceKey) {
    return new Response(
      JSON.stringify({
        error: "Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY",
      }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  const incoming = req.headers.get("x-data-quality-secret") ?? "";
  if (!cronSecret || incoming !== cronSecret) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), {
      status: 401,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  const supabase = createClient(url, serviceKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });

  const { data: rows, error } = await supabase
    .from("tree_reports")
    .select(
      "id, latitude, longitude, health_score, phenological_stage, created_at, species",
    )
    .order("created_at", { ascending: false })
    .limit(8000);

  if (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  const reports = (rows ?? []) as Report[];
  const byCluster = new Map<string, Report[]>();
  for (const r of reports) {
    const k = clusterKey(r.latitude, r.longitude);
    const list = byCluster.get(k) ?? [];
    list.push(r);
    byCluster.set(k, list);
  }

  let inserted = 0;
  for (const [key, list] of byCluster) {
    if (list.length < 2) continue;

    const healths = list.map((r) => r.health_score);
    const sd = stddev(healths);
    if (sd >= 1.25) {
      const { error: insErr } = await supabase.from("data_quality_flags").insert({
        cluster_key: key,
        reason: "health_score_variance",
        payload: {
          count: list.length,
          stddev: sd,
          report_ids: list.map((r) => r.id).slice(0, 20),
        },
      });
      if (!insErr) inserted += 1;
    }

    const withStage = list.filter((r) => r.phenological_stage);
    if (withStage.length >= 2) {
      const stages = new Set(withStage.map((r) => r.phenological_stage));
      if (stages.size > 1) {
        let conflict = false;
        for (let i = 0; i < withStage.length && !conflict; i++) {
          for (let j = i + 1; j < withStage.length; j++) {
            if (
              withStage[i].phenological_stage !==
                withStage[j].phenological_stage &&
              daysApart(withStage[i].created_at, withStage[j].created_at) <= 14
            ) {
              conflict = true;
              break;
            }
          }
        }
        if (conflict) {
          const { error: insErr2 } = await supabase
            .from("data_quality_flags")
            .insert({
              cluster_key: key,
              reason: "phenology_conflict_14d",
              payload: {
                stages: [...stages],
                report_ids: list.map((r) => r.id).slice(0, 20),
              },
            });
          if (!insErr2) inserted += 1;
        }
      }
    }
  }

  return new Response(
    JSON.stringify({
      ok: true,
      clusters_scanned: byCluster.size,
      flags_inserted: inserted,
    }),
    { headers: { ...corsHeaders, "Content-Type": "application/json" } },
  );
});
