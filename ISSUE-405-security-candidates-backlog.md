# ISSUE-405: 135 fallow `security` candidates to triage (UNVERIFIED)

- **Severity:** S3 (candidates for verification — not confirmed vulnerabilities)
- **Status:** 🔵 investigate (fallow `security`, 2026-06-07 — needs per-finding verification)
- **Area:** circle-spaces / circle-homepages / my-circles (+ a few packages)
- **Found:** 2026-06-07 (fallow `security` — runs on demand, never part of the default audit)

## Symptom
`fallow security` surfaces 135 local, deterministic **candidates** for tainted-data sinks. These are
*leads to verify*, NOT confirmed exploitable vulnerabilities — fallow does not prove reachability of
attacker-controlled input. Use alongside (not instead of) Snyk/CodeQL/Semgrep + dependabot for real
SAST/SCA.

## Evidence
`fallow security --format json --quiet`:

| Category | CWE | Count | Example |
|----------|-----|-------|---------|
| _uncategorized_ (null) | — | 79 | Low-signal generic non-literal sinks — triage last |
| `open-redirect` | 601 | 29 | `window.open()` non-literal target — `breakouts-panel/.../BreakoutsFooter.tsx:33` |
| `ssrf` | 918 | 13 | non-literal URL → `axios.post()` — `circle-spaces/.../useLogger.tsx:145` (telemetry — likely benign) |
| `path-traversal` | 22 | 10 | non-literal `path.resolve()` — `packages/testing/.../vitestBase.ts:12` (test infra — likely benign) |
| `nextjs-open-redirect` | 601 | 4 | Next redirect sink |

By workspace: circle-spaces 57 · circle-homepages 50 · my-circles 18 · isolated/vault 6 · packages 4.

Sampled findings (telemetry POST, test-infra path) look like **false positives**; the 79
null-category ones are the lowest-signal tier.

## Mechanism
Syntactic match of sink calls (`window.open`, `axios.post`, `path.resolve`, etc.) with non-literal
arguments against fallow's CWE catalogue. Conservative trigger, but no taint-flow proof — so a
configured/constant-derived argument still matches.

## Blast radius
Unknown until verified. The honest prior: most are false positives; a minority of entry-reachable,
high-blast-radius `open-redirect`/`ssrf` in app code could be real. Each finding carries
`reachability` (`reachable_from_entry`, `blast_radius`) to prioritize.

## Proposed fix (do not implement yet)
This is a **triage backlog, not a code change**. When doing a security pass:
1. `fallow security --format json` and sort by `reachability.blast_radius` desc, entry-reachable
   first.
2. Verify each `evidence` + `trace` — confirm the sink argument can be attacker-controlled.
3. Real ones → fix (allowlist host / reject `..` / validate redirect target). False positives →
   `// fallow-ignore-file security-sink` with a reason.
**Do not gate CI on this.**

## Effort / risk
Triage-only; no blast radius from recording it. Skip the 79 null-category entries on the first pass.
