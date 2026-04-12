# Data inventory — Google Play Data safety & Apple App Privacy

Use this table to answer store questionnaires. Wording is factual for the current UrbanTree codebase; adjust if you add auth, analytics, or change backends.

| Category | Examples in app | Collected? | Linked to user? | Purpose | Shared with third parties? |
|----------|-----------------|------------|-----------------|---------|----------------------------|
| **Location** | Latitude, longitude, GPS accuracy (meters) for each report | Yes (precise) | [No account yet → “not linked” unless you add IDs] | Map placement, land-use context | Supabase (host); not sold |
| **Photos** | User-selected / camera images for whole tree, flowers, leaves | Yes | [Same as above] | Citizen-science documentation | Supabase Storage |
| **Health / fitness** | **Not human health.** Tree condition score (1–5), stress indicators, damage extent | Yes (environmental) | [As above] | Research / ecology | Supabase |
| **User content** | Free-text notes sent to AI assistant (optional) | If used | [As above] | Suggestions for structured fields | [OpenAI when assistant used; on web via Supabase Edge Function] |
| **App activity** | [Add if you integrate analytics] | | | | |

## Google Play — typical declarations

- **Location**: Collected, optional [or required for core feature — your choice], used for app functionality.  
- **Photos / videos**: Collected, optional, used for app functionality.  
- **Health**: If the form conflates “health” with human data, use free text to clarify **tree ecological assessment** under “Other” or applicable environmental category per current Play taxonomy.  
- **Data encryption in transit**: Yes (HTTPS to Supabase / OpenAI).  
- **Account deletion**: [Describe once you support accounts.]

## Apple — Privacy Nutrition Labels

- Data types: Location (precise), Photos, **Other** (tree metrics — describe as environmental research data).  
- Usage: App functionality, analytics [if any].  
- Tracking: [Yes/No per Apple definition — default likely No if no ad ID.]

## Notes

- **Supabase anon key** in the client is normal; protect data with **RLS** and storage policies.  
- **OpenAI**: Prefer server-side key via Edge Function (`openai-suggest`) for all platforms to minimize key exposure.
