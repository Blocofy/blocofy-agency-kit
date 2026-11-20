#!/usr/bin/env node
/* Page sweep for Blocofy drafts.
   Usage: node verify-page.mjs [--expect "<text>"] "<url-1>" "<url-2>" …
   URLs: one per-page preview link per static route, or `blocofy theme dev`
   local URLs (http://127.0.0.1:<port>/…) for dynamic template routes
   (platform SKILL §3).
   --expect "<text>": a string that exists only in the draft. An expired or
   revoked preview link silently serves the live site; a URL whose HTML lacks
   the text fails, so the sweep cannot go green on the wrong content.
   Reports per URL: HTTP status, console errors, uncaught exceptions, failed
   requests, unknown-section count. Full-page screenshots land in ./qa-shots/.
   Exit code: 0 all passed, 1 at least one URL failed, 2 usage error. */
import { createRequire } from "node:module";
import fs from "node:fs";

function loadPlaywright() {
  // resolve from the script dir first, then from the invoking workspace (cwd)
  for (const base of [import.meta.url, process.cwd() + "/package.json"]) {
    try { return createRequire(base)("playwright"); } catch { /* next */ }
  }
  throw new Error("Playwright not found. Run `npm i playwright` in this workspace and re-run from there.");
}

const USAGE = 'Usage: verify-page.mjs [--expect "<text>"] "<url>" ["<url-2>" …]';
const urls = [];
let expect = null;
const args = process.argv.slice(2);
for (let i = 0; i < args.length; i++) {
  if (args[i] === "--expect") { expect = args[++i]; if (!expect) { console.error(USAGE); process.exit(2); } }
  else if (args[i].startsWith("--expect=")) expect = args[i].slice("--expect=".length);
  else urls.push(args[i]);
}
if (urls.length === 0 || expect === "") {
  console.error(USAGE);
  process.exit(2);
}

const pw = loadPlaywright();
let browser;
try { browser = await pw.chromium.launch({ headless: true }); }
catch { browser = await pw.chromium.launch({ headless: true, channel: "chrome" }); }

const ctx = await browser.newContext({ viewport: { width: 1440, height: 900 } });
const page = await ctx.newPage();
const errors = [];     // console.error + uncaught exceptions
const badRequests = []; // failed page resources (fail the URL)
let softFailed = 0;     // failed fetch/xhr/media etc. (reported only)
const HARD = new Set(["document", "script", "stylesheet", "font", "image"]);
page.on("console", (m) => { if (m.type() === "error") errors.push("console: " + m.text().slice(0, 140)); });
page.on("pageerror", (e) => errors.push("exception: " + String(e && e.message || e).slice(0, 140)));
page.on("requestfailed", (r) => {
  const why = r.failure() ? r.failure().errorText : "failed";
  if (why.includes("ERR_ABORTED")) return; // cancelled by navigation or by the page itself
  if (HARD.has(r.resourceType())) badRequests.push(`${r.resourceType()} ${r.url().slice(0, 100)} (${why})`);
  else softFailed++;
});

fs.mkdirSync("qa-shots", { recursive: true });

let failed = 0;
for (const [i, url] of urls.entries()) {
  let route = url;
  const errBefore = errors.length, reqBefore = badRequests.length, softBefore = softFailed;
  let status = null, unknown = 0, expectOk = expect === null, shot = "-", crash = null;
  try {
    route = new URL(url).pathname;
    // each preview link shows only its own page, so every route is opened through its own URL
    let resp;
    try {
      resp = await page.goto(url, { waitUntil: "networkidle", timeout: 45000 });
    } catch {
      // a page that never goes network-idle (video, polling) still has to load
      resp = await page.goto(url, { waitUntil: "load", timeout: 45000 });
    }
    status = resp ? resp.status() : null;
    await page.waitForTimeout(1500); // let entrance animations settle
    unknown = await page.evaluate(() =>
      (document.body.innerText.match(/Bilinmeyen section|unknown section/gi) || []).length);
    if (expect !== null) expectOk = (await page.content()).includes(expect);
    shot = "qa-shots/" + String(i + 1).padStart(2, "0") + "-" + (route === "/" ? "home" : route.replace(/\W+/g, "-").replace(/^-|-$/g, "")) + ".png";
    await page.screenshot({ path: shot, fullPage: true });
  } catch (e) {
    crash = String(e && e.message || e).split("\n")[0].slice(0, 160);
  }
  const errCount = errors.length - errBefore;
  const reqCount = badRequests.length - reqBefore;
  const ok = !crash && status === 200 && errCount === 0 && reqCount === 0 && unknown === 0 && expectOk;
  if (!ok) failed++;
  console.log(`${ok ? "✓" : "✗"} ${route} · HTTP ${status ?? "none"} · errors ${errCount} · failedRequests ${reqCount}` +
    ` (+${softFailed - softBefore} fetch/media) · unknownSections ${unknown}` +
    (expect !== null ? ` · expect ${expectOk ? "found" : "MISSING"}` : "") +
    ` · ${shot}` + (crash ? ` · ERROR ${crash}` : ""));
}
if (errors.length) console.log("first errors:", errors.slice(0, 3));
if (badRequests.length) console.log("first failed requests:", badRequests.slice(0, 3));
if (expect === null) console.log("note: no --expect given; a stale preview link would pass on live content.");
await browser.close();
console.log(failed ? `${failed} of ${urls.length} URL(s) failed` : `all ${urls.length} URL(s) passed`);
process.exit(failed ? 1 : 0);
