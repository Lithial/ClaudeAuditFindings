# ISSUE-008: local hand-raised state is always `true` — `Array.find()` result compared against `null` instead of `undefined`

- **Severity:** S1
- **Status:** confirmed
- **Area:** circle-spaces / state (useCirclesUsers)
- **Found:** 2026-06-01 (manual read of the 103-edge god store)

## Symptom
`state.localHandRaised` is set from `localHandRaised !== null`, where `localHandRaised` is the return value of `Array.prototype.find(...)`. `find()` returns the matched element or `undefined` — it never returns `null`. So `localHandRaised !== null` is **always `true`**, meaning the local user is reported as hand-raised whenever the handraise update path runs, regardless of whether their hand is actually up.

## Evidence
`apps/circle-spaces/src/state/useCirclesUsers.tsx`, `setLocalHandraise`:
```
305 const localHandRaised = membersWithHandsRaised.find((roomMember) => roomMember.id === state.localUserId);
...
318 state.localHandRaised = localHandRaised !== null;   // find() -> element | undefined, never null => always true
```
Same defect in `setHandraise`:
```
327 const localHandRaised = membersWithHandsRaised.find((roomMember) => roomMember.id === state.localUserId);
...
361 if (externalId === state.localUserId) state.localHandRaised = localHandRaised !== null;   // always true when this branch runs
```

## Mechanism
JavaScript `Array.prototype.find` yields `undefined` when no element matches, so the correct truthiness test is `localHandRaised !== undefined` or simply `Boolean(localHandRaised)` / `!!localHandRaised`. Comparing to `null` mis-handles the "not found" case, collapsing both raised and lowered into `true`.

## Blast radius
`useCirclesUserStore` is a god node (103 edges). `localHandRaised` drives the local user's raise/lower-hand UI and any logic gated on it. Effect: once a handraise update is processed, the local "lower hand" affordance / raised indicator can stick on even after the hand is lowered (the value cannot become `false` via these two setters). User-visible incorrectness in a core room interaction.

## Proposed fix
Replace both comparisons with `localHandRaised !== undefined` (or `!!localHandRaised`). Recommended: `state.localHandRaised = localHandRaised !== undefined;` in both `setLocalHandraise` (line 318) and `setHandraise` (line 361).

## Effort / risk
Trivial. Risk: if downstream code somehow relied on the always-true behaviour as a workaround, flipping it could expose a second latent bug — verify the lower-hand path once corrected.
