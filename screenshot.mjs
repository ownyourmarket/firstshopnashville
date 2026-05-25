// First Shop Nashville — design-review screenshot loop.
// Run: node screenshot.mjs
// Hits localhost:4000 (Eleventy dev server), screenshots each page at desktop + mobile,
// writes to ./temporary screenshots/screenshot-N-PAGE-WIDTH.png
import puppeteer from "puppeteer";
import fs from "node:fs";
import path from "node:path";

const HOST = process.env.HOST || "http://localhost:4000";
const PAGES = [
  ["home",          "/"],
  ["dealerships",   "/dealerships/"],
  ["auto-repair",   "/auto-repair/"],
  ["auto-detailing","/auto-detailing/"],
  ["new-car-dealers","/new-car-dealers/"],
  ["things-to-do",  "/things-to-do/"],
  ["events",        "/events/"],
  ["history",       "/history/"],
  ["about",         "/about/"],
  ["blog",          "/blog/"],
  ["submit",        "/submit-business/"],
  ["contact",       "/contact/"],
  ["thanks",        "/thanks/?type=listing"],
  ["404",           "/404.html"],
];

const VIEWPORTS = [
  { label: "desktop", width: 1440, height: 900,  deviceScaleFactor: 1 },
  { label: "mobile",  width: 390,  height: 844,  deviceScaleFactor: 2 },
];

const OUT_DIR = path.resolve("./temporary screenshots");
fs.mkdirSync(OUT_DIR, { recursive: true });

// Find next free counter so we don't overwrite previous comparison rounds.
let counter = 1;
const existing = fs.readdirSync(OUT_DIR)
  .map((f) => +(f.match(/^screenshot-(\d+)/)?.[1] || 0));
if (existing.length) counter = Math.max(...existing) + 1;

const label = process.argv[2] ? `-${process.argv[2]}` : "";

const browser = await puppeteer.launch({
  headless: "new",
  args: ["--no-sandbox","--disable-setuid-sandbox"],
});

try {
  for (const [name, urlPath] of PAGES) {
    for (const vp of VIEWPORTS) {
      const page = await browser.newPage();
      await page.setViewport(vp);
      // Force-disable reveal-on-scroll so off-viewport elements render in fullPage shots
      await page.emulateMediaFeatures([{ name: "prefers-reduced-motion", value: "reduce" }]);
      const url = HOST + urlPath;
      try {
        await page.goto(url, { waitUntil: "networkidle2", timeout: 30000 });
        // Give fonts a beat to settle
        await new Promise((r) => setTimeout(r, 800));
        const file = `screenshot-${counter}-${name}-${vp.label}${label}.png`;
        await page.screenshot({
          path: path.join(OUT_DIR, file),
          fullPage: true,
        });
        console.log("  ✓", file);
      } catch (err) {
        console.error("  ✗", urlPath, vp.label, "—", err.message);
      } finally {
        await page.close();
      }
    }
  }
} finally {
  await browser.close();
}

console.log(`\nDone. ${PAGES.length} pages × ${VIEWPORTS.length} viewports → ./temporary screenshots/`);
