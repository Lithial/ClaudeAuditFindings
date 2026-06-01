# ISSUE-107: `useJWT` `storage` listener is never removed (cleanup passes a different function instance)

- **Severity:** S3
- **Status:** 🔴 confirmed
- **Area:** circle-homepages / react hooks
- **Found:** 2026-06-01 (manual read of `JWTManagement/useJWT.ts`)

## Symptom
`useJWT` adds a `storage` event listener with an inline arrow function and tries to remove it with a *different* inline arrow function. `removeEventListener` matches by reference, so the original listener is never removed; every mount/remount of a `useJWT` consumer leaks another listener.

## Evidence
File: `src/components/JWTManagement/useJWT.ts`
- `:22` — `window.addEventListener("storage", () => checkAndSetJWT());`
- `:27` — `window.removeEventListener("storage", () => checkAndSetJWT());`
- These two arrow expressions are distinct objects, so the remove is a no-op. The effect's dep array is `[]` (`:29`), so the leak is per component instance/remount.
- `useJWT` is invoked from at least `useLogin` (`src/components/Login/LoginPanel/useLogin.tsx:14` — `UseJwt();`), and is a cross-store sync primitive used wherever JWT freshness matters.

## Mechanism
`EventTarget.removeEventListener` requires the same function reference that was passed to `addEventListener`. A freshly-allocated arrow can never match.

## Blast radius
Each accumulated listener calls `checkAndSetJWT` (which calls `getJWT()` + `setJWT`/`clearJWT` on the global store) on every cross-tab storage event. Over a long session with navigation/remounts this multiplies redundant store writes per storage event and never frees the handlers — a slow memory/CPU leak. Low severity because each handler is cheap, but it is a real, unbounded leak.

## Proposed fix
Hoist a stable handler: `const onStorage = () => checkAndSetJWT();` then `addEventListener("storage", onStorage)` and `return () => removeEventListener("storage", onStorage)`. (Wrap `checkAndSetJWT` in `useCallback` if it must be stable.)

## Effort / risk
Tiny. Low risk.
