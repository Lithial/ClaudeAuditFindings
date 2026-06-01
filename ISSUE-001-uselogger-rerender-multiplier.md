# ISSUE-001: `useLogger` re-render multiplier via unguarded Zustand selectors

- **Severity:** S2 (performance — affects ~160 components on every layout interaction)
- **Status:** 🔴 confirmed (verified end-to-end against source + `zustand@5.0.12` internals)
- **Area:** `apps/circle-spaces` / state + logging
- **Found:** 2026-06-01 (graphify god-node analysis → source trace → library-internals validation)

## Symptom
`useLogger()` is the #1 most-connected node in the graph (167 edges, 160 incoming callers).
It is structurally a clean facade (only 7 outgoing deps), **but** because it is a React hook
that subscribes to Zustand stores with unguarded object-literal selectors, all ~160
logger-holding components re-render on essentially every layout/panel/modal/media interaction.

## Evidence
**The dependency chain (graph + source):**
```
useLogger()  ──calls──▶  useDetectOrientation()  ──subscribes──▶  useLayoutControlsStore
```
- `apps/circle-spaces/src/hooks/useLogger.tsx` — calls 6 hooks at body level
  (`useStorybook`, `useTraceStore`, `useEnvStore`, `useDevStore`, `useClientMetricsData`,
  `useDetectOrientation`) + `useIntl`. Each store selector returns a fresh object literal,
  e.g. `useEnvStore((state) => ({ apiHost, magicKey, disableLogUpload, setDisableLogUpload }))`
  with **no** `shallow` 2nd arg.
- `apps/circle-spaces/src/hooks/useDetectOrientation.ts:13` —
  `useLayoutControlsStore((state) => ({ isMobile, isPhone, orientation }))`, again no `shallow`.
- `apps/circle-spaces/src/state/useLayoutControlsStore.tsx` — created via
  `createWithEqualityFn<...>()(persist(devtools(initializer)))` with **no equality fn argument**.

**Library internals (rigorously verified, not assumed):**
- `node_modules/zustand@5.0.12/esm/traditional.mjs`: the bound hook is
  `(selector, equalityFn = defaultEqualityFn) => ...`. With no 2nd arg at create time,
  `defaultEqualityFn` is `undefined`.
- `node_modules/use-sync-external-store/.../with-selector.development.js`: the shallow
  short-circuit is gated on `void 0 !== isEqual && isEqual(currentSelection, nextSelection)`.
  When `isEqual` is `undefined`, **the guard is skipped** and the freshly-built object literal
  (new reference) is returned, triggering a re-render.

## Mechanism
1. Zustand calls subscribers on **every** `set()`, and each `set()` produces a new top-level
   state object, so the `objectIs(memoizedSnapshot, nextSnapshot)` fast-path fails on every write.
2. The selector then runs and returns a **new object literal** (new reference).
3. Because the equality fn is `undefined`, there is no shallow comparison to collapse it back to
   the cached value → `useSyncExternalStore` sees a changed snapshot → re-render.
4. Net: a component re-renders whenever the *store it subscribes to* is written, **even if the
   selected fields did not change**.

## Blast radius
`useLayoutControlsStore` is not a single store — it is a **6-slice composite** with **81 setter
actions**:
| slice | setters |
|-------|---------|
| `LayoutControlPanelStates.ts` | 23 |
| `CirclesLayoutStates.ts` | 15 |
| `ReschedulerPanelStore.ts` | 14 |
| `TransitionLayoutStates.ts` | 13 |
| `MediaLayoutState.ts` | 9 |
| `LayoutInitialization.ts` (orientation/isMobile) | 7 |

Any of those 81 mutations (open a modal, toggle a panel, a layout transition, a media-layout
change, an orientation flip) re-renders `useDetectOrientation` → `useLogger` → **all ~160
components that hold a logger**. Layout transitions in particular may `set()` rapidly during
animations.

## Proposed fix
Two independent options, either sufficient; **(B) recommended**:

- **(A) Add `shallow`** to the selectors in `useLogger.tsx` and `useDetectOrientation.ts`
  (`import { shallow } from "zustand/shallow"`, pass as 2nd selector arg, or use `useShallow`).
  Smallest change; collapses re-renders to only when selected fields actually change.
- **(B) Lazy `getState()` reads (preferred).** `useLogger` does not need orientation/env
  *reactively* — they're only used inside the async `trace()` / `uploadLine()` paths. Read them
  lazily via `useLayoutControlsStore.getState()` / `useEnvStore.getState()` at log time instead
  of subscribing at the hook body. This removes the render-time subscription entirely and severs
  the `useLogger ↔ useLayoutControlsStore` chain. **Precedent already in the file:** `trace()`
  already does `useTraceStore.getState().storeTrace(newTrace)`.

## Effort / risk
- (A): ~30 min, very low risk (pure selector-equality change). Verify nothing relied on the
  reference-identity churn (nothing should).
- (B): ~1–2 hrs, low–medium risk. Need to confirm no consumer depends on `isMobile`/env being
  reactive *through the logger* (they should get reactivity from their own
  `useDetectOrientation` call, not the logger's). Verify in the live room via the join-room skill.
- Either way: confirm the broader pattern first — see ISSUE-002 — so this isn't fixed in isolation.
