# ISSUE-402: 27 declared production dependencies are unused or misplaced

- **Severity:** S3 (bundle bloat + dependency drift; some are install/audit surface)
- **Status:** 🟡 suspected (fallow `dead-code`, 2026-06-07 — verify each before removal)
- **Area:** all apps + packages / dependency hygiene
- **Found:** 2026-06-07 (fallow `unused_dependencies`)

## Symptom
27 packages are listed in a workspace's `dependencies` but never `import`ed from that workspace.
Two sub-cases:
1. **Truly unused** — not imported anywhere → removable.
2. **Misplaced** — unused *here* but used in another workspace (`used_in_workspaces` non-empty) →
   move/remove from this package, keep where it's actually used.

## Evidence
`fallow dead-code` → `unused_dependencies` (27, after `ignoreDependencies` already excludes the
build-only false-positives `sass-embedded`/`jsdom`/`tslib`).

**Likely truly-dead:** `aws-sdk`, `console-feed`, `react-split`, `styled-jsx`, `util`,
`uuid-browser`, `react-dates`, `react-with-direction`, `remove`, `negotiator`, `base-64`,
`global`, `nanoid`, `linkify-html`, `linkifyjs`, `use-sync-external-store`.

**Misplaced (used elsewhere):** `date-fns` (unused in `arc`, used in 6 other workspaces),
`reactjs-popup` (unused in circle-spaces, used in cui), `react-tiny-popover` (unused in ccc/new-asb,
used in spaces/cui), `lodash.isequal`, `linkify-react`.

## Mechanism
Copy-pasted `package.json` blocks across the workspaces, plus deps left behind after refactors.
`aws-sdk` in circle-spaces is the standout — a large SDK with no import.

## Blast radius
Mostly hygiene: install time, `node_modules` size, and audit/vuln surface (cf. the 127 dependabot
alerts on the repo). `aws-sdk` alone is a heavy unused install. Low correctness risk.

## Proposed fix (do not implement yet)
Per dep: `fallow dead-code --trace-dependency <pkg>` to confirm it's genuinely unused (catches
deps used only in package.json scripts / CI), then remove from the workspace. For misplaced deps,
remove from the workspace that doesn't use them; don't touch the one that does. **Verify before
removal** — fallow is syntactic and can miss fully-dynamic `import(variable)` usage.

## Effort / risk
Low-medium. Risk is per-dep: trace before deleting. Full annotated list in
`docs/fallow-rollout-decisions.md` (S2/S3).
