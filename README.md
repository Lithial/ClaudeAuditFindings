# Audit Findings

A running collection of problems discovered during codebase exploration (graphify-driven
architecture audit of `apps/circle-spaces`, started 2026-06-01; `fallow` static-analysis pass added
the 4xx series 2026-06-07). Mostly discovery + triage; a handful are now fixed (see
re-verification below). Each entry is evidence-backed and ready to be triaged into a real ticket.

## Status legend
- 🔴 **confirmed** — verified against source/runtime, mechanism understood
- 🟡 **suspected** — plausible, needs verification before action
- 🔵 **investigate** — a lead worth scoping, not yet examined
- 🟢 **partially resolved** — part fixed in passing; body records what's done vs outstanding
- ✅ **fixed** — re-verified resolved in current source

## Re-verification (2026-06-10)
All 38 findings were re-checked against current `staging` using freshly-rebuilt graphify graphs +
`fallow`. Status changes:
- **001 → ✅ fixed** — the cited `useEnvStore`/`useLayoutControlsStore` selectors now use `useShallow`.
- **002 → 🟢 partially resolved** — circle-spaces adopted **283 `useShallow`** wraps (was 0); ~4 unguarded
  object-literal selectors remain (e.g. `useSetCircleAssignedMembers.tsx`). NB the per-app sweep did **not**
  reach 101/201/301 — those are still 0 `useShallow`.
- **009 → ✅ fixed** — the `[...map.values()].forEach` fix merged to staging.
- **012 → 🔴 confirmed** (was 🔵 investigate) — the "PrePush" **ruleset** requires the 4 build checks on
  `staging`+default, and `on-pull-request.yml` (sole emitter) has `paths-ignore` → docs-only PRs deadlock.

The **4 S1 bugs are all still live** and were fixed on branch **`fix/audit-s1-bugs`** (commit pending merge):
**007** (`agendaClose` wrong result field), **008** (`find() !== null` always-true handraise),
**106** (unguarded `JSON.parse(extraFields)` forum crash), **202** (my-circles false-success + `allPeople[0]` crash).
Everything else re-verified **still valid / unchanged** (205, 302 partially resolved; 207, 208 product/needs-human; 405 backlog).

## Severity
- **S1** correctness bug / data loss / crash
- **S2** performance or UX degradation affecting many users/components
- **S3** maintainability / latent footgun / cleanup

## Index

`✓` in the Title = independently re-verified in source by the coordinator (not just agent-reported).

### circle-spaces (ISSUE-0xx)
| ID | Title | Severity | Status | Area |
|----|-------|----------|--------|------|
| [001](ISSUE-001-uselogger-rerender-multiplier.md) | `useLogger` re-render multiplier via unguarded Zustand selectors ✓ | S2 | ✅ fixed | state |
| [002](ISSUE-002-createwithequalityfn-without-shallow.md) | `createWithEqualityFn` used repo-wide without a `shallow` comparator (28 stores, 432 selectors) ✓ | S2 | 🟢 partially resolved | state |
| [003](ISSUE-003-ts-expect-error-suppressions.md) | `@ts-expect-error` suppressions hide GraphQL-shape (latent crash) + null-safety risks ✓ | S3 | 🟡 suspected | graphql |
| [004](ISSUE-004-unstable-usestorage-getitem-effect-churn.md) | Unmemoized `useStorage` getters churn `clientData` → Apollo effect re-fires every render | S2 | 🔴 confirmed | state/apollo |
| [005](ISSUE-005-agendastart-stale-closure-mount-effect.md) | `useAgendaStartHandler` auto-start mount effect captures stale session/lateBy (stale closure) | S2 | 🔴 confirmed | agenda |
| [006](ISSUE-006-agendastartmenu-import-cycle.md) | AgendaStartMenu 3-file import cycle (one stray type import; one-line fix) | S3 | 🔴 confirmed | agenda |
| [007](ISSUE-007-agendaclose-wrong-result-field-crash.md) | `agendaClose` error path reads `result.circleSetAgenda.messages` → TypeError when close fails ✓ — _fix on `fix/audit-s1-bugs`_ | S1 | 🔴 confirmed | agenda/graphql |
| [008](ISSUE-008-handraise-find-vs-null-always-true.md) | `find(...) !== null` is always true → local hand-raise flag can never clear ✓ — _fix on `fix/audit-s1-bugs`_ | S1 | 🔴 confirmed | state |
| [009](ISSUE-009-setspotlit-iterator-foreach.md) | `setSpotlit` uses `MapIterator.forEach` (iterator-helpers) — may throw on older runtimes ✓ | S2 | ✅ fixed | state |
| [010](ISSUE-010-layout-duplication-spaces.md) | `layout.ts` & `layoutMobile.ts` are near-duplicate forks (96 shared symbols, ~1,270 lines) ✓ | S3 | 🔴 confirmed | layout |
| [013](ISSUE-013-state-any-masked-type-errors.md) | `(state: any)` selector casts masked 18 real type errors across 13 files (several likely S1 crashes) ✓ | S2 | 🟡 suspected | state |
| [014](ISSUE-014-presence-predicate-and-or-split.md) | "Is user connected?" decided per-consumer (AND vs OR) — no shared predicate (4 AND + 2 OR sites) ✓ | S3 | 🔴 confirmed | state/presence |
| [015](ISSUE-015-usermap-lifecycle-edge-cases.md) | User-map connection-lifecycle edge cases — pre-greenroom phantoms unpruned, useUserList self-dep, addUser undefined-overwrite ✓ | S3 | 🔴 confirmed | state/presence |

