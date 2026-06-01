# ISSUE-106: `extractForumsData` does an unguarded `JSON.parse` on every member's `extraFields` — one malformed record crashes the whole forum render

- **Severity:** S1
- **Status:** 🔴 confirmed
- **Area:** circle-homepages / graphql response-shape
- **Found:** 2026-06-01 (manual read of `mfv/PageContent/useForumState.ts`)

## Symptom
Forum-member parsing calls `JSON.parse(memberNode.extraFields)` with no try/catch, inside a `.map` that runs synchronously in a `useEffect`. A single member whose `extraFields` is non-JSON (or partially-written) throws, the effect throws, and the entire forum view fails to render rather than degrading for one member.

## Evidence
File: `src/mfv/PageContent/useForumState.ts`
- `:155` — `const extraFields = memberNode.extraFields ? JSON.parse(memberNode.extraFields) : {};` — guards only for empty/falsy, not for invalid JSON.
- `:153-203` — this runs inside `profileEdgesInsideForum.map(...)` so a throw aborts the whole `extractForumsData` for that forum (and the surrounding loop over forums).
- `:271-299` — `extractForumsData(...)` is invoked directly in a `useEffect`; the throw propagates out of the effect (no try/catch), surfacing as a render error.
- The `.edges`/`.node` accesses around it *are* defensively guarded (`?.edges ?? []`, `pEdge.node ?? {}`), which makes the bare `JSON.parse` the sole unguarded crash point and confirms the author was otherwise being careful.

## Mechanism
`extraFields` is a server-provided JSON-encoded string. The schema (`personQueries.ts:73`) types it as an opaque field; nothing guarantees well-formed JSON for every historical record. `JSON.parse` throws synchronously on bad input.

## Blast radius
The MFV / guide-home forum dashboard (`useForumState` is a god-node hub in the graph: `ForumData` has 41 edges). One bad member record blanks the forum for the guide. Also a latent data-quality landmine: any backend change to `extraFields` encoding breaks all forums at once.

## Proposed fix
Wrap in a helper: `try { return JSON.parse(s) } catch { logger.error("bad extraFields", { id }); return {} }`. Keeps the rest of the member list rendering.

## Effort / risk
Tiny. Low risk; strictly more defensive.
