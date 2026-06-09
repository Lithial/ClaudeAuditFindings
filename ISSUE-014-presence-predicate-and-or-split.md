# ISSUE-014: "Is this user connected?" is decided per-consumer (AND vs OR), with no shared predicate

- **Severity:** S3
- **Status:** confirmed
- **Area:** circle-spaces / state (user-map presence)
- **Found:** 2026-06-08 (manual read, while fixing the duplicate-user bug)

## Symptom
Two different definitions of "connected" coexist across the codebase with no shared helper enforcing them. Some consumers gate on **both** transports being live (`hasChimeConnection && hasCirclesSocketConnection`), others on **either** (`hasChimeConnection || hasCirclesSocketConnection`). Each new consumer re-decides ad hoc and can pick the wrong one.

## Evidence
**AND** (`chime && socket`) — "fully present / countable":
- `apps/circle-spaces/src/hooks/GraphqlHooks/useTalkTime.tsx:46`
- `apps/circle-spaces/src/hooks/FeatureHooks/useHug.tsx:36`
- `apps/circle-spaces/src/hooks/StateHooks/useLocalUserHandraiseQueue.tsx:20`
- `apps/circle-spaces/src/features/Sidebar/SidebarContainer.tsx:73`

**OR** (`chime || socket`) — "keep showing / don't prune":
- `apps/circle-spaces/src/hooks/useDebouncedDeadRemoteUserPrune.ts:10` (`isConnectionAlive`)
- `apps/circle-spaces/src/utils/users.ts:34` (`isUserVisible`, post-greenroom OR)

## Mechanism
The split is actually *defensible* — a half-connected user (e.g. Chime dropped but socket still up, the exact lingering-join state behind the duplicate-user bug) should stay **visible** (OR) but should not be **counted** in talk-time/hug/handraise (AND). But the intent lives only in each call site's inline boolean; there is no `isUserPresent()` to sit alongside the existing `isUserVisible()`, so the semantics are rediscovered (and mis-picked) per consumer.

## Blast radius
Maintainability / latent correctness. Four AND sites + two OR sites today. A future consumer that picks OR where it needed AND would, e.g., count a ghost/half-connected join in talk-time or the participant count; picking AND where it needed OR would hide a user mid-reconnect. Directly adjacent to the duplicate-user class (the personId-dedup work on branch `fix/duplicate-user-by-person-id`).

## Proposed fix
Add a named `isUserPresent(user)` (= `chime && socket`) to `apps/circle-spaces/src/utils/users.ts`, next to the existing `isUserVisible` (OR), and route the four AND sites through it. Two named predicates make the "visible vs countable" distinction explicit and greppable.

## Effort / risk
Small (~30 min, mechanical). Risk: low — pure extraction of existing booleans; verify each call site's current AND/OR is preserved (don't accidentally flip `useHug`'s `==` loose check at line 36).
