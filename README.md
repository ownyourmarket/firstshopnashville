# First Shop Nashville

> *Support Local. Shop First.* — Nashville's trusted directory of independent automotive businesses, local events, and the stories that make Music City worth supporting.

Static site, GitHub Pages, Jekyll. Tailwind via CDN, Alpine.js for interactivity, Higgsfield AI for imagery.

---

## Local development

GitHub Pages will build automatically on push. To preview locally:

```bash
bundle install
bundle exec jekyll serve
# → http://localhost:4000
```

If you don't have Ruby/Jekyll, the simplest preview is to open any compiled page in a browser after `jekyll build`, or use a static server on the rendered `_site/` directory.

---

## Project structure

```
firstshopnashville/
├─ _config.yml              site metadata, brand tokens
├─ _layouts/default.html    master layout (SEO, schema, fonts, Tailwind config)
├─ _includes/               reusable partials
│  ├─ nav.html              sticky transparent → solid nav with mobile drawer
│  ├─ footer.html           Support Local banner + sitemap + MyUSA Local link
│  ├─ hero.html             cinematic hero with overlay gradient + grain
│  ├─ business-card.html    LocalBusiness schema-marked listing card
│  ├─ category-tile.html    homepage / directory category card
│  ├─ event-card.html       Event schema-marked event card
│  └─ directory-listing.html grid of businesses filtered by category
├─ _data/                   structured content (editable without touching markup)
│  ├─ categories.yml
│  ├─ businesses.yml        seed listings — REPLACE WITH REAL DATA BEFORE LAUNCH
│  ├─ events.yml
│  └─ staples.yml           food / attractions / history timeline
├─ assets/
│  ├─ css/main.css          custom animations + brand utilities
│  ├─ js/main.js            reveal-on-scroll observer
│  └─ images/               Higgsfield-generated + placeholder imagery
├─ scripts/generate-images.sh   Higgsfield batch generator (idempotent)
├─ index.html               home
├─ dealerships/             used-car directory + FAQ + FAQPage schema
├─ auto-repair/             repair directory
├─ auto-detailing/          detailing directory + service tiers
├─ new-car-dealers/         new-car dealer directory
├─ things-to-do/            food + attractions guide
├─ events/                  community events calendar + ItemList schema
├─ history/                 Nashville timeline + editorial
├─ blog/                    blog hub (empty state ready, picks up _posts/)
├─ about/                   mission + stats
├─ submit-business/         free listing submission form
├─ contact/                 contact + topic-tagged form
├─ 404.html
├─ robots.txt
├─ CNAME                    firstshopnashville.info
└─ Gemfile
```

---

## Brand system

| Token   | Hex       | Use                          |
|---------|-----------|------------------------------|
| navy    | `#0B1B2B` | Primary surface, body text   |
| forest  | `#1F3D2A` | Secondary accent, eyebrows   |
| gold    | `#C9A86A` | CTAs, highlights             |
| tan     | `#E8D9B8` | Soft backgrounds, tags       |
| cream   | `#FAF7F0` | Default page background      |
| charcoal| `#1A1A1A` | Body text                    |

Typography: **Fraunces** (display, variable, optical-sized) + **Inter** (UI).

---

## SEO / AEO checklist

- ✅ Semantic HTML5 landmarks
- ✅ Per-page `<title>`, meta description, canonical, OG, Twitter
- ✅ `Organization` schema on every page
- ✅ `LocalBusiness` schema on every business card
- ✅ `FAQPage` schema on `/dealerships/`
- ✅ `Event` + `ItemList` schema on `/events/`
- ✅ `CollectionPage` schema on directory pages
- ✅ jekyll-sitemap auto-generates `/sitemap.xml`
- ✅ `robots.txt` allows all
- ✅ Mobile-first, accessible skip-link, focus-visible rings, prefers-reduced-motion respected

---

## Imagery — Higgsfield workflow

The site uses Higgsfield AI for all hero / category / business imagery. The CLI is already authenticated for this account.

**Generate (or re-generate missing) images:**

```bash
bash scripts/generate-images.sh
```

The script is idempotent — it skips any image already present on disk, so you can safely re-run it the next day if you hit the daily quota.

**Currently generated** (5 of 26):
- `assets/images/hero/home-hero.png`
- `assets/images/hero/dealerships-hero.png`
- `assets/images/hero/auto-repair-hero.png`
- `assets/images/hero/auto-detailing-hero.png`
- `assets/images/hero/new-car-dealers-hero.png`

**Pending** (re-run script after quota resets):
- 7 remaining hero images (things-to-do, events, history, about, blog, submit, contact)
- 4 category card images
- 3 lifestyle images
- 8 business photos

While pending, those slots fall back to `placehold.co` color blocks matching the brand palette so the site renders cleanly.

---

## Deployment (GitHub Pages)

1. Create the GitHub repo and push this directory.
2. **Settings → Pages** → Build from `main` branch, root.
3. Custom domain: `firstshopnashville.info` (the `CNAME` file is already in place).
4. At your registrar, add an A record for the apex (`@`) to GitHub's IPs:
   - `185.199.108.153`
   - `185.199.109.153`
   - `185.199.110.153`
   - `185.199.111.153`
5. Enable **Enforce HTTPS** once DNS propagates.

---

## Before launch

- [ ] Replace placeholder `(615) 555-XXXX` numbers in `_data/businesses.yml` with real listings
- [ ] Replace placeholder dealer addresses with real verified businesses
- [ ] Swap form action URLs in `submit-business/` and `contact/` for your Formspree/Netlify Forms endpoint
- [ ] Re-run `scripts/generate-images.sh` to fill in remaining Higgsfield imagery
- [ ] Add real social handles to `_config.yml` (`twitter_handle` etc.)
- [ ] Add Open Graph hero image at `/assets/images/hero/home-hero.png` (already there from first run)
- [ ] Write 2–3 launch blog posts in `_posts/` so `/blog/` doesn't ship in empty state
- [ ] Optional: add Google Analytics or Plausible tag in `_layouts/default.html`

---

## Powered by [My USA Local](https://myusalocal.com)
