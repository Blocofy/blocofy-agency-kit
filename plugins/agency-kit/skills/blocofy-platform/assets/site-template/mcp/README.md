# Blocofy connection files

One file per agent. Copy yours into the site folder under the name below. If
that file already exists, add the `blocofy` entry to it by hand. Full
reference: the kit README, "Connect a site", step 5.

| Your agent | Copy this file | To this path in the site folder |
|---|---|---|
| Claude Code, Copilot CLI | `claude-code--copilot.mcp.json` | `.mcp.json` |
| Codex CLI | `codex.config.toml` | `.codex/config.toml` |
| Gemini CLI | `gemini.settings.json` | `.gemini/settings.json` |
| Cursor | `cursor.mcp.json` | `.cursor/mcp.json` |
| OpenCode | `opencode.jsonc` | `opencode.jsonc` |
| OpenCode, older shape | `opencode.older.jsonc` | `opencode.jsonc` |
| Amp | `amp.settings.json` | `.amp/settings.json` |

- These files hold the **name** of the variable, `BLOCOFY_API_TOKEN`, never
  the key itself. Do not replace the name with a key.
- OpenCode: if it answers "Invalid input mcp.servers", use
  `opencode.older.jsonc` instead. OpenCode 1.14 needs that one.
