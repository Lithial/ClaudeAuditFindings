# ISSUE-203: Login mutation has no transport-error handling — a failed network request silently does nothing

- **Severity:** S2
- **Status:** confirmed
- **Area:** my-circles / auth
- **Found:** 2026-06-01 (manual read of `useLogin.tsx`)

## Symptom
`UseLogin` handles the business-failure case correctly (`result.userAuthenticate.successful === false` → shows "invalid-login"), but the `useMutation` call has **only an `onCompleted` callback and no `onError` / `.catch`**. If the login request fails at the transport/GraphQL layer (network down, server 5xx, CORS, captcha endpoint unreachable), the promise rejects, `onCompleted` never runs, and nothing sets an error. From the user's perspective the "Sign in" button does nothing — no spinner resolution, no message, no retry hint. Apollo will also log an unhandled rejection.

## Evidence
`src/components/Login/useLogin.tsx:48-98`:
```
const [login] = useMutation(loginMutations.userAuthenticate);   // line 15 — untyped, result is `any`
...
login({
  variables: { input },
  onCompleted(result) {
    if (!result.userAuthenticate.successful) { ...setError... }
    else { const { token } = result.userAuthenticate.result; setJWT(token, rememberMe); }
  },
  // no onError
});
```
`handleLogin` returns void and the promise from `login(...)` is neither awaited nor `.catch`-ed, so a rejection is unhandled. There is no loading state surfaced from this hook either, so the UI can't show "trying…/failed".

Secondary: `useMutation(loginMutations.userAuthenticate)` is **untyped** (no generic type args), so `result.userAuthenticate.successful`, `.messages[0].message`, and `.result.token` are all `any` — `result.userAuthenticate.messages[0]` (line 59) will throw if `messages` is empty, with no guard.

## Mechanism
Apollo rejects mutation promises on network/GraphQL transport errors. `onCompleted` only fires on success. With no `onError` and no `.catch`, transport failures are dropped on the floor.

## Blast radius
The single login entry point for the entire app. Affects every user any time the backend/login endpoint is unreachable or errors — the most security/availability-sensitive flow, with the worst possible UX (apparent no-op).

## Proposed fix
Add `onError(err) { logger.error("Login request failed", err); setError({ message: intl.formatMessage({ id: "login.invalid-login" }), location: "sign-in" }); }` (or a network-specific message). Type the mutation: `useMutation<UserAuthenticateResponse, UserAuthenticateVariables>(...)`. Guard `messages[0]?.message`. Optionally expose a `loading` flag from the hook so the button can show progress.

## Effort / risk
Low. Adding `onError` + types is additive; the only behavioral change is that failures now show a message instead of nothing.
