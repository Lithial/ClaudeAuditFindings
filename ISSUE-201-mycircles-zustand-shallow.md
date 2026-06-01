# ISSUE-201: my-circles repeats the Zustand `shallow` footgun across all 5 global stores (43 unguarded object-literal selectors, 0 `useShallow`)

- **Severity:** S2
- **Status:** confirmed
- **Area:** my-circles / state
- **Found:** 2026-06-01 (manual read of all `src/components/GlobalStore/*` + grep of selector call sites)

## Symptom
Every global Zustand store in `my-circles` is created with `createWithEqualityFn` (from `zustand/traditional`) but **no equality comparator is passed**, and **not a single call site uses `useShallow` or imports `shallow`**. 43 of those call sites use object-literal selectors of the form `useXxxStore((state) => ({ ... }))`, which allocate a fresh object every render. Because no shallow comparison is wired up, the default `Object.is` reference check always reports "changed," so these components re-render on *every* store update regardless of whether the fields they selected actually changed. This is the same defect already logged as ISSUE-002 (circle-spaces) and ISSUE-101 (circle-homepages), now confirmed for the third app.

## Evidence
Stores using `createWithEqualityFn` **with no second-arg comparator** (all under `apps/my-circles/src/components/GlobalStore/`):
- `useLoginStore.tsx:43` — `createWithEqualityFn<LoginStore>()(persist(devtools(...)))` — no comparator
- `useCircleSelectStore.tsx:14` — `createWithEqualityFn<CircleSelectStore>()(devtools(...))` — no comparator
- `useOrgStore.ts:19` — `createWithEqualityFn<OrgStore>()(devtools(...))` — no comparator
- `useNotificationStore.ts:20` — `createWithEqualityFn<NotificationStore>()(devtools(...))` — no comparator
- `useAgendaStore.ts:57` — `createWithEqualityFn<AgendaStore & AgendaPanelStoreState>()(devtools(...))` — no comparator

`shallow` / `useShallow` usage in the whole app: **zero** (grep for `useShallow`, `zustand/shallow`, `, shallow`, `{ shallow }` across `src` + `app` returns nothing).

Object-literal selectors (`Store((state) => ({ ... }))`): **43 occurrences** across 30 files. Representative sites:
- `src/components/Logger/useLogger.tsx:17` — `useLoginStore((state) => ({ params: state.params, jwt: state.jwt }))` — **highest-impact**: `useLogger` is the #1 god node (33 graph edges) and is instantiated in dozens of components/hooks, so a fresh selector object here multiplies the re-render across the whole tree.
- `src/components/NavBar/NavBar.tsx:27,34`
- `src/components/AgendaTools/hooks/useAgendaProps.ts:11,17`
- `src/hooks/usePermissions.ts:6,9,12` (three separate store selectors in one hook)
- `src/queries/useGetRolesInOrg.ts:21,22`, `src/queries/useOrganizations.ts:15,18`
- plus 11 modal components and all 4 `TabPanels`.

**Smoking gun — the team has already been bitten by this and documented it inline:** `src/queries/useOrganizations.ts:36-40`:
> "Driving this off `loading` (instead of calling setOrganizationsLoaded from the error effect) avoids a re-render loop: useLogger returns a fresh `logger` ref each render, so any effect that both depends on `logger` and writes to the org store would ping-pong through **non-shallow zustand subscribers**."

That comment is a workaround for exactly this defect rather than a fix of the root cause.

## Mechanism
`createWithEqualityFn` only applies an equality function if one is supplied at store-creation time *or* a `useShallow` wrapper is used at the selector. With neither, Zustand falls back to `Object.is`. An object-literal selector returns `{...}` — a new reference each render — so `Object.is(prev, next)` is always `false` and the subscriber re-renders on every `set()` anywhere in that store, even for unrelated fields. `useLoginStore` holds `person`, `jwt`, `params`, `organizationId`, `loggingOut`, role flags — any write to any of these forces a re-render of all ~15 components selecting from it, including every component that calls `useLogger`.

## Blast radius
All 5 global stores; 43 selector sites across 30 files; effectively the entire interactive surface (NavBar, all tab panels, every circle/member modal, permissions, agenda tools, metrics). `useLoginStore` + `useLogger` coupling makes this app-wide rather than localized.

## Proposed fix
Two standard options (same as ISSUE-002 recommendation):
1. **Per-call-site:** wrap each object-literal selector in `useShallow` (`import { useShallow } from "zustand/react/shallow"`). Lowest risk, explicit.
2. **Per-store default:** pass `shallow` as the second arg to `createWithEqualityFn(creator, shallow)` so every selector on that store is shallow-compared by default. Less churn, but changes equality semantics for all selectors at once (verify no selector relies on referential identity).

Recommendation: option 2 for the 5 stores, then remove the `useOrganizations.ts` workaround comment/logic if it's no longer needed. Single-field primitive selectors (e.g. `(state) => state.circleIdSelected`) don't need either and could be migrated for clarity.

## Effort / risk
Low effort (mechanical). Low risk for single-field selectors; for object-literal selectors verify nothing downstream depends on a new-reference-every-render behavior (unlikely). Recommend a render-count spot check on NavBar + a tab panel before/after, mirroring the ISSUE-001 methodology.
