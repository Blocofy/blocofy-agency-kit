# Blocofy site folder

This is the site folder of ONE Blocofy site. Do not use it for another site.

- Site address and keys: `.env.local`. Never print, commit or copy its values.
  If the `BLOCOFY_*` variables are not in your environment, ask the person to
  run `set -a; . ./.env.local; set +a` and start you again from that terminal.
- Blocofy tools: the MCP server named `blocofy`, the `blocofy` CLI, or the REST
  wrapper in the `blocofy-platform` skill. Load that skill before any write.
- Build state: `.blocofy-build/STATE.md`. Read it first if it exists; the
  `blocofy-orchestrator` skill explains how to start or continue. It is also
  the handover between people and between agents, so keep it current.
- Skills to use by name: `blocofy-orchestrator`, `blocofy-platform`,
  `blocofy-theme-kit`, `blocofy-media`, `blocofy-qa`, `site-build-method`.
  If any is missing, stop and point the person at the kit README.
- Drafts are free. Anything visitors can see needs the person's yes. Going
  live with a theme is their click in the Blocofy panel, never your command.
- Before the first write of a session, and whenever the person says they
  changed site or terminal, run the `blocofy-platform` skill's doctor script
  from this folder and read back the site name it reports.
- The skills run shell commands that need network access and the `BLOCOFY_*`
  variables. If a command is blocked by your sandbox, stop and ask the person.
  Never work around it.
- Optional: a line here that starts with `**Browser Support:**` overrides the
  kit's default browser support (format: the `blocofy-theme-kit` skill).
- Answer in the language the person writes in.
