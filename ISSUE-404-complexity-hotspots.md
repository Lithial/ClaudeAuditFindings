# ISSUE-404: Complexity hotspots — `useNotesEvents` (CRAP 3080) + top critical functions

- **Severity:** S2 (high-churn, hard-to-test functions; bug-prone)
- **Status:** 🔴 confirmed (fallow `health`, 2026-06-07)
- **Area:** circle-spaces / circle-homepages / new-asb — events & agenda hooks
- **Found:** 2026-06-07 (fallow `health` — 152 critical, 184 high findings)

## Symptom
`fallow health` scores the repo **32.2 / F**, but the grade is penalty-inflated by the dep/circular
noise (see note below) — average cyclomatic is 1.8 and maintainability 92.4. The *real* signal is a
set of genuine refactor targets: **152 critical** + 184 high complexity functions, **99.7% in
production code** (only 2 of 654 in test/story files, so no skip pattern applies).

## Evidence
Top critical functions by cyclomatic / cognitive / **CRAP**:

| Function | cyc / cog / CRAP | Location |
|----------|------------------|----------|
| `useNotesEvents` (arrow) | 55 / 43 / **3080** | circle-spaces `features/EventManagers/useNotesEvents.ts:57` |
| `useNotesEvents` (arrow) | 48 / 35 / 546 | circle-homepages `NotesViewer/useNotesEvents.ts:44` |
| `addAgendaButtons` | 41 / 55 / 1722 | circle-spaces `AgendaHooks/useParseActiveAgendaPage.tsx:107` |
| `handleFormSubmit` | 36 / 17 / 316 | new-asb `useNoteMenus.ts:27` |
| `ForumCircle` | 33 / 23 / 1122 | circle-homepages `ForumDashboard/ForumCircle.tsx:9` |
| `parseSelectedMicrophone` | 30 / 19 / 930 | circle-spaces `DeviceHandling/deviceUtilities.ts:45` |

`useNotesEvents` is the standout: CRAP **3080** (cyclomatic × untested-ness) **and** it's duplicated
across circle-spaces + circle-homepages (see [ISSUE-403](ISSUE-403-cross-app-utility-duplication.md))
— the single highest-value target.

> **Don't be alarmed by the "F".** The score's penalties are dominated by `unused_deps` (21.1) and
> `circular_deps` (20.1) — the noise-heavy categories tracked in ISSUE-401/402 and below. Fixing
> deps + dedupe raises the grade without touching most code.

## Mechanism
Event-manager and agenda-parse hooks accreted branching over time (every note/agenda state path
added an `if`). High CRAP = high complexity × low test coverage, so they're both risky to change
and currently unguarded.

## Blast radius
These are core hot-path hooks (notes, agenda, device selection). High cyclomatic + low coverage =
the most likely place for a regression to hide.

## Proposed fix (do not implement yet)
Prioritize `useNotesEvents` (both copies — dedupe + decompose together with ISSUE-403). Use
`fallow health --complexity-breakdown` (MCP `check_health` `complexity_breakdown:true`) to get the
per-decision-point contributions and target the heaviest branches. Add tests before refactoring
(CRAP drops fastest from coverage, not just decomposition).

## Effort / risk
Medium-high per function; these are dense and under-tested. Treat as an ongoing backlog, not a
single PR. Could later gate new code via `health.maxCrap` once the top offenders are tamed.
