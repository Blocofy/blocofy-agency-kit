# Contract: STATE.md (contractVersion 1)

Single writer: the orchestrator. Human-readable markdown so anyone can open it
and see where the build stands.

```markdown
# Build State — <workspace dir name>
contractVersion: 1
updated: YYYY-MM-DD HH:MM

## Target
- Draft theme instance: <handle or "not created">
- Theme dir: <path>
- themeOrigin: skeleton | existing:<handle>   ← provenance gate decision

## Phases
| # | Phase | Status | Artifact | Gate note |
|---|---|---|---|---|
| 0 | Bootstrap | done|active|pending | STATE.md | doctor OK @date |
| 1 | Brief | … | brief.md | … |
| 2 | Design DNA | … | design-dna.json | … |
| 3 | Content model | … | content-model.json | … |
| 4 | Theme build | … | draft <handle> | … |
| 5 | Content & media | … | pages/entries/media | … |
| 6 | QA | … | NOTES.md#qa | … |
| 7 | Publish | … | live | HUMAN APPROVAL: … |

## Open items
- …

## Session cache pointers (gitignored files, informational)
- preview token: .blocofy-build/session/preview.json (check exp!)
```

Rules: statuses only move forward via gate checks; "done" requires the gate
note to name its evidence (date + what was verified). Reopening a phase
demotes every later phase to pending.
