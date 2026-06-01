# ISSUE-204: `useLoginStore` is overloaded — mixes auth, URL params, org selection, and transient UI state in one persisted store

- **Severity:** S3
- **Status:** confirmed
- **Area:** my-circles / state organization
- **Found:** 2026-06-01 (manual read of `useLoginStore.tsx` + call-site survey)

## Symptom
`useLoginStore` is the #2 god node (24 graph edges) and conflates at least four unrelated concerns in a single `persist`-wrapped store. It's named "login" but is the de-facto global junk drawer, which couples unrelated subsystems and amplifies the unguarded-selector re-render problem (ISSUE-201).

## Evidence
`src/components/GlobalStore/useLoginStore.tsx:6-41` — the `LoginStore` interface holds:
1. **Auth/identity:** `person` (id/name/roles), `jwt` (token/expires), `setPerson`, `setJWT`, `clearJWT`, role setters.
2. **URL / connection params:** `params: { apiUrl, magicKey, circleId, locale }`, `setApiUrl`, `setUrlDetails`, `setLocale`, `setup`.
3. **Org selection:** `organizationId`, `organizationName`, `setOrganization` — duplicating concern owned by `useOrgStore` (which separately holds `selectedOrg`). Org identity is split across two stores.
4. **Transient UI flag:** `loggingOut` + `clearLoggingOut` — ephemeral, yet lives in a `sessionStorage`-persisted store.

The store comment itself says "Only stuff that is used in multiple parts of the tree should be stored here" (line 5) — and `useCircleSelectStore` (line 4) carries the identical comment, showing the boundary between the two "global" stores was never defined.

Whole store is wrapped in `persist(..., { storage: sessionStorage })` (lines 44, 113-116), so the transient `loggingOut` flag and derived `organizationId` are persisted alongside the JWT.

Coupling evidence: `organizationId` is read from `useLoginStore` in `useGetOrgMetricsData.ts:24`, `AddNewCircleModal.tsx:24`, `AddMembersToCircleModal.tsx:31`, `BulkAddCirclesModal.tsx:20`, `MetricsPanel.tsx:51`, `AddNewCircleModal`, etc., while `selectedOrg` (the same selection) is read from `useOrgStore`. Any consumer needing "the current org" must know which of the two stores to ask.

## Mechanism
Organic growth: a "login" store accreted params, org selection, and UI flags. Because every write to any slice notifies all subscribers (and selectors aren't shallow-guarded — ISSUE-201), the overload directly worsens re-render fan-out: e.g. `setOrganization` re-renders every component selecting `jwt`/`person`/`params`.

## Blast radius
Maintainability + correctness-of-source-of-truth: org identity duplicated across `useLoginStore.organizationId` and `useOrgStore.selectedOrg` risks drift. Persisting `loggingOut` can leave a stale transient flag across a session-storage-restored tab. Re-render amplification touches the whole tree via the god-node status.

## Proposed fix
- Move `organizationId`/`organizationName` out of `useLoginStore`; make `useOrgStore.selectedOrg` the single source of truth (derive `organizationId` from it).
- Move `loggingOut`/`clearLoggingOut` to a non-persisted UI store (or local state in the logout flow); exclude it from `persist` via a `partialize`.
- Consider splitting auth (`person`/`jwt`) from connection `params` (`apiUrl`/`magicKey`/`circleId`/`locale`) — they have different lifecycles.
- Pair with ISSUE-201 (`useShallow`) so the slimmer stores also stop over-notifying.

## Effort / risk
Medium. Mechanical moves but touches ~15 call sites and the `persist` config; risk is missing a consumer of `organizationId`. Do after or alongside ISSUE-201 so re-render behavior can be validated once.
