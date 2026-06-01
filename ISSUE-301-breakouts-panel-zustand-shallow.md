# ISSUE-301: breakouts-panel repeats the Zustand `shallow` footgun (shared lib)

- **Severity:** S2
- **Status:** 🔴 confirmed (coordinator-verified, 2026-06-01)
- **Area:** `packages/breakouts-panel` / state (shared library consumed by circle-spaces)
- **Found:** 2026-06-01 (packages graph → store god-nodes → source verification)

## Symptom
`breakouts-panel` — a shared package rendered inside the circle-spaces video room — carries the
same `createWithEqualityFn`-without-`shallow` re-render footgun documented in ISSUE-002/101/201,
**and** most of its selectors needlessly wrap a single field in an object literal, which guarantees
a re-render on every store write.

## Evidence
- 3 stores via `createWithEqualityFn` (`zustand/traditional`): `useBreakoutsStore.tsx:206`,
  `useBreakoutsLayoutStore.tsx`, `useMetricsStore.tsx`. None pass a `shallow` comparator.
- 0 `shallow`/`useShallow` imports anywhere in `breakouts-panel/src`.
- 23 object-literal selectors (excl. tests/stories), e.g.:
  - `src/components/BreakoutsFooter/BreakoutsFooter.tsx:21` —
    `const { breakoutGroups } = useBreakoutsStore((state) => ({ breakoutGroups: state.breakoutGroups }));`
  - `src/components/BreakoutGroupContainer/BreakoutGroupContainer.tsx:21` —
    `const { userIdToScrollTo } = useBreakoutsLayoutStore((state) => ({ userIdToScrollTo: state.userIdToScrollTo }));`
  Both select **one field** but wrap it in `({ ... })`, so the selector returns a new object every
  call → re-render on every store write regardless of the field.

## Mechanism
Identical to ISSUE-002 (verified against `zustand@5.0.12` there). `equalityFn === undefined` ⇒ the
shallow short-circuit is skipped ⇒ the fresh object literal is a new reference every time ⇒
re-render. For these single-field selectors the object wrapper is pure overhead — returning the
primitive directly would be reference-stable.

## The codebase already has the right pattern (use it as the reference)
`packages/new-asb` uses the SAME `createWithEqualityFn` store but selects **primitives**:
`useAgendaSidebarStore((s) => s.tabs.activeTab)` — reference-stable, no spurious re-renders even
without `shallow`. new-asb is the newer agenda sidebar and is **clean**; breakouts-panel (older)
is not. (agenda-browser uses a per-instance factory/context store pattern — not assessed here.)

## Blast radius
Smaller than the apps (3 stores, 23 selectors), but it ships inside the render-sensitive video
room as the breakouts UI. Live during breakout sessions.

## Proposed fix (do not implement yet)
Two trivial options:
- **Best for single-field selectors:** drop the object wrapper — `const breakoutGroups =
  useBreakoutsStore((s) => s.breakoutGroups);` (matches the new-asb reference, no `shallow` needed).
- **For genuine multi-field selectors:** add the default `shallow` comparator at each
  `createWithEqualityFn` call (3 one-liners).

## Effort / risk
Very low. Mechanical. Fold into the repo-wide "enable shallow / fix selectors" sweep
(ISSUE-002/101/201) — and adopt new-asb's primitive-selector style as the house standard.

## Cross-references
[ISSUE-002](ISSUE-002-createwithequalityfn-without-shallow.md) ·
[ISSUE-101](ISSUE-101-chp-zustand-shallow-and-logger.md) ·
[ISSUE-201](ISSUE-201-mycircles-zustand-shallow.md). new-asb = clean reference implementation.
