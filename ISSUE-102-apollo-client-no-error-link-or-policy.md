# ISSUE-102: Three Apollo client factories are near-duplicates with no error link, no `errorPolicy`, and unencoded auth params in the URL

- **Severity:** S2
- **Status:** 🔴 confirmed
- **Area:** circle-homepages / graphql (Apollo multi-client)
- **Found:** 2026-06-01 (manual read of `utils/apolloClient/*`)

## Symptom
Three of the four Apollo clients (`anon`, `login`, `forum`) are copy-pasted with identical config and none install an error link (`onError` / `ErrorLink`) or set a default `errorPolicy`. GraphQL/network errors therefore surface only at each individual `useQuery`/`useMutation` call site (and most call sites don't handle them — see ISSUE-103). The forum client additionally interpolates the auth `forumId`/`myfKey` straight into the query string with no encoding.

## Evidence
- `src/utils/apolloClient/anonClient.ts:14-22` — `new ApolloClient({ link, cache, ssrMode: true, devtools, queryDeduplication })`, no error handling.
- `src/utils/apolloClient/loginClient.ts:12-20` — byte-for-byte the same shape.
- `src/utils/apolloClient/forumClient.ts:12-20` — same again. The factory comment is even wrong (copied from loginClient): `/**Creates a basic apollo client keyed to /graphql/login for acquiring jwts*/` but it builds the `?forum_id=...&myf_key=...` URL.
- `src/utils/apolloClient/forumClient.ts:6` — `` `${protocol}://${apiUrl}/graphql?forum_id=${forumId}&myf_key=${myfKey}` `` — `forumId`/`myfKey` are not `encodeURIComponent`'d, so a key containing `&`, `=`, `#`, or `+` corrupts the query string / auth.
- The JWT client (`src/components/Graphql/CirclesJWTClient.tsx:96-104`) is the only one built inline with a split link, and it too has no error link / `errorPolicy`.
- Repo-wide there are only 3 `errorPolicy` usages across ~40 `useQuery` + ~29 `useMutation` (per MAP-circle-homepages.md line 38), so the default `errorPolicy: "none"` is in force almost everywhere: any GraphQL `errors` entry discards `data` and rejects the promise.

## Mechanism
Apollo's default `errorPolicy` is `"none"`: a partial response with a non-null `errors` array throws away `data` and surfaces as a thrown/rejected error. With no error `ApolloLink` to centralize logging, every consumer must independently catch and route errors to the Logger/Honeybadger; in practice almost none do.

## Blast radius
All four auth contexts. Any backend that returns partial data + errors (common with Absinthe) yields blank UI instead of degraded UI. The forum-client URL-encoding bug can intermittently break forum auth for keys with reserved characters.

## Proposed fix
1. Extract one `createBaseClient(uri, { ssrMode })` factory and have all three thin wrappers call it (kills the duplication + the wrong comment).
2. Add a shared `onError` link that routes `graphQLErrors`/`networkError` to `Logger.error` (→ Honeybadger).
3. Decide a default `defaultOptions.watchQuery/query.errorPolicy` ("all" for read paths that should degrade gracefully).
4. `encodeURIComponent(forumId)` / `encodeURIComponent(myfKey)` in `forumClient.ts`.

## Effort / risk
Small-medium. Risk: switching `errorPolicy` to `"all"` changes which call sites now receive `data` alongside `error`; audit the ~40 query sites for code that assumes "error ⇒ no data".
