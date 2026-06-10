# ISSUE-002: `createWithEqualityFn` used repo-wide without a `shallow` comparator

- **Severity:** S2 (broad, low-grade perf cost) — escalated from S3 after scoping
- **Status:** 🟢 partially resolved (re-verified 2026-06-10) — circle-spaces adopted **283 `useShallow`** call sites across 210 files (was 0); only ~4 unguarded object-literal selectors remain (`useDownloadButtons.ts:8`, `AgendaWarningModal.tsx:16`, `useSetCircleAssignedMembers.tsx:18,24`). Approach taken was per-selector `useShallow` (not the per-store default); no store passes `shallow` at create. **NB the sweep did not reach 101/201/301** — those apps/packages are still 0 `useShallow`. (orig: 🔴 confirmed, scoped 2026-06-01)
- **Area:** `apps/circle-spaces` / state (all Zustand stores)
- **Found:** 2026-06-01 (generalized from ISSUE-001, then repo-wide grep)

## Symptom
Every Zustand store in circle-spaces is created with `createWithEqualityFn` from
`zustand/traditional` — the variant whose *entire purpose* is to support a custom equality
function (typically `shallow`) so object-literal selectors don't re-render on every write.
**No store supplies one, and no file passes `shallow` per-selector.** The result: the
`createWithEqualityFn` import is functionally identical to plain `create`, and all object-literal
selectors re-render whenever their store is written, regardless of whether the selected fields
changed. ISSUE-001 (`useLogger`) is the worst single instance of this pattern.

## Evidence (circle-spaces, 2026-06-01)
- **28** stores created with `createWithEqualityFn`.
- **0** of them pass a 2nd argument (equality fn) at create time.
- **0** files anywhere import `shallow` (`zustand/shallow`) or `useShallow`.
- **432** object-literal selector call sites of the form `useXxxStore((state) => ({ ... }))`
  — every one of them unguarded.
- **0** stores use plain `create()` (so this is the universal pattern, not a mix).

Library mechanism is identical to ISSUE-001 (verified against `zustand@5.0.12` +
`use-sync-external-store`): with `equalityFn === undefined`, the shallow short-circuit in
`useSyncExternalStoreWithSelector` is skipped, so a fresh object literal (new reference) is
returned on every store write → re-render.

## Mechanism
Same as ISSUE-001. The deciding line is in the bound hook
(`zustand/esm/traditional.mjs`): `(selector, equalityFn = defaultEqualityFn) => ...`. With no
create-time default and no per-call arg, `equalityFn` is `undefined`, and the
`void 0 !== isEqual && isEqual(...)` guard never fires.

## Blast radius
Repo-wide across circle-spaces. Severity per site varies with **how often the store is written**:
- High-write stores (e.g. `useLayoutControlsStore` — 81 setters across 6 slices,
  `useChimeStore`, layout/media stores updated during transitions/animations) → frequent
  needless re-renders of every subscriber.
- Write-once stores (e.g. `useEnvStore`, `useStorybook`) → negligible in practice, but still
  technically unguarded.

The cost is "death by a thousand cuts" rather than one hot path — but it is paid in the video
room, the most render-sensitive surface in the product.

## Proposed fix
**Elegant, low-surface option (recommended):** add the default equality fn **once per store** at
the create call — `createWithEqualityFn<T>()(initializer, shallow)`. That single 2nd-arg addition
fixes **all** selectors on that store at once (28 one-line changes vs. 432 selector edits).
Caveat: any selector that intentionally returns a primitive is unaffected (shallow handles
primitives fine), and any selector relying on reference churn would need review (none should).

**Per-selector option:** wrap with `useShallow(...)` at call sites. More verbose, only worth it
where a store should *not* default to shallow.

Do **not** mass-fix blind. Sequence:
1. Confirm `shallow` is the desired default for each store (it almost always is).
2. Start with the highest-write stores (`useLayoutControlsStore`, `useChimeStore`, media/layout),
   which give nearly all the benefit.
3. Measure before/after with React DevTools Profiler in the live room (join-room skill).

## Effort / risk
- Per-store default: ~5 min/store × ~28 = a focused afternoon, but **front-load the hot stores**
  (3–5 stores capture most of the win).
- Risk: low. Shallow equality is strictly more conservative about re-rendering; the only way it
  breaks behavior is if code (incorrectly) depended on a re-render firing despite unchanged
  values. Verify in the room before/after.
- Relationship to ISSUE-001: fixing this store-default for `useLayoutControlsStore` partially
  addresses ISSUE-001, but the lazy-`getState()` refactor there is still preferable because the
  logger shouldn't subscribe to orientation reactively at all.
