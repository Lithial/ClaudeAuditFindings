# ISSUE-202: Circle mutations report success on promise-resolve without checking `successful` — false "success" toasts on server-side validation failure

- **Severity:** S1
- **Status:** confirmed
- **Area:** my-circles / graphql
- **Found:** 2026-06-01 (manual read of mutation hooks + modal handlers + `graphqlTypes.ts`)

## Symptom
The Absinthe/Ash backend returns mutation results as `{ successful: boolean, messages: [...], result }` and **resolves the Apollo promise even when `successful: false`** (business/validation errors are delivered in `messages`, not thrown as GraphQL errors). Most `my-circles` mutation handlers treat "promise resolved without throwing" as success: they show a green success notification, fire the `circlesChanged` refetch event, and close the modal — even when the server actually rejected the operation. The user is told the circle/member was created/edited when it was not.

## Evidence
The response types explicitly model `successful` (so the shape is known), e.g. `src/types/graphqlTypes.ts`:
- `CreateManyCirclesResponse.circleCreateMany.successful` (line 169)
- `EditCircleResponse.circleUpdate.successful` (line 190)
- `CreateNewPeopleResponse.personCreateMany.successful` (line 261)
- `RemovePersonFromCircleResponse.circleRemoveParticipant.successful` (line 232)

Handlers that **do not** check `successful` and report success unconditionally on `.then()`:
- `src/components/ModalContainer/Modals/AddNewCircleModal/AddNewCircleModal.tsx:120-134` — `createManyCircles(...).then(() => { ... notify("circle-created"); dispatch circlesChanged; closeDialog })`. Never inspects `data.circleCreateMany.successful` or `messages`. The outer `createPeople(...).then(({ data }) => ...)` (line 90) also doesn't check `personCreateMany.successful`.
- `src/components/ModalContainer/Modals/EditCircleDetailsModal/EditCircleDetailsModal.tsx:46-52` — `editCircle(...).then(() => notify("circle-edited"))`. No `successful` check.
- `src/components/ModalContainer/Modals/AddMembersToCircleModal/AddMembersToCircleModal.tsx:74-97` — chains `createPeople → addPersonToCircle`, then `notify("member-added")`. No `successful` check on either mutation.
- `src/components/ModalContainer/Modals/BulkAddCirclesModal/useBulkCreateCircles.ts:74-79` — logs "Circles created successfully" off the resolved promise; no `successful` check.

The **one correct example** confirming the intended pattern is `src/queries/useRemovePersonFromCircle.ts:22-28`, which does the right thing:
```
if (response.data?.circleRemoveParticipant.successful) { ... } else { logger.error("Error removing member:", response.data?.circleRemoveParticipant.messages); }
```
So the codebase already knows `successful: false` arrives on a resolved promise — the other handlers just skip the check.

### Secondary crash (S1) in the same file
`AddMembersToCircleModal.tsx:78-79`:
```
const newPerson = allPeople[0];
return addPersonToCircle({ variables: { input: { personId: newPerson.id, ... }}});
```
If `personCreateMany` failed validation, `newPeople`/`existingPeople` are empty (the `|| []` fallbacks on lines 75-76), so `allPeople[0]` is `undefined` and `newPerson.id` throws `TypeError: Cannot read properties of undefined`. It lands in the `.catch` (line 98) and surfaces a generic "error-adding-member" alert — so the user gets an error rather than a crash, but the real cause (person creation rejected) is masked, and the same undefined-access pattern would bite anywhere it isn't wrapped.

## Mechanism
Apollo only rejects a mutation promise on transport/GraphQL-level errors. Ash/Absinthe domain mutations succeed at the GraphQL layer (HTTP 200, no `errors[]`) and encode the domain outcome in `successful`/`messages`. `.then()` therefore runs on validation failure, and code that doesn't read `successful` cannot distinguish success from rejection.

## Blast radius
All four primary write flows in the app: create circle, bulk-create circles, edit circle, add member. Users can be shown a success toast and a closed modal while the operation silently failed (e.g. duplicate name, permission denied, invalid email). The `circlesChanged` refetch then re-renders the unchanged list, reinforcing the illusion. Data-integrity / trust impact → S1.

## Proposed fix
In each `.then(({ data }) => ...)`, branch on `data?.<mutationField>.successful`:
- success → notify + dispatch `circlesChanged` + close
- failure → `logger.error(..., data?.<field>.messages)` + `notifyAlert(...)`, do **not** close or fire `circlesChanged`.
Mirror the existing `useRemovePersonFromCircle` pattern. For `AddMembersToCircleModal`, also guard `allPeople.length === 0` before indexing `[0]`.
Consider centralizing: a small `assertMutationSuccess(data, field, messages)` helper, or moving the check into each `useXxx` mutation hook so call sites can't forget it.

## Effort / risk
Medium-low effort (4-5 handlers). Low risk — adds a branch on data already returned. Main risk is missing a `messages` localization key; check `lang/*.json` for existing `notifications.error-*` keys (most already exist, used by the catch branches).
