# ISSUE-007: `agendaClose` failure path reads the wrong mutation result field (`circleSetAgenda`), throwing a TypeError exactly when the close fails

- **Severity:** S1
- **Status:** confirmed
- **Area:** circle-spaces / AgendaFeatures (useAgendaActions)
- **Found:** 2026-06-01 (manual read)

## Symptom
The `agendaClose` mutation's `onCompleted` handler, on the failure branch, reads `result.circleSetAgenda.messages` — a field that does not exist on the `agendaClose` response. When `agendaClose` returns `successful: false`, this dereferences `undefined.messages` and throws a `TypeError`, so the intended "report the failure to the logger + show support alert" path crashes instead of running.

## Evidence
`apps/circle-spaces/src/features/AgendaFeatures/AgendaHooks/useAgendaActions.tsx:131-140`:
```
131 const [agendaClose] = useMutation(agendaMutations.mutateAgendaClose, {
132     onError: (error: ApolloError) => handleAgendaError(error, "mutateAgendaClose"),
133     onCompleted(result) {
134         if (result.agendaClose.successful) return;
135
136         const errorMessages = result.circleSetAgenda.messages;   // BUG: should be result.agendaClose.messages
137
138         handleAgendaMutationErrors("mutateAgendaClose", errorMessages);
139     },
140 });
```
Compare the sibling mutations in the same file which correctly read their own result field:
- `circleSetActive` → `result.circleSetAgenda.messages` (correct for that mutation) — line 125
- `agendaPageUpdate` → `result.circleSetAgendaPage.messages` — line 147
- `roomSetAgendaTimer` → `result.roomSetAgendaTimer.messages` — line 158

So line 136 is a copy-paste from `circleSetActive`: it checks `result.agendaClose.successful` but pulls messages from `result.circleSetAgenda`, which is absent on an `agendaClose` payload.

## Mechanism
On a failed close, `result.agendaClose.successful` is falsy, control falls through to line 136, `result.circleSetAgenda` is `undefined`, and `.messages` throws. Apollo's `onCompleted` is not wrapped in app error handling here, so the throw surfaces as an unhandled exception in the mutation lifecycle and the user-facing `handleAgendaMutationErrors` alert never fires.

## Blast radius
The agenda-close failure path. Users get no "contact support" alert and instead hit an uncaught error precisely when something is already going wrong server-side. Low frequency (only on a failed close) but high severity because the error-handling code is the thing that crashes — a blind spot in exactly the scenario it exists to cover.

## Proposed fix
Change line 136 to `const errorMessages = result.agendaClose.messages;` and add optional chaining for safety (matching `roomSetActiveSession`'s pattern): `result?.agendaClose?.messages ?? []`.

## Effort / risk
Trivial (one-field rename). Near-zero risk; strictly fixes a broken branch.
