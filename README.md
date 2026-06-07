# Audit Findings

A running collection of problems discovered during codebase exploration (graphify-driven
architecture audit of `apps/circle-spaces`, started 2026-06-01). **Discovery only** — nothing
here is fixed yet. Each entry is evidence-backed and ready to be triaged into a real ticket later.

## Status legend
- 🔴 **confirmed** — verified against source/runtime, mechanism understood
- 🟡 **suspected** — plausible, needs verification before action
- 🔵 **investigate** — a lead worth scoping, not yet examined
- 🟢 **partially resolved** — part fixed in passing; body records what's done vs outstanding

## Severity
- **S1** correctness bug / data loss / crash
- **S2** performance or UX degradation affecting many users/components
- **S3** maintainability / latent footgun / cleanup

## Index

`✓` in the Title = independently re-verified in source by the coordinator (not just agent-reported).

### circle-spaces (ISSUE-0xx)
| ID | Title | Severity | Status | Area |
|----|-------|----------|--------|------|
| [001](ISSUE-001-uselogger-rerender-multiplier.md) | `useLogger` re-render multiplier via unguarded Zustand selectors ✓ | S2 | 🔴 confirmed | state |
| [002](ISSUE-002-createwithequalityfn-without-shallow.md) | `createWithEqualityFn` used repo-wide without a `shallow` comparator (28 stores, 432 selectors) ✓ | S2 | 🔴 confirmed | state |
| [003](ISSUE-003-ts-expect-error-suppressions.md) | `@ts-expect-error` suppressions hide GraphQL-shape (latent crash) + null-safety risks ✓ | S3 | 🟡 suspected | graphql |
| [004](ISSUE-004-unstable-usestorage-getitem-effect-churn.md) | Unmemoized `useStorage` getters churn `clientData` → Apollo effect re-fires every render | S2 | 🔴 confirmed | state/apollo |
| [005](ISSUE-005-agendastart-stale-closure-mount-effect.md) | `useAgendaStartHandler` auto-start mount effect captures stale session/lateBy (stale closure) | S2 | 🔴 confirmed | agenda |
| [006](ISSUE-006-agendastartmenu-import-cycle.md) | AgendaStartMenu 3-file import cycle (one stray type import; one-line fix) | S3 | 🔴 confirmed | agenda |
| [007](ISSUE-007-agendaclose-wrong-result-field-crash.md) | `agendaClose` error path reads `result.circleSetAgenda.messages` → TypeError when close fails ✓ | S1 | 🔴 confirmed | agenda/graphql |
| [008](ISSUE-008-handraise-find-vs-null-always-true.md) | `find(...) !== null` is always true → local hand-raise flag can never clear ✓ | S1 | 🔴 confirmed | state |
| [009](ISSUE-009-setspotlit-iterator-foreach.md) | `setSpotlit` uses `MapIterator.forEach` (iterator-helpers) — may throw on older runtimes | S2 | 🔵 investigate | state |
| [010](ISSUE-010-layout-duplication-spaces.md) | `layout.ts` & `layoutMobile.ts` are near-duplicate forks (96 shared symbols, ~1,270 lines) ✓ | S3 | 🔴 confirmed | layout |
| [013](ISSUE-013-state-any-masked-type-errors.md) | `(state: any)` selector casts masked 18 real type errors across 13 files (several likely S1 crashes) ✓ | S2 | 🟡 suspected | state |

### Cross-app (ISSUE-01x shared)
| ID | Title | Severity | Status | Area |
|----|-------|----------|--------|------|
| [011](ISSUE-011-unguarded-edges-shape-crossapp.md) | Unguarded `.edges.<method>` GraphQL shape assumptions — ~9 crash sites across all 3 apps ✓ | S2 | 🔴 confirmed | graphql (all apps) |
| [012](ISSUE-012-ci-paths-ignore-vs-required-checks.md) | on-pull-request.yml `paths-ignore` can hang docs-only PRs if jobs are required checks — verify branch protection ✓ | S3 | 🔵 investigate | CI |

### packages / shared libraries (ISSUE-3xx)
| ID | Title | Severity | Status | Area |
|----|-------|----------|--------|------|
| [301](ISSUE-301-breakouts-panel-zustand-shallow.md) | breakouts-panel repeats the Zustand `shallow` footgun (3 stores, 23 selectors); single-field object selectors ✓ | S2 | 🔴 confirmed | breakouts-panel / state |
| [302](ISSUE-302-ccc-dist-deep-imports.md) | Consumers deep-import `@circles/ccc/dist/...` instead of the public API (10 lines / 9 files); type half fixed, runtime-value half outstanding (VRT-gated) ✓ | S3 | 🔴 confirmed | ccc / packaging |

_Clean (no issue): **new-asb** uses primitive selectors (`(s) => s.x`) — reference-stable, the correct house pattern. agenda-browser uses a per-instance factory/context store (not assessed)._

