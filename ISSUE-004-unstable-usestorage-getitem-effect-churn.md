# ISSUE-004: `useStorage` returns unstable `getItem`, destabilising `clientData` and firing the Apollo client-metadata effect every render

- **Severity:** S2
- **Status:** confirmed
- **Area:** circle-spaces / hooks + ApolloClient
- **Found:** 2026-06-01 (manual read, traced from `useClientMetricsData` → `useStorage` → `useCreateCirclesApolloConnection`)

## Symptom
`clientData` (the metrics/header builder used on every GraphQL request and by the logger) is wrapped in `useCallback` but its identity changes on **every render**, because one of its dependencies (`getItem`) is a brand-new function each render. Downstream, an Apollo `useEffect` keyed on `[clientData]` re-runs on every render of the provider.

## Evidence
`apps/circle-spaces/src/hooks/useStorage.tsx` defines `getItem`/`setItem`/`removeItem` as plain inline closures with no `useCallback`/`useMemo`, and returns a fresh object literal each call:
```
15  const getItem = (key: string, type?: StorageType): string => {
16      return isBrowser ? window[storageType(type)][key] : "";
17  };
...
44  return { getItem, setItem, removeItem };   // new functions every render
```

`apps/circle-spaces/src/hooks/GraphqlHooks/useClientMetricsData.tsx:56-79` memoises `clientData` with `getItem` in the dep array:
```
56  const clientData = useCallback((): Record<string, string> => { ... },
79  [clientTabSession, getItem]);   // getItem changes every render → clientData changes every render
```

`apps/circle-spaces/src/components/ApolloClient/useCreateCirclesApolloConnection.tsx:208-212`:
```
208 useEffect(() => {
209     if (!clientMetadata) {
210         setClientMetadata(clientData());
211     }
212 }, [clientData]);   // re-runs every render because clientData identity churns
```
The `if (!clientMetadata)` guard means the *work* only happens once, so this is not a correctness bug, but the effect comparison + closure allocation run on every render of the Apollo provider subtree, and any other consumer that puts `clientData` in a dep array (e.g. memoised request builders, the logger's `useClientMetricsData()` usage) is silently denied memoisation.

## Mechanism
`useStorage` is a "utility hook" that allocates new function identities on each call. `useCallback` only stabilises its output when *all* deps are stable; an unstable dep defeats it entirely. This propagates: unstable `getItem` → unstable `clientData` → unstable effect/memo deps in every consumer.

## Blast radius
`useStorage` and `useClientMetricsData` are foundational — `clientData()` is invoked in the Apollo header middleware, the WS `connectionParams`, and `useLogger` (a 167-edge god node). Any memoisation that lists `clientData` or `getItem` as a dep is dead. Bounded perf cost (object/closure churn, repeated effect comparisons) rather than a crash, but it is broad.

## Proposed fix
Wrap `getItem`/`setItem`/`removeItem` in `useCallback` (deps `[]` — they only touch `window`) inside `useStorage`, OR hoist them to module scope (they capture no React state; `isBrowser` can be computed inside each call). Either makes `clientData` genuinely stable. Recommended: hoist the three storage helpers out of the hook entirely (pure functions), then have `useStorage` return a stable reference.

## Effort / risk
Small. Risk: other code may rely (incorrectly) on getting a fresh closure; unlikely since these are pure. Verify no consumer mutates the returned object.
