-- Schedule Edge Function `data-quality-weekly` (weekly, Sunday 02:00 UTC).
-- Run in Supabase SQL Editor after:
--   1) Extensions: enable pg_cron and pg_net (Dashboard → Database → Extensions) if not already on.
--   2) Vault secrets (Dashboard → Project Settings → Vault, or SQL vault.create_secret):
--        name: data_quality_function_url
--        value: https://<PROJECT_REF>.supabase.co/functions/v1/data-quality-weekly
--        name: data_quality_cron_secret
--        value: same string as Edge secret DATA_QUALITY_CRON_SECRET
--
-- Auth for the function is header x-data-quality-secret (not Bearer service_role).

select cron.unschedule(jobid)
from cron.job
where jobname = 'urban_tree_data_quality_weekly';

select cron.schedule(
  'urban_tree_data_quality_weekly',
  '0 2 * * 0',
  $cron$
  select net.http_post(
    url := (select decrypted_secret from vault.decrypted_secrets where name = 'data_quality_function_url' limit 1),
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'x-data-quality-secret', (select decrypted_secret from vault.decrypted_secrets where name = 'data_quality_cron_secret' limit 1)
    ),
    body := '{}'::jsonb
  );
  $cron$
);
