# ISSUE-011: Unguarded `.edges.<method>` GraphQL shape assumptions (cross-app)

- **Severity:** S2 (latent runtime crashes on the data-display paths)
- **Status:** 🔴 confirmed (coordinator gap-sweep, 2026-06-01)
- **Area:** all three apps / GraphQL data mapping
- **Found:** 2026-06-01 (systematic `.edges` access sweep — the pass the mining agents couldn't run without Grep)

## Symptom
Across all three apps, code maps over Relay-style connection `edges` **without guarding that
`edges` exists** — `something.edges.map(...)` / `.forEach` / `.find` / `.some` with no `?.` and no
`?? []` fallback. If the server returns a node where the connection is `null`/absent, these throw
`Cannot read properties of undefined (reading 'map')` and take down the rendering path.

## Evidence
Sweep for `\.edges\.(map|forEach|filter|reduce|find|some|length)` **without** optional-chaining,
per app:

- **circle-spaces (3):**
  `src/features/AgendaFeatures/.../AgendaMenuHooks/Agenda/useAgendaButtonSharedFunctions.tsx:141,145,146`
  — chained `agendaFolder.agendas.edges.some(...)`, `agendaFolder.folders.edges.some(...)`,
  `agendaFolder.node.agendas.edges.some(...)` (triple-nested, any level can be absent).
- **circle-homepages (5, 1 is dummy):**
  `mfv/GuideHomeDashboard/MeetingTab/utils/useForumRetreatSubscription.ts:49`
  `mfv/GuideHomeDashboard/MeetingTab/hooks/.../useCreateCompleteRetreatDialog.ts:146,153`
  (plus one more); `components/.../KeyMetrics/dummyData.ts:128` is test fixture — ignore.
- **my-circles (2):**
  `src/queries/useGetOrgMetricsData.ts:11` — `data.organizationMetrics.sessions.edges.filter(...)`
  `src/queries/useOrganizations.ts:62` — `edge.node.members.edges.map(...)`

This is the same class as the already-filed ISSUE-003 (circle-spaces `@ts-expect-error` over
`agendas.edges`) and ISSUE-106 (circle-homepages `JSON.parse` inside an `edges.map`) — those are
the acute instances; this is the systematic enumeration.

## Mechanism
GraphQL connection fields are nullable. The TS types often type them as optional (hence the
ISSUE-003 suppressions), but the runtime code dereferences `.edges` directly. Optional chaining was
applied inconsistently — some call sites guard (`?.edges ?? []`), these don't.

## Blast radius
~9 real sites (excluding dummy data) on user-facing data paths: agenda folder navigation, forum
retreat subscriptions/dialogs, org & member metrics. Each is a single-record-crashes-the-view risk.
Severity depends on whether the server can actually return null for those specific connections —
worth confirming against the schema (introspection is available).

## Proposed fix (do not implement yet)
- Normalize to `(x.edges ?? []).map(...)` at every site, or a tiny `edgesOf(connection)` helper that
  returns `[]` for null/undefined.
- Pair with schema-generated types (also recommended in ISSUE-003) so nullability is enforced at
  compile time and the guards become provably necessary/sufficient.

## Effort / risk
Low. Mechanical per-site guards; ~9 edits across three apps. No behavior change for the happy path;
converts a crash into an empty list for the null path. Verify each site's "empty" rendering is
sensible (usually it already is).