### circle-homepages (ISSUE-1xx)
| ID | Title | Severity | Status | Area |
|----|-------|----------|--------|------|
| [101](ISSUE-101-chp-zustand-shallow-and-logger.md) | Zustand `shallow` footgun + logger-store coupling (7 stores, 59 selectors) ✓ | S2 | 🔴 confirmed | state |
| [102](ISSUE-102-apollo-client-no-error-link-or-policy.md) | Anon/login/forum Apollo factories near-duplicate; no error link / `errorPolicy`; unencoded URL params | S2 | 🔴 confirmed | apollo |
| [103](ISSUE-103-mutation-onError-swallowed.md) | Login + 6 notes mutations have no `onError`/`.catch`; errors never reach Logger→Honeybadger | S2 | 🔴 confirmed | graphql |
| [104](ISSUE-104-apollo-client-rebuilt-every-render.md) | `CirclesAuthClient`/`CirclesForumClient` build a new ApolloClient+cache every render (not memoized) ✓ | S2 | 🔴 confirmed | apollo |
| [105](ISSUE-105-jwt-client-effect-stale-closure.md) | JWT client effect: missing deps / stale closure, dual token source can desync | S2 | 🔴 confirmed | apollo/auth |
| [106](ISSUE-106-extractforumsdata-unguarded-json-parse.md) | Unguarded `JSON.parse(extraFields)` in a `.map` → one bad record crashes the forum view ✓ | S1 | 🔴 confirmed | forum |
| [107](ISSUE-107-usejwt-storage-listener-leak.md) | `useJWT` add/remove `storage` listener with different arrow instances → listener never removed ✓ | S3 | 🔴 confirmed | auth |
| [108](ISSUE-108-client-metrics-browser-version-bug.md) | `useClientMetricsData` reads browser version from `os.version` → wrong version on every metric | S3 | 🔴 confirmed | metrics |

### my-circles (ISSUE-2xx)
| ID | Title | Severity | Status | Area |
|----|-------|----------|--------|------|
| [201](ISSUE-201-mycircles-zustand-shallow.md) | Zustand `shallow` footgun (5 stores, 43 selectors, 0 shallow); existing re-render-loop workaround | S2 | 🔴 confirmed | state |
| [202](ISSUE-202-mycircles-mutation-success-not-checked.md) | Circle/member mutations toast success without checking `successful`; `allPeople[0].id` crash ✓ | S1 | 🔴 confirmed | graphql |
| [203](ISSUE-203-mycircles-login-mutation-no-onerror.md) | Login mutation has no `onError`/`.catch` → Sign-in silently no-ops on transport failure | S2 | 🔴 confirmed | graphql |
| [204](ISSUE-204-mycircles-login-store-overloaded.md) | `useLoginStore` overloaded (auth + conn params + org selection + transient flags) | S3 | 🔴 confirmed | state |
| [205](ISSUE-205-mycircles-send-session-stub-shipped.md) | `SendSessionDetailsModal` Send button only `console.log`s a TODO — shipped dead feature ✓ — _stub fixed; residual fire-and-forget folds into 202/203_ | S3 | 🟢 partially resolved | modals |
| [206](ISSUE-206-mycircles-dead-i18n-keys.md) | Dead / unaudited i18n keys (`shared.close` confirmed unused; naive scan unreliable — needs proper audit) ✓ | S3 | 🟡 suspected | localization |
| [207](ISSUE-207-mycircles-send-session-disclaimer-accuracy.md) | `SendSessionDetailsModal` calendar disclaimer copy needs verification against actual `circleSendInviteToMeetingEmail` behaviour ✓ | S3 | 🔵 investigate | content |
| [208](ISSUE-208-mycircles-modal-close-loses-form-progress.md) | Modal Cancel/close discards in-progress form input with no confirmation (PR #931 c9) — product decision ✓ | S3 | 🔵 investigate | modals/UX |

## Maps & graphs
- [MAP-circle-homepages.md](MAP-circle-homepages.md) — architecture overview (routes, stores, Apollo clients)
- [graphs/](graphs/) — committed snapshots of all 4 graphify graphs (`graph.json` + `wiki/` + `GRAPH_REPORT.md`; `graph.html`/`cache` excluded). See [graphs/README.md](graphs/README.md). Live/queryable copies remain in the monorepo's gitignored `graphify-out/` dirs.

## Cross-cutting themes
- **Zustand `shallow` never enabled** (002/101/201/301): three apps + breakouts-panel import `createWithEqualityFn` and never pass a comparator → ~43 stores, ~557 unguarded selectors repo-wide. **The fix already exists in-repo:** `new-asb` uses primitive selectors (`(s) => s.x`) and is clean — adopt that as the house standard, or add the `shallow` default per store. One sweep fixes everything.
- **Ash/Absinthe `{ successful, messages }` mishandled** (007/103/202/203): mutations either skip the `successful` check (false success) or read the wrong result object (crash) or omit `onError` (silent failure). A shared mutation-result helper would kill this class.
- **Relay `.edges` dereferenced without guards** (003/106/011): the read side of the GraphQL contract is assumed non-null across all three apps (~9 live crash sites + suppressed-type instances). A schema-generated-types + `edgesOf()` helper would kill this class.
- **`useLogger` is the #1 god node in every app** and rides the store-coupling bug along with it (001/101).

## How entries are created
1. Found during exploration → write `ISSUE-NNN-slug.md` from the template below.
2. Pick `NNN` from the per-area range, taking the next free number in that range:
   - `0xx` — circle-spaces · `01x` — cross-app (shared across ≥2 apps) · `1xx` — circle-homepages · `2xx` — my-circles · `3xx` — packages / shared libraries.
3. Add a row to the matching section's index table. Append `✓` to the title only once you've **independently re-verified** the finding in source (not just agent-reported).
4. Do **not** fix yet — capture evidence so triage is cheap. (If a finding is partially fixed in passing, keep the entry and mark in the body what's done vs outstanding.)

## Issue template

```markdown
# ISSUE-NNN: <title>

- **Severity:** S1 | S2 | S3
- **Status:** confirmed | suspected | investigate
- **Area:** <app/package / subsystem>
- **Found:** <date> (<how — graphify query, manual read, etc.>)

## Symptom
<what's wrong, in one or two sentences>

## Evidence
<files, line refs, library internals, measurements — the expensive-to-rediscover part>

## Mechanism
<why it happens>

## Blast radius
<who/what is affected and how widely>

## Proposed fix
<options, with a recommendation; do not implement here>

## Effort / risk
<rough sizing and what could break>
```
