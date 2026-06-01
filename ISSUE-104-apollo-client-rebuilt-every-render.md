# ISSUE-104: Auth & Forum Apollo clients are rebuilt (with a fresh `InMemoryCache`) on every render

- **Severity:** S2
- **Status:** 🔴 confirmed
- **Area:** circle-homepages / graphql (Apollo multi-client)
- **Found:** 2026-06-01 (manual read of `components/Graphql/*`)

## Symptom
`CirclesAuthClient` and `CirclesForumClient` call their `create*Client(...)` factory directly in the render body — not in `useMemo`/`useRef`/`useState` — so every render of the provider constructs a brand-new `ApolloClient` and a brand-new `InMemoryCache`. The cache is wiped on every render, in-flight queries are orphaned, and all descendants see a new client identity (forcing re-subscription).

## Evidence
- `src/components/Graphql/CirclesAuthClient.tsx:15` — `const client = createLoginClient(apiUrl);` in the component body, then `<ApolloProvider client={client}>`.
- `src/components/Graphql/CirclesForumClient.tsx:22` — `const client = createForumClient(apiUrl, forumParams.forumId, forumParams.myfKey);` in the body. It also subscribes to `forumParams` via an unguarded object selector (`(state) => ({ forumParams: state.forumParams })`), so any GlobalStore change that produces a new `forumParams` reference re-renders and rebuilds the client (ties into ISSUE-101's `shallow` footgun).
- `src/components/Graphql/CirclesAnonClient.tsx:17` — same pattern (`createAnonClient(apiUrl, token)` in body); somewhat masked because it early-returns when there's no token.
- Contrast: `src/components/Graphql/CirclesJWTClient.tsx:96-106` *does* memoize the client into `useState` inside an effect keyed on `[apiUrl, jwt, magicKey, isMounted]` — proof the correct pattern exists in the same folder, just not applied to the other three.

## Mechanism
React re-renders providers freely. A non-memoized `new ApolloClient(...)` per render means the normalized cache never persists across renders, so `fetchPolicy: "cache-first"` reads always miss and refetch, queryDeduplication can't help across the boundary, and the provider thrashes its whole subtree.

## Blast radius
Login flow (`CirclesAuthClient`) and the entire forum dashboard surface (`CirclesForumClient`) — both wrap large subtrees. Manifests as redundant network traffic, lost cache, and subscription churn; worse under the `shallow`-less selector re-render storm from ISSUE-101.

## Proposed fix
Wrap each client in `useMemo(() => create*Client(...), [apiUrl, ...inputs])` (matching the JWT client's keying), or lift the client to a ref. Guard the `forumParams` selector with `useShallow`.

## Effort / risk
Small. Low risk; standard memoization.
