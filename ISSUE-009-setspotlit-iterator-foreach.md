# ISSUE-009: `setSpotlit` calls `.forEach()` on a Map iterator (`map.values().forEach`) — relies on unshipped iterator-helpers, throws on older runtimes

- **Severity:** S2
- **Status:** partially resolved — fixed in branch `fix/duplicate-user-by-person-id` (commit `212c65fc`), pending merge to `staging`
- **Area:** circle-spaces / state (useCirclesUsers)
- **Found:** 2026-06-01 (manual read)

## Resolution (2026-06-08)
Fixed on branch `fix/duplicate-user-by-person-id`: `setSpotlit` now spreads first — `[...usersMapClone.values()].forEach(...)` — so it no longer depends on ES2025 Iterator Helpers. Outstanding only: merge to `staging`. Confirming the original runtime-floor risk against the browser matrix is moot once merged.

## Symptom
`setSpotlit` iterates the users map with `usersMapClone.values().forEach(...)`. `Map.prototype.values()` returns a **MapIterator**, and `Iterator.prototype.forEach` is a Stage-3 / ES2025 "iterator helpers" proposal that is not available in all supported browsers. On a runtime without iterator helpers this throws `TypeError: ...values(...).forEach is not a function`, breaking spotlight selection entirely.

## Evidence
`apps/circle-spaces/src/state/useCirclesUsers.tsx`, `setSpotlit`:
```
254 setSpotlit: (spotlitExternalId) =>
255     set((state) => {
257         const usersMapClone = new Map(state.users);
259         usersMapClone.values().forEach((user: UserType) => {   // .forEach on a MapIterator
260             const userClone = { ...user };
261             if (!userClone) return;
262             userClone.spotlit = user.externalId === spotlitExternalId;
264             usersMapClone.set(user.externalId, userClone);
265         });
```
Every other setter in this same file iterates with `state.users.forEach(...)` (the Map's own `forEach`, which IS standard) — e.g. `setRandomOrder` (279, 289), `setLocalHandraise` (307), `setHandraise` (330). `setSpotlit` is the lone outlier using the iterator form.

## Mechanism
`Map.prototype.forEach` is standard everywhere; `MapIterator.prototype.forEach` only exists where the TC39 iterator-helpers proposal has shipped (e.g. Chrome 117+/V8). Safari and Firefox shipped iterator helpers more recently, and older supported browser versions do not have it at all. Where it is absent, the call throws and the spotlight update aborts.

## Why "suspected" not "confirmed"
On a sufficiently new Chrome/V8 (the likely dev environment) this works, which is probably why it passed review. The defect is a portability/runtime-floor risk: it will throw on any supported browser/runtime lacking iterator helpers. Confirming requires checking the app's actual browserslist / minimum supported browser matrix.

## Blast radius
Spotlight feature (facilitator spotlighting a participant). On affected runtimes the entire `setSpotlit` action throws, so spotlight does nothing and the immer producer aborts mid-update.

## Proposed fix
Iterate the Map directly like every other setter: `usersMapClone.forEach((user) => { ... })`, or spread first: `[...usersMapClone.values()].forEach(...)`. Recommended: match the file's prevailing `state.users.forEach` style.

## Effort / risk
Trivial. Risk: near-zero; aligns with existing patterns in the same file.
