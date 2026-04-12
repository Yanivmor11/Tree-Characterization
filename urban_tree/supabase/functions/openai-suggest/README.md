# openai-suggest (Edge Function)

Proxies the characterization assistant to OpenAI so **web** clients avoid browser CORS and do not need `OPENAI_API_KEY` in the Flutter bundle.

## Deploy

```bash
cd urban_tree
supabase secrets set OPENAI_API_KEY=sk-...
supabase functions deploy openai-suggest --project-ref YOUR_PROJECT_REF
```

The Flutter app calls `Supabase.functions.invoke('openai-suggest', body: {'text': '...'})` on web. Mobile still uses direct OpenAI when `OPENAI_API_KEY` is supplied via `--dart-define` (consider moving all clients to this function to keep keys server-side only).

## Local

```bash
supabase start
supabase secrets set OPENAI_API_KEY=sk-... --env-file supabase/.env.local
supabase functions serve openai-suggest
```
