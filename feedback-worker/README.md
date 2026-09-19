# Lime feedback inbox

The website's **Feedback** page can't write to GitHub directly — the site is public, so any token
inside it would be public too. This tiny Cloudflare Worker sits in between: the site POSTs to it, and
the Worker (which holds the token as a secret) appends the message to a **private** GitHub repo.

```
visitor → website form → this Worker → private repo  Denizprof/LimeAI-feedback
                                        └─ feedback/2026-09.md   (only you can open it)
```

## One-time setup (~5 minutes, free)

1. **Make a token that can only touch the feedback repo.**
   GitHub → Settings → Developer settings → Personal access tokens → *Fine-grained tokens* → Generate.
   - Repository access: **Only select repositories → `LimeAI-feedback`**
   - Permissions → Repository → **Contents: Read and write** (nothing else)
   - Do **not** reuse a token that can touch the public `LimeAI` repo.

2. **Deploy the Worker** (needs a free Cloudflare account):
   ```
   cd feedback-worker
   npx wrangler login
   npx wrangler deploy
   npx wrangler secret put GITHUB_TOKEN     # paste the token from step 1
   ```
   Wrangler prints the Worker's URL, e.g. `https://lime-feedback.<your-subdomain>.workers.dev`.

3. **Point the site at it.** In `index.html`, find `var FEEDBACK_ENDPOINT = '';` (inside
   `setupFeedback`) and set it to that URL. Commit and push. Until it's set, the form honestly says it
   isn't connected instead of pretending to send.

4. **Read feedback** at `github.com/Denizprof/LimeAI-feedback/feedback/YYYY-MM.md` (log in as yourself —
   the repo is private, so visitors can't see it).

## What it does / doesn't do

- Accepts POSTs **only** from `https://denizprof.github.io` (CORS + Origin check).
- Validates type (`idea|bug|praise|other`), message length (5–2000), contact length (≤120), body size (≤8 KB).
- Bot defences: hidden honeypot field, must have been typed into for ≥2.5 s, and 5 messages/hour per IP
  (best-effort, per Worker instance).
- Stores each message inside a Markdown code fence, so nothing a visitor types can render as
  HTML/markdown when you read it.
- **Does not store** IP addresses or user agents — only what the visitor typed (plus an optional contact).
- Retries if two submissions race on the same file (GitHub 409/422).

## Quick test after deploying

```
curl -X POST https://lime-feedback.<your-subdomain>.workers.dev \
  -H "Origin: https://denizprof.github.io" -H "Content-Type: application/json" \
  -d '{"type":"idea","message":"hello from curl","elapsedMs":5000}'
# → {"ok":true}   and a new entry appears in the private repo
```

If you change the site's domain (custom domain, etc.), update `ALLOWED_ORIGINS` in `worker.js`.
