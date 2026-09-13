# Lime — website

The marketing/landing site for Lime, a local-first voice assistant.

## Publish it on GitHub Pages

1. Create a new repo on GitHub (e.g. `lime-website`), don't initialize it with a README.
2. Unzip this folder, open a terminal inside it, and run:
   ```
   git init
   git add -A
   git commit -m "Initial commit: Lime website"
   git remote add origin https://github.com/<your-username>/<repo-name>.git
   git branch -M main
   git push -u origin main
   ```
3. On GitHub: **Settings → Pages → Source → Deploy from a branch → `main` / `(root)`** → Save.
4. Your site will be live at `https://<your-username>.github.io/<repo-name>/` within a minute or two.

## Files

- `index.html` — the entire site (single file: HTML, CSS, and JS together)
- `assets/dashboard-screenshot.png` — the real screenshot used on the Interface page

## Notes

- No build step, no dependencies to install — it's static HTML/CSS/JS plus one external font stylesheet and the Three.js CDN script (both already referenced in `index.html`).
- The Download page's button is intentionally a placeholder — there's no packaged installer yet. Swap its `href` for a real release URL once one exists.
- Copyright / attribution lives in the page footer.
