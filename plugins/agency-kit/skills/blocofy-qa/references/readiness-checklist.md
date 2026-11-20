# Pre-publish checklist (human gate)

Run after the automated sweeps pass. The publish itself is a person's
approval: request it through the theme-work flow (`blocofy-platform`) and give
the user the approval link; never publish on your own.

## Automated inputs

- [ ] `site_readiness` (MCP) report reviewed; every `fail` resolved,
      every `warn` consciously accepted
- [ ] `site_status` health `ok` (no pages_split / empty live instance)
- [ ] Page sweep: all routes 200, 0 console errors, 0 unknown sections
- [ ] Responsive + reduced-motion sweeps green

## Content honesty

- [ ] Zero placeholder text/media anywhere (search for REPLACE_, lorem, TODO)
- [ ] All metrics/claims verifiable or removed; no invented awards/quotes
- [ ] Client names only where the engagement is confirmed
- [ ] All media self-hosted on the tenant CDN (no generation-service or
      third-party hotlinks)

## Hygiene

- [ ] Forms: correct form key, notify email set, consent link resolves,
      success redirect works
- [ ] Legal pages present and linked (privacy, cookies)
- [ ] Navigation validated (`validate_navigation`); no draft-page links
- [ ] Redirects created for any changed URLs (301 map)
- [ ] SEO: titles/descriptions per page, OG image set, single h1 per page
- [ ] Alias/legacy sections documented with a removal plan
- [ ] Analytics/integrations as the client requested — nothing extra
- [ ] Every CDN `<script>`/`<link rel="stylesheet">` is version-pinned with
      `integrity` + `crossorigin` (`scripts/legacy-scan-liquid.sh` reports
      missing ones when `modern-web-guidance` is available)

## After publish

- [ ] Smoke: fetch `/`, one inner page, one dynamic detail on the live domain
- [ ] Retro: generalizable lessons promoted from tenant NOTES.md to the kit repo (PR)