### Cross-app (ISSUE-01x shared)
| ID | Title | Severity | Status | Area |
|----|-------|----------|--------|------|
| [011](ISSUE-011-unguarded-edges-shape-crossapp.md) | Unguarded `.edges.<method>` GraphQL shape assumptions — ~9 crash sites across all 3 apps ✓ | S2 | 🔴 confirmed | graphql (all apps) |
| [012](ISSUE-012-ci-paths-ignore-vs-required-checks.md) | on-pull-request.yml `paths-ignore` hangs docs-only PRs — "PrePush" ruleset requires the 4 checks (confirmed via API) ✓ | S3 | 🔴 confirmed | CI |

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
| [106](ISSUE-106-extractforumsdata-unguarded-json-parse.md) | Unguarded `JSON.parse(extraFields)` in a `.map` → one bad record crashes the forum view ✓ — _fix on `fix/audit-s1-bugs`_ | S1 | 🔴 confirmed | forum |
| [107](ISSUE-107-usejwt-storage-listener-leak.md) | `useJWT` add/remove `storage` listener with different arrow instances → listener never removed ✓ | S3 | 🔴 confirmed | auth |
| [108](ISSUE-108-client-metrics-browser-version-bug.md) | `useClientMetricsData` reads browser version from `os.version` → wrong version on every metric | S3 | 🔴 confirmed | metrics |

