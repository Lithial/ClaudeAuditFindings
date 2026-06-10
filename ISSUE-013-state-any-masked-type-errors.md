# ISSUE-013: `(state: any)` selector casts were masking real type errors

- **Severity:** S2 (type-safety holes; several are likely S1 runtime bugs — see table)
- **Status:** 🟡 suspected (type errors confirmed by `tsc`; runtime impact needs per-item verification)
- **Area:** `apps/circle-spaces` / state (Zustand selectors) + downstream consumers
- **Found:** 2026-06-07 (surfaced while removing redundant `(state: any)` casts — commit `555ecca3`, preserved in closed PR [#1000](https://github.com/circles-learning-labs/circles-frontend/pull/1000))
- **Related:** [ISSUE-002](ISSUE-002-createwithequalityfn-without-shallow.md) (same selector call sites), [ISSUE-003](ISSUE-003-ts-expect-error-suppressions.md) (sibling pattern: suppressions hiding type holes)

> **Provenance update (2026-06-10):** the source branch `lithial/refactor/circle-spaces-drop-selector-state-any` and PR #1000 were closed/deleted as **superseded** — `staging` independently refactored these selectors (multi-field → `useShallow`, single-field → atomic `(s) => s.x`), which absorbed the branch's mechanical cast removals. The diagnostic finding below is **unaffected**: the 13 flagged files still carry `(state: any)` on `staging` (~35 occurrences verified 2026-06-10), so the 18 masked type errors remain actionable. Commit `555ecca3` is still viewable in the closed PR for reference.

## Symptom
`(state: any)` was used on **124** Zustand selector call sites in circle-spaces. Because every
store is declared with the curried `createWithEqualityFn<T>()` form, the `state` parameter is
already fully inferred — so the `any` was pure loss: it discarded inference **and** widened the
selector's return value to `any`, letting type-unsafe usage flow downstream undetected.

Removing the cast (87 sites cleaned cleanly in `555ecca3`) caused `tsc --noEmit` to surface
**18 genuine type errors** across **13 files** that the `any` had been suppressing. To keep that
cleanup commit green, the casts on those 13 files were **retained** (33 `any` casts kept at
file-granularity revert) and are logged here as follow-up work.

> Count note: "33 anys" = casts retained across the 13 files (some are collateral from reverting
> whole files). The **18 rows below are the actionable items** — each is a distinct `tsc` error.

## Evidence (`tsc --noEmit -p apps/circle-spaces/tsconfig.json`, diffed vs pristine `staging` baseline)

| # | File:line | TS code | Error | Likely sev |
|---|-----------|---------|-------|-----------|
| 1 | `hooks/useRoomStateUpdates.tsx:220` | TS2554 | Expected 4 arguments, but got 5 | **S1** (wrong call) |
| 2 | `hooks/useRoomStateUpdates.tsx:372` | TS2345 | `URL` not assignable to `string` | S2 |
| 3 | `hooks/useRoomStateUpdates.tsx:444` | TS2345 | `number \| undefined` → `number \| null` | S2 |
| 4 | `features/.../AgendaEditor/AgendaEditorFloating.tsx:51` | TS2367 | comparison has no overlap (`"agendaStart"` vs `"noAgenda"\|"agendaLoaded"\|"agendaStarted"`) | **S1** (dead branch — likely typo for `agendaStarted`) |
| 5 | `features/.../AgendaEditor/AgendaEditorFloating.tsx:69` | TS2339 | `pages` does not exist on type `{}` | **S1** (crash risk) |
| 6 | `features/.../AgendaEditor/AgendaEditorFloating.tsx:89` | TS2739 | `{}` missing `name`, `description`, `pages` of `Agenda` | **S1** (crash risk) |
| 7 | `features/.../AgendaWarningModal/AgendaWarningModal.tsx:90` | TS2554 | Expected 0 arguments, but got 1 | **S1** (wrong call) |
| 8 | `features/.../AgendaMenuHooks/Agenda/useAgendaButtonSharedFunctions.tsx:158` | TS2554 | Expected 0 arguments, but got 1 | **S1** (wrong call) |
| 9 | `features/.../AgendaMenuHooks/Tools/useTimerButtons.tsx:21` | TS2345 | `number \| null` → `SetStateAction<boolean>` | **S1** (state type confusion) |
| 10 | `features/.../AgendaControls/AgendaControlHooks/useAgendaCurrentTime.ts:37` | TS2345 | `Date \| null` → `string \| number \| Date` | S2 |
| 11 | `hooks/FeatureHooks/useHug.tsx:48` | TS2345 | `string \| undefined` → `UserType \| null \| undefined` | **S1** (passing id where object expected) |
| 12 | `hooks/useInitialize.tsx:146` | TS2345 | `{ retryCount: number }` → `boolean \| undefined` | **S1** (wrong arg shape) |
| 13 | `hooks/Breakouts/useSessionStorageSettings.tsx:110` | TS2345 | `boolean \| null` → `boolean` | S2 |
| 14 | `components/Wrappers/FloatingPanelWrapper.tsx:133` | TS2322 | `boolean \| null` → `boolean` | S2 |
| 15 | `components/Wrappers/FloatingPanelWrapper.tsx:155` | TS2322 | `(s: ScheduleSessionType \| null) => void` → `() => void` | S2 (arity mismatch) |
| 16 | `components/FloatingControlPanel/FloatingControlPanel.tsx:163` | TS2345 | `string \| null` → `string` | S2 |
| 17 | `components/ModernMobileLayouts/.../MobileFloatingControlPanel.tsx:119` | TS2345 | `string \| null` → `string` | S2 |
| 18 | `components/VideoTile/hooks/useSetLocalCirclePosition.ts:20` | TS2322 | `number \| undefined` → `number` | S2 |

### Separate, NOT a bug (S3 cleanup)
`state/LayoutStore/LayoutControlPanelStates.ts` lines 79/85/90/94 — `set((state: any) => …)`
slice updaters. Dropping `any` gives TS7006 ("implicit any") because the slice's `set` isn't
generically typed (cross-slice fields aren't visible in the slice file). These need the slice
typed properly (e.g. `StateCreator<FullStore, [...], [], Slice>`), not a blind cast removal.

## Mechanism
`any` on a selector return widens everything that reads it. The clustering by category is telling:
- **Null/undefined holes** (`string | null → string`, `number | undefined → number`, etc.): the
  store field is nullable but the consumer assumes non-null. With `any` these never tripped.
- **Arg-count / arg-shape mismatches** (TS2554, TS2345 on call args): a function is being called
  with the wrong number/shape of arguments — usually a real bug.
- **Empty-object inference** (TS2339/TS2739 on `{}` in AgendaEditorFloating): a selector returned
  `any`, got narrowed to `{}` once typed, and `.pages` access / `Agenda` assignment now fail —
  strong crash-risk candidates.

## Proposed fix
Per file, remove the `(state: any)` cast and fix the genuine error it reveals (add `?? default`,
optional chaining, correct the call signature, or correct the store field's type). Prioritize the
**S1** rows (4–9, 11, 12) — arg-count and missing-property errors are the most likely live bugs.
Then the nullable-flow S2 rows. The `LayoutControlPanelStates.ts` slice typing is independent S3.

## Effort / risk
- ~13 files, mostly one- or two-line fixes once the real intent is confirmed. Each needs a
  judgment call (is the null path reachable? is the extra arg dead code or a missed param?), so
  **do not batch-fix blind** — that's exactly why they were excluded from the cleanup commit.
- Verify the S1 agenda ones in the live room (join-room skill); AgendaEditorFloating `{}` access
  and the `"agendaStart"` comparison look like they could already be silently broken.
