# ISSUE-302: Consumers deep-import `@circles/ccc/dist/...` instead of the package public API

- **Severity:** S3
- **Status:** ✅ fixed (re-verified 2026-07-03) — the outstanding runtime-value imports (`useControlDatePickerDialog`, `TalkTimeTable`, `BreakoutSessionPanel`, `FacilitatorSurveysTable`, `ParticipantSurveysTable`, `ListSelectionItem`) have all been repointed to the public `@circles/ccc` entry; `ListSelectionItem` was added to the `PopoverMenu` barrel. No remaining deep imports. (orig: 🔴 confirmed, type-half already fixed at filing)
- **Area:** packages/ccc (public API) + my-circles, circle-spaces (consumers)
- **Found:** 2026-06-01 (manual read during a pre-merge diff review; flagged by an existing `// TODO` in `useGetOrgMetricsData.ts`)

## Symptom
App code reaches *through* `@circles/ccc`, past its declared public API, and imports symbols by deep path from the package's compiled build output (`@circles/ccc/dist/components/.../X`). This couples the apps to ccc's internal `dist/` folder layout and to build order (the import only resolves after ccc has been built).

## Evidence
The package only exposes two doors (`packages/ccc/package.json`):

```json
"exports": {
  ".":        { "import": "./dist/index.js", "types": "./dist/index.d.ts" },
  "./dist/*": "./dist/*"
}
```

`.` is the curated front door; `./dist/*` is a wildcard escape hatch exposing the whole build tree. Source files using the escape hatch (10 import lines across 9 files):

**Type-only (RESOLVED — see "Status of fix"):**
- `apps/my-circles/src/queries/useGetOrgMetricsData.ts` — `OrganizationMetricsRaw`
- `apps/my-circles/src/components/MetricsPanel/SubSections/MetricsHeaders.tsx` — `ActiveInputOptions`
- `apps/my-circles/src/components/MetricsPanel/SubSections/CircleLevelDatePicker.tsx` — `ActiveInputOptions`
- `apps/my-circles/src/components/MetricsPanel/SubSections/BaseMetricsPanel.tsx` — `CirclesMetricsRawData`, `CirclesMetricsMembersRawData`
- `apps/my-circles/src/components/MetricsPanel/SubSections/CircleMetricsEmptyState.tsx` — `CirclesMetricsMembersRawData`
- `apps/my-circles/src/components/MetricsPanel/SubSections/AttendanceMetricsPanel.tsx` — `CirclesMetricsRawData`, `CirclesMetricsMembersRawData`
- `apps/my-circles/src/components/MetricsPanel/SessionMetricsDetail.tsx` — `TalkTimeEntry`, `ParticipantSurveyEntry`, `FacilitatorSurveyEntry`
- `apps/circle-spaces/src/features/ParticipantAwareNoteTaking/PantsContextMenu.tsx` — `MenuItem`

**Runtime values (OUTSTANDING — this spec's remaining work):**
- `apps/my-circles/src/components/TabbedDisplay/TabPanels/MetricsPanel.tsx:9` — `useControlDatePickerDialog` (hook)
- `apps/my-circles/src/components/MetricsPanel/SessionMetricsDetail.tsx:4-6` — `TalkTimeTable`, `BreakoutSessionPanel`, `FacilitatorSurveysTable`, `ParticipantSurveysTable` (components)
- `apps/circle-spaces/src/features/ParticipantAwareNoteTaking/PantsContextMenu.tsx:5` — `ListSelectionItem` (component)

## Mechanism
`packages/ccc/src/components/index.tsx` re-exports the MetricsTables and Calendar barrels with **value-only named lists** — e.g. `export { BaseMetricsTable, ... } from "./MetricsTables"`. A named re-export does **not** carry sibling `export type` declarations from the target barrel (only `export * from` or an explicit `export type {…}` would). So even types that *were* exported from `MetricsTables/index.ts` (`TalkTimeEntry` etc.) never reached `@circles/ccc`, and the apps were pushed to the `./dist/*` escape hatch to get them. Same gap for the runtime values that simply aren't listed in the barrel (e.g. `ListSelectionItem`).

## Blast radius
9 source files across 2 apps. Low runtime risk today (mostly type imports, now fixed), but a latent maintainability footgun: any internal reorg of ccc's `dist/` tree (folder move/rename) silently breaks consumers even though the public API is unchanged — the worst kind of break, because nothing in the contract signalled it was allowed.

## Proposed fix
Two-part, already applied for the type half:
1. **Promote symbols into the ccc public API** (`src/components/index.tsx` + the relevant sub-barrels), then `yarn build` so `dist/index.d.ts` carries them.
2. **Repoint consumers** to `import … from "@circles/ccc"` (use `import type` for types).

Remaining (runtime values):
- `useControlDatePickerDialog`, `TalkTimeTable`, `BreakoutSessionPanel`, `FacilitatorSurveysTable`, `ParticipantSurveysTable` are **already public** via `@circles/ccc` — just repoint the imports.
- `ListSelectionItem` is **not** exported yet — add it to the `PopoverMenu` barrel + `components/index.tsx`, rebuild ccc, then repoint.

Longer term: consider dropping the `"./dist/*"` wildcard from `exports` once nothing depends on it, so the escape hatch can't be reintroduced.

## Effort / risk
- Type half: **done** — `import type` is compile-erased, zero runtime/bundle impact; my-circles `tsc --noEmit` clean (no ccc errors).
- Runtime half: small code change, but it alters the module graph (chunk boundaries, what `vite-plugin-lib-inject-css` emits). **VRT-gated**: rebuild ccc and run `yarn test:visual` for `@circles/ccc` + affected apps before merging, per the repo's CSS-tree-shaking findings. Risk is a CSS-ordering/bundling regression, not a logic bug.
