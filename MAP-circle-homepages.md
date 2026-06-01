# MAP: apps/circle-homepages

Dashboard app (Next.js 14 App Router). Navigability aid for the audit, not exhaustive.

## Routes (App Router, `app/[locale]/`)
- `(chp)/` group — main dashboard surface:
  - `dashboard/` — primary guide/circle dashboard (`DashboardContainer`)
  - `login/` — login flow (`LoginContainer`)
  - `myforum/` — forum dashboard (`ForumDashboard`)
  - `token/` — transfer-token landing (decodes token, redirects)
  - `access_denied/`
- `(mfv)/` group — "multi-forum view" / newer guide-home surface (`src/mfv/`)
- `app/api/` — `githash`, `healthcheck` route handlers
- Root: `app/[locale]/error.tsx`, layout per group.

## State — Zustand stores (all `createWithEqualityFn`, none pass `shallow`)
| Store | File | Notes |
|-------|------|-------|
| `useGlobalStore` | `src/components/GlobalStore/useGlobalStore.tsx` | session context (jwt, magicKey, circleId, forumParams, person…); `persist` → `sessionStorage`; most-subscribed store |
| `useErrorAlertStore` | `src/components/GlobalStore/useErrorAlertStore.tsx` | notification/alert queue |
| `useNavStore` | `src/components/NavBar/useNavStore.tsx` | nav UI |
| `useRetreatStore` | `src/components/GlobalStore/useRetreatStore.ts` | |
| `useForumRetreatStore` | `src/components/GlobalStore/useForumRetreatStore.ts` | |
| `useTimezoneStore` | `src/components/GlobalStore/useTimezoneStore.ts` | |
| `useDevStore` | `src/components/DevPanel/useDevStore.ts` | dev panel |

7 stores total. 79 object-literal selectors (`useXxxStore((state) => ({...}))`) across 71 files; **0** use `shallow`/`useShallow`.

## Apollo / GraphQL layer
Four provider components in `src/components/Graphql/`, each wrapping a different auth context:
- `CirclesAnonClient.tsx` → `utils/apolloClient/anonClient.ts` (`?type=anonymous`, decode transfer token)
- `CirclesAuthClient.tsx` → `utils/apolloClient/loginClient.ts` (`/graphql/login`)
- `CirclesForumClient.tsx` → `utils/apolloClient/forumClient.ts` (`?forum_id=&myf_key=`)
- `CirclesJWTClient.tsx` → `utils/apolloClient/jwtClient.ts` (Phoenix/Absinthe WebSocket split link; JWT or quick_join)

The four `create*Client` factories are near-duplicates (same `InMemoryCache`, `ssrMode`, `devtools`, `queryDeduplication`). Auth/Forum providers build the client inline in render (not memoized). JWT provider builds it in an effect keyed on `[apiUrl, jwt, magicKey, isMounted]`.

Hooks: `useInitialize` (lazy decode token), `useJWT` (`storage` event sync), `useLogin` (`userAuthenticate` mutation). 40 `useQuery`, 29 `useMutation`, only 3 `errorPolicy` usages.

## Most-connected components / entry points
- `CirclesRouter` (`src/components/CirclesRouter/CirclesRouter.tsx`) — top-level router; reads token, calls `setup`, `redirect()`s in an effect.
- `DashboardContainer/` — largest feature tree (members, metrics, notes, session scheduler, forum planning).
- `mfv/GuideHomeDashboard/` — newer guide-home tree (meetings, retreats, member list, dialogs); deepest folder nesting.
- `Logger/useLogger.tsx` — used in almost every component; subscribes to 4 GlobalStore fields via an unguarded object selector.
- `NavBar/`, `Notifications/`, `Login/` — broadly consumed.

## Cross-cutting
- Localization: `react-intl` via `CirclesLocalization` (`src/components/CirclesLocalization/`), flat JSON dictionaries.
- Error monitoring: Honeybadger (`honeybadger.client/server.config.ts`), wired into `Logger.error()` only.
- Type erosion clusters: 23 `@ts-ignore`/`@ts-expect-error`, concentrated in `Login/*` (CUI input refs) and `Chatlio/*` (untyped global).
