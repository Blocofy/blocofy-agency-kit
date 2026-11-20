#!/usr/bin/env node
/* Recon of a reference site the client pointed at (Phase 1, reference route).
   Usage (from .blocofy-build/ in the site folder):
     node <skill-dir>/scripts/reference-recon.mjs "<url>" ["<url-2>" …]
   Reads only what a visitor's browser receives. Saves nothing from the site
   except full-page screenshots and a facts file:
     ./reference/<n>-<host>-1440.png, -390.png, ./reference/recon.json
   Facts per page: title, nav links, section sequence (tag, height in
   viewports, background), fonts and sizes in use, colours in use, container
   width, tech signals (generator, framework and theme markers). */
import { createRequire } from "node:module";
import fs from "node:fs";

function loadPlaywright() {
  for (const base of [import.meta.url, process.cwd() + "/package.json"]) {
    try { return createRequire(base)("playwright"); } catch { /* next */ }
  }
  throw new Error("Playwright not found — run `npm i playwright` in the site folder and re-run from there.");
}

const urls = process.argv.slice(2);
if (urls.length === 0) {
  console.error('Usage: reference-recon.mjs "<url>" ["<url-2>" …]');
  process.exit(2);
}

const pw = loadPlaywright();
let browser;
try { browser = await pw.chromium.launch({ headless: true }); }
catch { browser = await pw.chromium.launch({ headless: true, channel: "chrome" }); }

fs.mkdirSync("reference", { recursive: true });
const out = [];

// Runs in the page. Counts what is actually rendered, not what the CSS declares.
function collect() {
  const vh = window.innerHeight;
  const top = (map, n) => [...map.entries()].sort((a, b) => b[1] - a[1]).slice(0, n).map(([k, v]) => ({ value: k, count: v }));
  const fonts = new Map(), colors = new Map(), bgs = new Map();
  const visible = [...document.querySelectorAll("body *")].filter((el) => {
    const r = el.getBoundingClientRect();
    return r.width > 0 && r.height > 0;
  }).slice(0, 4000);
  for (const el of visible) {
    const cs = getComputedStyle(el);
    const hasText = [...el.childNodes].some((n) => n.nodeType === 3 && n.textContent.trim());
    if (hasText) {
      fonts.set(cs.fontFamily.split(",")[0].trim().replace(/["']/g, ""), (fonts.get(cs.fontFamily.split(",")[0].trim().replace(/["']/g, "")) || 0) + 1);
      colors.set(cs.color, (colors.get(cs.color) || 0) + 1);
    }
    if (cs.backgroundColor !== "rgba(0, 0, 0, 0)") bgs.set(cs.backgroundColor, (bgs.get(cs.backgroundColor) || 0) + 1);
  }
  const size = (sel) => { const el = document.querySelector(sel); return el ? getComputedStyle(el).fontSize : null; };
  const main = document.querySelector("main") || document.body;
  const blocks = [...main.querySelectorAll(":scope > section, :scope > div, :scope > article, :scope > header, :scope > footer")];
  const sections = (blocks.length >= 3 ? blocks : [...document.querySelectorAll("section")]).map((el) => {
    const r = el.getBoundingClientRect();
    const h = el.querySelector("h1, h2, h3");
    return {
      tag: el.tagName.toLowerCase(),
      viewports: +(r.height / vh).toFixed(2),
      background: getComputedStyle(el).backgroundColor,
      has: { heading: !!h, images: el.querySelectorAll("img, picture, svg").length, video: el.querySelectorAll("video").length, form: el.querySelectorAll("form").length },
      heading_words: h ? h.textContent.trim().split(/\s+/).length : 0,
    };
  }).filter((s) => s.viewports > 0.05);
  const widest = [...document.querySelectorAll("main *, body > *")].map((el) => parseFloat(getComputedStyle(el).maxWidth)).filter((n) => n > 600 && n < 2000);
  const html = document.documentElement.outerHTML;
  const signals = {
    generator: document.querySelector('meta[name="generator"]')?.content || null,
    markers: ["wp-content", "/_next/", "data-reactroot", "__NUXT__", "cdn.shopify.com", "webflow", "elementor", "wix.com", "squarespace", "framerusercontent", "gsap", "lenis", "swiper", "themeforest", "envato"].filter((m) => html.toLowerCase().includes(m)),
    stylesheets: [...document.querySelectorAll('link[rel="stylesheet"]')].map((l) => l.href).slice(0, 12),
  };
  return {
    title: document.title,
    lang: document.documentElement.lang || null,
    nav: [...document.querySelectorAll("nav a, header a")].map((a) => ({ text: a.textContent.trim().slice(0, 40), href: a.getAttribute("href") })).filter((a) => a.text).slice(0, 40),
    sections,
    fonts: top(fonts, 5),
    sizes: { h1: size("h1"), h2: size("h2"), body: getComputedStyle(document.body).fontSize },
    text_colors: top(colors, 6),
    background_colors: top(bgs, 6),
    container_max_width: widest.length ? Math.round(widest.sort((a, b) => a - b)[Math.floor(widest.length / 2)]) : null,
    signals,
  };
}

let n = 0;
for (const url of urls) {
  n += 1;
  const host = new URL(url).hostname.replace(/[^a-z0-9.-]/gi, "_");
  const entry = { url, widths: {} };
  for (const [width, height] of [[1440, 900], [390, 844]]) {
    const ctx = await browser.newContext({ viewport: { width, height } });
    const page = await ctx.newPage();
    try {
      const resp = await page.goto(url, { waitUntil: "networkidle", timeout: 45000 }).catch(() => page.goto(url, { waitUntil: "load", timeout: 45000 }));
      entry.status = resp ? resp.status() : null;
      // scroll once so lazy content renders, then return to the top
      await page.evaluate(async () => {
        for (let y = 0; y < document.body.scrollHeight; y += 600) { window.scrollTo(0, y); await new Promise((r) => setTimeout(r, 80)); }
        window.scrollTo(0, 0);
      });
      await page.waitForTimeout(400);
      await page.screenshot({ path: `reference/${n}-${host}-${width}.png`, fullPage: true });
      entry.widths[width] = await page.evaluate(collect);
    } catch (e) {
      entry.widths[width] = { error: String(e.message || e).slice(0, 200) };
    }
    await ctx.close();
  }
  out.push(entry);
  const d = entry.widths[1440] || {};
  console.log(`${entry.status ?? "ERR"} ${url} · sections ${d.sections?.length ?? "-"} · fonts ${(d.fonts || []).map((f) => f.value).join(", ") || "-"} · signals ${(d.signals?.markers || []).join(", ") || "-"}`);
}

fs.writeFileSync("reference/recon.json", JSON.stringify(out, null, 2));
await browser.close();
console.log(`Wrote reference/recon.json and ${out.length * 2} screenshots to ./reference/`);
