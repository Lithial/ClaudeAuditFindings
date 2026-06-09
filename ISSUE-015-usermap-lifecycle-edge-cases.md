# ISSUE-015: circle-spaces user-map connection-lifecycle edge cases (three latent footguns)

- **Severity:** S3
- **Status:** confirmed (15a, 15b) / suspected (15c)
- **Area:** circle-spaces / state (useCirclesUsers, useUserList, useDebouncedDeadRemoteUserPrune)
- **Found:** 2026-06-08 (manual read, while fixing the duplicate-user bug)

Three small, related latent issues in the two-writer user-map lifecycle (Chime roster writer `useUserList` + Circles socket writer `useRoomStateUpdates`, merged into `useCirclesUsers`). Bundled because they share a subsystem and are each individually minor; split into separate tickets at triage if preferred.

## 15a — Pre-greenroom socket-only phantoms are never pruned
**Confirmed.** `useDebouncedDeadRemoteUserPrune.ts` only considers users with `hasPassedGreenroom === true` (lines 31-34, 68-71); anything still pre-greenroom is deleted from the dead-remote tracking ref and skipped. A user who is socket-connected but never passed greenroom (e.g. the `Felipe` entry in the original duplicate-bug log: `hasPassedGreenroom:false, hasChimeConnection:false, hasCirclesSocketConnection:true, attendeeId:""`) can therefore only be removed by a server `RoomRemoveMember`. If that remove is delayed or never arrives, the entry lingers indefinitely as a ghost with `tileId:-1`.
- **Mechanism:** the prune is intentionally greenroom-gated to avoid racing room entry, but that leaves the pre-greenroom socket-only state with no client-side eviction path.
- **Note:** the personId-dedup (branch `fix/duplicate-user-by-person-id`) clears this *if* the same person later rejoins post-greenroom, but not otherwise.
- **Fix sketch:** allow pruning pre-greenroom remotes after a longer debounce when both transports are false, or reconcile against the server member list on a timer.

## 15b — `useUserList` effect self-depends on `users`; loop-safety rests entirely on the equality guard
**Confirmed.** `apps/circle-spaces/src/hooks/useUserList.tsx:118` lists `users` in the effect's own dependency array; the effect both reads and writes `users`. The only thing preventing an infinite render loop is the `areCirclesUserMapsEqual(users, usersCopy)` guard at line 108 — which is correct *only* as long as that comparator covers every field the effect writes. Add a written field to the roster merge without adding it to `areCirclesUsersEqual` (`utils/compareCirclesUserMaps.ts`) and you get either a silently dropped update or a render loop.
- Also: `tiles` is in the dep array (line 118) but the body only uses `attendeeIdToTileId` → harmless extra re-runs.
- **Fix sketch:** add a comment coupling the two files, or restructure so the writer doesn't depend on its own output (e.g. compute from roster/tiles only and merge in the setter against live state, like `addUser` now does).

## 15c — `addUser` merge overwrites `personId`/`avatarKey` with `undefined`
**Suspected (latent).** In `useCirclesUsers.addUser`, the existing-user branch assigns `userClone.personId = personId; userClone.avatarKey = avatarKey;` unconditionally. If a future `RoomAddMember` (or other caller) ever omits these, it would wipe a previously-known `personId`/`avatarKey`. Today every `RoomAddMember` includes them, so this is latent only — but `personId` is now load-bearing for the dedup logic, so silently clearing it would be worse than before.
- **Fix sketch:** only overwrite when the incoming value is defined (`if (personId !== undefined) userClone.personId = personId;`), or treat `personId` as immutable once set.

## Blast radius
Maintainability / latent correctness in the participant presence subsystem. None are current regressions; 15a is the most user-visible (occasional ghost tile), 15b is the highest future-bug risk, 15c is purely defensive.

## Effort / risk
Each is small and independent. 15c is trivial and near-zero risk. 15a and 15b warrant a little care (don't reintroduce ghost dropouts / render loops) — pair with the ISSUE-014 predicate cleanup since they touch the same files.
