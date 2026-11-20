#!/usr/bin/env node
/* Page sweep for Blocofy draft previews.
   Usage: node verify-page.mjs "<preview-link-1>" "<preview-link-2>" …
   (one per-page preview link per route; see platform SKILL §3)
   Reports per route: HTTP status, console errors, unknown-section count.
   Screenshots land in ./qa-shots/. */
import { createRequire } from "node:module";
import fs from "node:fs";

function loadPlaywright() {
  // resolve from the script dir first, then from the invoking workspace (cwd)
  for (const base of [import.meta.url, process.cwd() + "/package.json"]) {
    try { return createRequire(base)("playwright"); } catch { /* next */ }
  }
  throw new Error("Playwright not found — run `npm i playwright` in this workspace and re-run from there.");
}

const urls = process.argv.slice(2);
if (urls.length === 0) {
  console.error('Usage: verify-page.mjs "<preview-link>" ["<preview-link-2>" …]');
  process.exit(2);
}

const pw = loadPlaywright();
let browser;
try { browser = await pw.chromium.launch({ headless: true }); }
catch { browser = await pw.chromium.launch({ headless: true, channel: "chrome" }); }

const ctx = await browser.newContext({ viewport: { width: 1440, height: 900 } });
const page = await ctx.newPage();
const errors = [];
page.on("console", m => { if (m.type() === "error") errors.push(m.text().slice(0, 140)); });

fs.mkdirSync("qa-shots", { recursive: true });

let failed = 0;
for (const [i, url] of urls.entries()) {
  const route = new URL(url).pathname;
  const before = errors.length;
  // each link previews only its own page, so open every route through its own link
  const resp = await page.goto(url, { waitUntil: "networkidle", timeout: 60000 });
  await page.waitForTimeout(1500); // let entrance animations settle
  const unknown = await page.evaluate(() =>
    (document.body.innerText.match(/Bilinmeyen section|unknown section/gi) || []).length);
  const shot = "qa-shots/" + String(i + 1).padStart(2, "0") + "-" + (route === "/" ? "home" : route.replace(/\W+/g, "-").replace(/^-|-$/g, "")) + ".png";
  await page.screenshot({ path: shot });
  const errCount = errors.length - before;
  const ok = resp.status() === 200 && errCount === 0 && unknown === 0;
  if (!ok) failed++;
  console.log(`${ok ? "✓" : "✗"} ${route} · HTTP ${resp.status()} · consoleErrors ${errCount} · unknownSections ${unknown} · ${shot}`);
}
if (errors.length) console.log("first errors:", errors.slice(0, 3));
await browser.close();
process.exit(failed ? 1 : 0);
