# ISSUE-010: `layout.ts` and `layoutMobile.ts` are near-duplicate forks (96 shared symbols)

- **Severity:** S3 (maintainability — every layout-math fix must be applied twice)
- **Status:** 🔴 confirmed (coordinator gap-sweep, 2026-06-01)
- **Area:** `apps/circle-spaces` / utils (video layout math)
- **Found:** 2026-06-01 (largest-files sweep + symbol diff)

## Symptom
`src/utils/layout.ts` (680 lines) and `src/utils/layoutMobile.ts` (593 lines) are the desktop and
mobile/phone implementations of the petal/hug video-layout geometry. They are not a shared core
with two thin wrappers — they are **forks of each other**.

## Evidence
Symbol-name diff of the two files (functions + consts):
- `layout.ts`: 106 symbols
- `layoutMobile.ts`: 97 symbols
- **Shared (defined in BOTH): 96** — i.e. all but one of `layoutMobile.ts`'s symbols also exist in
  `layout.ts`.

Shared symbols include the entire geometry engine:
`circle_hug_layout`, `group_hug_layout`, `maybe_hug_layout`, `radial_petal`, `radial_petal_group`,
`staggered_layout`, `uniform_staggered_layout`, `ortho_layout`, `calc_score`, `solve_for`,
`recalculate_landscape`, `recalculate_portrait`, `recalculate_ring`, `place_petal`, `place_elements`,
`cos30`, `sin30`, … (full list captured during the sweep).

## Mechanism
The mobile file was almost certainly copied from the desktop file and tweaked for phone constants
(`PhoneRinnerPad`, phone padding, landscape/portrait recompute). The two have since drifted
independently.

## Blast radius
Any bug fix or behavior change to the layout geometry (spotlight sizing, hug packing, petal
placement, scoring) must be made in **both** files or the desktop/mobile layouts silently diverge.
This is also a meaningful chunk of the two largest util files in the app (~1,270 lines combined).

## Proposed fix (do not implement yet)
Extract the shared geometry into one module parameterized by a device/profile config object
(constants like `Rinner`, paddings, column rules), and have `layout.ts` / `layoutMobile.ts` (or a
single `layout.ts`) call it with desktop vs phone params. Requires care: the files have *drifted*,
so first diff the function bodies to catalogue intentional vs accidental divergence before merging.

## Effort / risk
Medium-high. The math is dense and under-tested; a merge risks regressing one platform's layout.
Strongly pair with visual-regression coverage (the repo has VRT infra) before/after. Lower-risk
interim step: add a header comment to both files cross-referencing each other so fixes aren't
applied to only one.
