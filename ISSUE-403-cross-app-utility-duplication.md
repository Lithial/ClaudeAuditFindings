# ISSUE-403: Cross-app utility duplication + dead `agendaUtilities` exports

- **Severity:** S3 (maintainability — same fix must land in 3 places; dead code)
- **Status:** 🔴 confirmed (fallow `dupes` + `dead-code`, 2026-06-07)
- **Area:** circle-spaces / circle-homepages / my-circles / new-asb — shared utilities
- **Found:** 2026-06-07 (fallow `dupes` 9.9% / 38 clone groups; `unused_exports`)
- **Related:** [ISSUE-004](ISSUE-004-unstable-usestorage-getitem-effect-churn.md) (useStorage), [ISSUE-010](ISSUE-010-layout-duplication-spaces.md) (layout), [ISSUE-302](ISSUE-302-ccc-dist-deep-imports.md) (packaging)

## Symptom
The same utility modules are copy-pasted across the three Next apps rather than shared. After
ignoring config/fixture boilerplate, fallow still reports **38 real clone groups / 9.9% duplication**,
dominated by cross-app utility copies.

## Evidence
`fallow dupes` — prime extract-to-shared candidates (each ×3 across apps):

| Unit | Locations |
|------|-----------|
| `graphql.ts` | circle-homepages / circle-spaces / my-circles `src/utils/` |
| layout utils | homepages `circleLayout` + spaces `layout`/`layoutMobile` (see ISSUE-010) |
| `useStorage` | homepages / spaces / my-circles (see ISSUE-004) |
| `useClientMetricsData` | homepages / spaces / my-circles |
| `noteSort` | homepages / spaces / new-asb |
| `CirclesVideo{Disabled,Large,Small}` | circle-spaces VideoTile (intra-app) |

Plus **10 dead exports** in the duplicated `agendaUtilities.js` (fallow `unused_exports`):
- circle-spaces `…/AgendaUtilities/agendaUtilities.js`: `padTo2Digits`
- my-circles `…/AgendaTools/utils/agendaUtilities.js`: `toHoursAndMinutes`, `padTo2Digits`,
  `shortTotalTimeFormat`, `naturalCompare`, `naturalSort`, `getWelcomeAgenda`, `getPageSectionIdx`,
  `createAgendaSections`, `folderHasContent`

`agendaUtilities.js` is itself duplicated across the two apps **and** carries dead exports — both
symptoms at once.

## Mechanism
New apps were bootstrapped by copying utilities from an existing app; the copies have drifted. No
shared `@circles/utils` package exists, so there's no home for cross-app helpers.

## Blast radius
Every bug fix to graphql helpers / layout math / storage / metrics / note sorting must be applied in
2–3 places or the apps silently diverge. The dead `agendaUtilities` exports are safe to delete now.

## Proposed fix (do not implement yet)
1. Quick win: delete the 10 dead `agendaUtilities` exports (auto-fixable via `fallow fix --dry-run`
   then `--yes`; verify each isn't dynamically referenced first).
2. Larger: extract genuinely-shared helpers (`graphql.ts`, `noteSort`, `useStorage`,
   `useClientMetricsData`) into a shared package. Diff bodies first — copies have drifted, so
   catalogue intentional vs accidental divergence before merging.

## Effort / risk
Dead-export deletion: low. Extraction: medium — pair with the existing VRT infra and per-helper
tests, since several are used on hot paths. Full clone table in `docs/fallow-rollout-decisions.md`.
