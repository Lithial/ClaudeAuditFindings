# ISSUE-101: circle-homepages repeats the Zustand `shallow` footgun + logger-store coupling

- **Severity:** S2
- **Status:** 🔴 confirmed
- **Area:** `apps/circle-homepages` / state + logging
- **Found:** 2026-06-01 (graphify graph of circle-homepages → same god-node shape as circle-spaces → verified)

## Symptom
circle-homepages exhibits the **same two problems** found in circle-spaces (see ISSUE-001 and
ISSUE-002), independently confirmed here. The graphify graph of circle-homepages
(2,433 nodes · 4,110 edges · 103 communities) has the same tell-tale shape: its **#1 god node is
`UseLogger()` (81 edges)** and **#3 is `useGlobalStore` (50 edges)**.

## Evidence (circle-homepages, 2026-06-01)
- **7** stores created with `createWithEqualityFn` (`zustand/traditional`).
- **0** files import `shallow` / `useShallow`.
- **59** object-literal store selectors `useXxxStore((state) => ({ ... }))` — all unguarded.
- `src/components/Logger/useLogger.tsx:17` subscribes at the hook body:
  ```ts
  const { apiUrl, jwt, magicKey, forumParams } = useGlobalStore((state) => ({
      apiUrl: state.apiUrl, jwt: state.jwt, magicKey: state.magicKey, forumParams: state.forumParams,
  }));
  ```
  Same fresh-object-literal selector, no `shallow`, so every `useGlobalStore` write re-renders
  every logger-holding component.

## Mechanism
Identical to ISSUE-002 (verified against `zustand@5.0.12` internals there): `createWithEqualityFn`
with no default comparator + object-literal selectors with no per-call `shallow` ⇒
`equalityFn === undefined` ⇒ the shallow short-circuit is skipped ⇒ a new reference is returned on
every store write ⇒ re-render regardless of whether selected fields changed.

## Blast radius
Smaller than circle-spaces (7 stores / 59 selectors vs 28 / 432), and the dashboard is less
render-intensive than the live video room, so the practical cost is lower. But `useGlobalStore`
holds auth/session essentials (`jwt`, `apiUrl`, `magicKey`, `forumParams`) read widely, and
`UseLogger` is again the most-connected node — so the same logger→store re-render fan-out applies.

## Proposed fix
Same as ISSUE-002, scaled down:
- Add the default `shallow` comparator once per store at the `createWithEqualityFn` call
  (7 one-line changes fix all 59 selectors).
- For `useLogger`, prefer lazy `useGlobalStore.getState()` reads at log time over the hook-body
  subscription (mirrors the circle-spaces recommendation in ISSUE-001).

## Effort / risk
Low. ~7 one-line store edits + one logger touch-up. Verify the dashboard in the browser
before/after. Best done together with ISSUE-002 as a single "enable shallow everywhere" sweep
across both apps.

## Cross-references
- Same root cause as [ISSUE-002](ISSUE-002-createwithequalityfn-without-shallow.md) (circle-spaces).
- Same logger-coupling shape as [ISSUE-001](ISSUE-001-uselogger-rerender-multiplier.md).
- Architecture overview: [MAP-circle-homepages.md](MAP-circle-homepages.md).
- Graph artifacts: `apps/circle-homepages/graphify-out/` (graph.html, GRAPH_REPORT.md, wiki/).
