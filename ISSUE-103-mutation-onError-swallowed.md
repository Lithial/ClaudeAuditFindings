# ISSUE-103: Transport/GraphQL errors on key mutations are silently swallowed (no `onError`, no Logger, no Honeybadger)

- **Severity:** S2
- **Status:** 🔴 confirmed
- **Area:** circle-homepages / graphql + error monitoring
- **Found:** 2026-06-01 (manual read of login + notes mutation hooks)

## Symptom
The login mutation and all six notes mutations handle only the *logical* failure case (`result.successful === false`). They provide no `onError` callback and the call sites don't `.catch()` the returned promise. A network failure or a GraphQL transport error (the case Apollo's default `errorPolicy: "none"` turns into a rejected promise — see ISSUE-102) produces no user feedback, no `logger.error`, and therefore nothing in Honeybadger (Honeybadger is wired only into `Logger.error`, see `Logger.ts:104-108`).

## Evidence
- `src/components/Login/LoginPanel/useLogin.tsx:57-108` — `login({ variables, onCompleted(result){...} })`. Only `onCompleted`; no `onError`, no try/catch. If the auth request fails at the network/GraphQL layer the user sees nothing (the `showLoginError` path is only reached from `onCompleted` ⇒ `successful === false`).
- `src/components/Login/LoginPanel/useLogin.tsx:68` — `result.userAuthenticate.messages[0].message` assumes `messages` is a non-empty array; if `successful` is false but `messages` is `[]`/null this throws *inside* `onCompleted`.
- `src/components/DashboardContainer/NotesViewer/useNoteMutations.ts:43-119` — all six `useMutation` hooks (`reorderNotes`, `noteDeleteCompleted`, `noteBulkUpdate`, `postNote`, `editNote`, `deleteNote`) define only `onCompleted`; none define `onError`. Optimistic local state (e.g. `setNoteGroups` in `reorderNotesCallback`, line 320) is applied before the server responds and is never rolled back on transport failure.
- `Logger.ts:104-108` — confirms `Honeybadger.notify` fires only from `error()`, so any error not passed through `logger.error` is invisible to monitoring.

## Mechanism
`useMutation` rejects (or calls `onError`) on transport/GraphQL errors. With no `onError` and no `.catch`, React/Apollo logs an unhandled rejection at most; the app's own monitoring never sees it, and optimistic UI is left in a wrong state.

## Blast radius
Login (every user, the most critical path) and the entire notes feature (a god-node community per the graph). Combined with ISSUE-102's missing error link, these failures are completely dark.

## Proposed fix
- Add `onError` to each mutation (and `useLazyQuery`) that routes to `logger.error` + a user-facing notification via the existing `useNotifications().action`.
- Guard `messages[0]` (`messages?.[0]?.message ?? <generic>`).
- For notes optimistic updates, roll back local state in `onError`.
- Best handled together with the shared error link in ISSUE-102.

## Effort / risk
Small per call site, but many sites. Low risk; purely additive error handling.
