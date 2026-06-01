# ISSUE-105: JWT Apollo client effect has stale-closure / missing-dep hazards and `as any` on the subscription link

- **Severity:** S2
- **Status:** 🔴 confirmed
- **Area:** circle-homepages / graphql + react hooks
- **Found:** 2026-06-01 (manual read of `CirclesJWTClient.tsx`)

## Symptom
The effect that builds the JWT/websocket Apollo client closes over several values it doesn't list as dependencies, builds its own `customFetch` that reads auth differently than the effect's own guards, and casts the subscription link to `any`. The result is a client that can be built with a stale view of auth state and whose link types are unchecked.

## Evidence
File: `src/components/Graphql/CirclesJWTClient.tsx`
- `:67-106` — the build effect lists deps `[apiUrl, jwt, magicKey, isMounted]` but uses `logger`, `clientData` (via `headerMiddleware`), `onOpenCallback/onCloseCallback/onErrorCallback`, and `customFetch` — all recreated each render and none in the dep array (ESLint exhaustive-deps would flag these; the in-file comment at `:71` "Im not sure how i feel about this" acknowledges the smell).
- `:54-65` — `customFetch` reads the token via `getJWT()` (cui local storage) and `magicKey` from the store, while the *effect* keys off the store's `jwt`. These two sources can disagree: the client is created based on store `jwt`, but each request's URL is derived from `getJWT()` at fetch time — a token cleared in storage but still in the store (or vice-versa) produces a mismatched request.
- `:94` — `ApolloLink.split(sortSendViaWebSocket, createAbsintheSocket as any, ...)` — the websocket link is cast to `any`, defeating type checking on the subscription transport.
- `:55` — `customFetch = (uri: any, options: any)` — both params typed `any`.
- `:59` / `:62` — JWT and `quick_join` are concatenated into the URL unencoded (`?jwt=${jwt}` / `?quick_join=${magicKey}`).

## Mechanism
A `useEffect` only re-runs on listed deps; functions captured from render are frozen at the deps' last value. Because the client is created once per `[apiUrl, jwt, magicKey, isMounted]` change but `customFetch`/`clientData`/`logger` are captured by reference, later changes to those aren't reflected, and the dual auth source (`getJWT()` vs store `jwt`) can desync.

## Blast radius
The primary authenticated data path for the whole dashboard (every JWT/quick_join query, mutation, and subscription routes through this client). Desync surfaces as 401s or requests sent with the wrong identity; the `as any` hides real link-type regressions.

## Proposed fix
- Move `customFetch`/`headerMiddleware`/callbacks into `useCallback` and include in deps, or build them inside the effect so deps are honest.
- Pick a single source of truth for the token (store `jwt` *or* `getJWT()`, not both) and key the effect + fetch on the same value.
- Type the Absinthe link instead of `as any`; type `customFetch` params.
- `encodeURIComponent` the jwt/quick_join params.

## Effort / risk
Medium. Touches the core auth client; needs testing across jwt and quick_join paths plus subscriptions.
