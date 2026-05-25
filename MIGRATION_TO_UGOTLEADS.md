# Migrating FSN Forms: Formspree → UGotLeads → n8n

This site was built so the lead pipeline can be swapped without touching any HTML, Liquid, or page templates. The only file you ever edit is `_data/integrations.yml`.

## Today (Formspree)

```yaml
forms:
  default_endpoint: "https://formspree.io/f/maqkdazl"
  overrides:
    business_listing: ""
    contact: ""
    newsletter: ""
```

All three forms POST to the single default endpoint. Leads arrive in `myusalocal@gmail.com`. Attribution (UTM/fbclid/gclid/referrer/landing_url) is captured automatically by `assets/js/utm-capture.js` and sent as hidden form fields.

---

## Phase 2 — UGotLeads (when deployed)

Per-form override path (recommended), so each form drops into its own UGotLeads pipeline:

```yaml
forms:
  default_endpoint: "https://formspree.io/f/maqkdazl"  # keep as fallback
  overrides:
    business_listing: "https://crm.firstshopnashville.info/f/abc123"
    contact:          "https://crm.firstshopnashville.info/f/def456"
    newsletter:       "https://crm.firstshopnashville.info/f/ghi789"
```

**That's the entire migration.** No other files change.

**But there's a catch with iframe vs POST:** UGotLeads' `/f/[formId]` page is designed to be either visited directly OR embedded as an iframe. POSTing to it from a separate origin isn't its first-class supported path. Two options:

1. **Iframe embed (simplest):** swap the form pages to use the UGotLeads form via iframe with `?embed=1&theme=light&accent=%23C9A86A&title=0`. Lose some custom styling, gain full UGotLeads features (Speed-to-Lead automation, contact attribution, Meta Lead pixel fires automatically).
2. **Webhook POST:** add a public `/api/forms/[formId]/submit` route to UGotLeads that accepts a JSON or form-encoded body with the same field names FSN already sends, and creates the contact + fires automation. Keeps FSN's custom form styling. Recommended for production — drop the override URL into `default_endpoint` and you're done.

When you're ready, open a chapter: "wire FSN to UGotLeads" and pick option 1 or 2 above.

---

## Phase 3 — Self-hosted n8n (long-term)

n8n becomes the integration hub between FSN, UGotLeads, GHL, Stripe, and anything else.

```yaml
forms:
  default_endpoint: "https://n8n.starwriley.com/webhook/fsn-leads"
```

The n8n webhook receives all FSN form submits and fans them out:
- Creates contact in UGotLeads
- Drops a row in Google Sheets for backup
- Sends Slack/Discord notification
- Triggers downstream automation chains

Same one-line config change.

---

## What gets sent on every form submit

Every form sends these fields (the hidden ones are auto-filled by `assets/js/utm-capture.js`):

| Field | Source | Example |
|---|---|---|
| visible form fields | user input | name, email, business name, etc. |
| `form_name` | hidden, hardcoded per form | `"Business Listing Submission"` |
| `pipeline_tag` | hidden, hardcoded per form | `"firstshopnashville,business-listing"` |
| `_subject` | hidden, Formspree subject line | `"[FSN] Business Listing Submission — new lead"` |
| `utm_source` | sessionStorage (first-touch wins) | `"facebook"` |
| `utm_medium` | sessionStorage | `"cpc"` |
| `utm_campaign` | sessionStorage | `"summer-2026"` |
| `utm_content` | sessionStorage | `"ad-variant-3"` |
| `utm_term` | sessionStorage | `"used cars nashville"` |
| `fbclid` | sessionStorage | (Meta click ID) |
| `gclid` | sessionStorage | (Google click ID) |
| `referrer` | document.referrer | `"https://google.com/..."` |
| `landing_url` | first URL visited | `"https://firstshopnashville.info/dealerships/"` |
| `_next` | redirect after submit | `"https://firstshopnashville.info/thanks/?type=listing"` |
| `_gotcha` | honeypot, always empty for humans | `""` |

Whatever endpoint receives these — Formspree, UGotLeads, n8n — has everything it needs to attribute, route, and respond.

---

## Tracking pixels & live chat

Same `_data/integrations.yml` controls them. Set the IDs and they load site-wide. Leave empty and they no-op.

```yaml
tracking:
  meta_pixel_id: "1234567890123456"
  gtm_container_id: "GTM-ABCDE12"
chat:
  crisp_website_id: "abc123de-..."
```

For unified attribution across FSN and UGotLeads, use the **same Meta Pixel ID** in both `_data/integrations.yml` (here) and UGotLeads' env var. Same with GTM.