### my-circles (ISSUE-2xx)
| ID | Title | Severity | Status | Area |
|----|-------|----------|--------|------|
| [201](ISSUE-201-mycircles-zustand-shallow.md) | Zustand `shallow` footgun (5 stores, 43 selectors, 0 shallow); existing re-render-loop workaround | S2 | 🔴 confirmed | state |
| [202](ISSUE-202-mycircles-mutation-success-not-checked.md) | Circle/member mutations toast success without checking `successful`; `allPeople[0].id` crash ✓ — _fix on `fix/audit-s1-bugs`_ | S1 | 🔴 confirmed | graphql |
| [203](ISSUE-203-mycircles-login-mutation-no-onerror.md) | Login mutation has no `onError`/`.catch` → Sign-in silently no-ops on transport failure | S2 | 🔴 confirmed | graphql |
| [204](ISSUE-204-mycircles-login-store-overloaded.md) | `useLoginStore` overloaded (auth + conn params + org selection + transient flags) | S3 | 🔴 confirmed | state |
| [205](ISSUE-205-mycircles-send-session-stub-shipped.md) | `SendSessionDetailsModal` Send button only `console.log`s a TODO — shipped dead feature ✓ — _stub fixed; residual fire-and-forget folds into 202/203_ | S3 | 🟢 partially resolved | modals |
| [206](ISSUE-206-mycircles-dead-i18n-keys.md) | Dead / unaudited i18n keys (`shared.close` confirmed unused; naive scan unreliable — needs proper audit) ✓ | S3 | 🟡 suspected | localization |
| [207](ISSUE-207-mycircles-send-session-disclaimer-accuracy.md) | `SendSessionDetailsModal` calendar disclaimer copy needs verification against actual `circleSendInviteToMeetingEmail` behaviour ✓ | S3 | 🔵 investigate | content |
| [208](ISSUE-208-mycircles-modal-close-loses-form-progress.md) | Modal Cancel/close discards in-progress form input with no confirmation (PR #931 c9) — product decision ✓ | S3 | 🔵 investigate | modals/UX |

### Dependency & structure hygiene (fallow-surfaced, ISSUE-4xx)
Surfaced by `fallow` (dead-code / dupes / health / security), 2026-06-07. Tool config + full
per-command triage tables live in [`docs/fallow-rollout-decisions.md`](../docs/fallow-rollout-decisions.md).
| ID | Title | Severity | Status | Area |
|----|-------|----------|--------|------|
| [401](ISSUE-401-unlisted-dependencies.md) | 29 dependencies imported but undeclared (rely on Yarn hoisting) | S2 | 🔴 confirmed | deps (all) |
| [402](ISSUE-402-unused-misplaced-dependencies.md) | 27 declared production dependencies unused or misplaced | S3 | 🟡 suspected | deps (all) |
| [403](ISSUE-403-cross-app-utility-duplication.md) | Cross-app utility duplication + dead `agendaUtilities` exports (×3 apps) | S3 | 🔴 confirmed | dedupe (all) |
| [404](ISSUE-404-complexity-hotspots.md) | Complexity hotspots — `useNotesEvents` (CRAP 3080) + top critical fns | S2 | 🔴 confirmed | complexity |
| [405](ISSUE-405-security-candidates-backlog.md) | 135 fallow `security` candidates to triage (unverified) | S3 | 🔵 investigate | security |
| [406](ISSUE-406-storybook-vrt-coverage-gap.md) | Storybook/VRT coverage gap — harness wired on `ccc` only; ~360 story-worthy components unstoried | S3 | 🔵 investigate | testing (all) |

## Maps & graphs
- [MAP-circle-homepages.md](MAP-circle-homepages.md) — architecture overview (routes, stores, Apollo clients)
- [graphs/](graphs/) — committed snapshots of all 4 graphify graphs (`graph.json` + `wiki/` + `GRAPH_REPORT.md`; `graph.html`/`cache` excluded). See [graphs/README.md](graphs/README.md). Live/queryable copies remain in the monorepo's gitignored `graphify-out/` dirs.

## Cross-cutting themes
- **Zustand `shallow` never enabled** (002/101/201/301): three apps + breakouts-panel import `createWithEqualityFn` and never pass a comparator → ~43 stores, ~557 unguarded selectors repo-wide. **The fix already exists in-repo:** `new-asb` uses primitive selectors (`(s) => s.x`) and is clean — adopt that as the house standard, or add the `shallow` default per store. One sweep fixes everything.
- **Ash/Absinthe `{ successful, messages }` mishandled** (007/103/202/203): mutations either skip the `successful` check (false success) or read the wrong result object (crash) or omit `onError` (silent failure). A shared mutation-result helper would kill this class.
- **Relay `.edges` dereferenced without guards** (003/106/011): the read side of the GraphQL contract is assumed non-null across all three apps (~9 live crash sites + suppressed-type instances). A schema-generated-types + `edgesOf()` helper would kill this class.
- **`useLogger` is the #1 god node in every app** and rides the store-coupling bug along with it (001/101).
- **Cross-app utility copy-paste, no shared `@circles/utils`** (010/403/404, ties 004/108): `graphql.ts`, `useStorage`, `useClientMetricsData`, `noteSort`, `agendaUtilities`, layout math each exist as 3 drifting copies. `useNotesEvents` is duplicated *and* the #1 complexity hotspot. A shared utils package + dedupe kills a whole maintenance class.
- **Implicit dependency graph** (401/402): 29 packages imported but undeclared (work only via Yarn hoisting) and 27 declared-but-unused — the dependency manifests don't match actual imports, which is also what inflates the `fallow health` F grade.
- **No VRT regression net for most of the UI** (406, gates 302): the `@repo/testing` snapshot harness is wired on `packages/ccc` only; ~360 story-worthy components across the monorepo have no story, so visual regressions ship unseen. This is also why the runtime-value half of 302 is stuck — it's VRT-gated with no coverage to catch breakage. Rolling the cheap `ccc`→`cui` wiring outward + backfilling design-system stories first kills the class.

## How entries are created
1. Found during exploration → write `ISSUE-NNN-slug.md` from the template below.
2. Pick `NNN` from the per-area range, taking the next free number in that range:
   - `0xx` — circle-spaces · `01x` — cross-app (shared across ≥2 apps) · `1xx` — circle-homepages · `2xx` — my-circles · `3xx` — packages / shared libraries · `4xx` — cross-cutting / tooling-surfaced (fallow: deps, duplication, complexity, security).
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
