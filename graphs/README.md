# Committed graphify graphs

Point-in-time snapshots of the four [graphify](../README.md) knowledge graphs that back this audit, committed so the structural context the findings reference travels with the repo (without needing the monorepo + a rebuild).

| Dir | Source in monorepo |
|-----|--------------------|
| `circle-spaces/` | `graphify-out/` (repo root) |
| `circle-homepages/` | `apps/circle-homepages/graphify-out/` |
| `my-circles/` | `apps/my-circles/graphify-out/` |
| `packages/` | `packages/graphify-out/` |

Each dir contains:
- **`graph.json`** — the queryable AST graph (what `graphify query` reads)
- **`wiki/`** — generated navigation pages (browse the structure)
- **`GRAPH_REPORT.md`** — human-readable summary
- **`manifest.json`** — present for `circle-spaces` only

**Deliberately excluded** to keep the repo light: `graph.html` (~3.5MB each visualization) and `cache/` (regeneration scratch). Regenerate either in the monorepo if you need them.

## Caveats
- These are **generated artifacts** (gitignored in the monorepo) and are **point-in-time** — they drift from the code as it changes. Treat them as a snapshot tied to the audit, not a live index.
- To refresh: run `bash audit-findings/rebuild-graphs.sh` in the monorepo, then re-copy the outputs here (data + wiki + report, minus `graph.html`/`cache`).
- To query a snapshot directly, run `graphify query` from the matching monorepo graph dir (the live `graphify-out/`), not from here — these copies are for reading/sharing.
