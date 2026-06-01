# ISSUE-205: `SendSessionDetailsModal` ships a live, fully-validated submit button that only `console.log`s a TODO — no-op feature in production UI

- **Severity:** S3
- **Status:** partially resolved — original `console.log` stub fixed; residual fire-and-forget folds into [ISSUE-202]/[ISSUE-203]
- **Area:** my-circles / circle data panel
- **Found:** 2026-06-01 (manual read of `SendSessionDetailsModal.tsx` + `ModalContainer.tsx`)

## Update (2026-06-01, during pre-merge cleanup)
The no-op symptom below is **fixed**: `handleSubmit` no longer `console.log`s — it now calls the real `circleSendInviteToMeetingEmail` mutation via `useSendSessionDetails` (`src/queries/{sendSessionQueries,useSendSessionDetails}.ts`), and the placeholder `console.log("TODO: …")` block has been removed.

**Residual (still open):** `handleSubmit` fires the mutation and immediately `toggleDialog(...)`s closed **without awaiting it or checking `successful`/`messages`**, and `useSendSessionDetails` has **no `onError`** and the component never surfaces `error` — so a failed send is silent and the user gets no success/failure feedback. This is the same class as [ISSUE-202](ISSUE-202-mycircles-mutation-success-not-checked.md) (success not checked) and [ISSUE-203](ISSUE-203-mycircles-login-mutation-no-onerror.md) (no `onError`); fix it as part of that sweep rather than as a standalone item. The disclaimer-copy question that was inline here is now tracked in [ISSUE-207](ISSUE-207-mycircles-send-session-disclaimer-accuracy.md).

---
_Original finding (retained for history):_

## Symptom
The "Send session details" modal is mounted in the production `ModalContainer` and presents a complete form (date, time, duration, purpose, per-member selection) with a submit button that becomes enabled once valid — but `handleSubmit` does **not** call any mutation. It `console.log`s a TODO and closes the dialog. The user fills out and "sends" session details that go nowhere, with positive-looking dismissal feedback.

## Evidence
`src/components/ModalContainer/Modals/SendSessionDetailsModal/SendSessionDetailsModal.tsx:66-77`:
```
const handleSubmit = () => {
    // TODO: Call GraphQL mutation when API is ready
    console.log("TODO: Send session details", { circleId, sessionDate, sessionTime, duration, purpose, selectedMemberIds: ... });
    toggleDialog("sendSessionDetails");
};
```
The submit button (lines 230-235) is wired to `handleSubmit` and only disabled until the form is valid (`disabled={!purpose || !sessionDate || selectedMembers.size === 0}`) — so a fully-filled form submits to nothing and the modal closes as if it worked.

Mounted live in production: `src/components/ModalContainer/ModalContainer.tsx:45-48` renders `<SendSessionDetailsModal .../>` alongside the real modals. This is also the only remaining raw `console.log` in app code (all other modules route through the Logger).

## Mechanism
Feature was built UI-first ahead of the backend mutation ("when API is ready") and merged with the placeholder handler still in place, but the modal was also wired into the live container, so it's reachable by users rather than feature-flagged off.

## Blast radius
Any user who opens this modal from the circle data panel. They believe they've sent session details to selected members; nothing is sent. Reputation/trust + support-load risk; functionally a dead feature presented as live.

## Proposed fix
Either (a) gate the modal behind a feature flag / remove it from `ModalContainer` until the mutation exists, or (b) implement the mutation. Until then, at minimum replace the `console.log` with a `notifyAlert`/disabled state so it doesn't masquerade as success. Route any retained logging through `useLogger` rather than raw `console.log`.

## Effort / risk
Low to hide/flag; medium to implement the real mutation (needs backend support). Removing from `ModalContainer` is the safe interim step.
