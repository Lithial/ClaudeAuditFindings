# ISSUE-003: `@ts-expect-error` suppressions hiding GraphQL-shape and null-safety risks

- **Severity:** S3 (maintainability + a few latent S2 runtime risks)
- **Status:** 🟡 suspected (cluster confirmed; individual runtime risks need per-site review)
- **Area:** `apps/circle-spaces` / GraphQL hooks, Chime wrappers, sidebar
- **Found:** 2026-06-01 (manual grep + spot reads)

## Symptom
21 `@ts-expect-error` suppressions across circle-spaces. They fall into two groups:
- **6 codemod migration debt** — `@ts-expect-error ts-migrate(2322) FIXME: Type Borked / borked`,
  auto-inserted during a TS migration and never resolved.
- **15 hand-written** — deliberate suppressions, several over GraphQL server-response shapes and
  one over a null-safety assertion. These are the ones that can hide real runtime bugs.

(For comparison: `@ts-ignore` = 0, `as any` = 10, and ~248 non-selector `: any` annotations —
type erosion is concentrated around the GraphQL/Apollo layer.)

## Evidence
**Latent runtime crash risk — GraphQL `edges` shape:**
`src/features/.../AgendaBrowserFloating/AgendaBrowserFloatingHooks/useFloatingBrowserProps.ts:375`
```ts
// @ts-expect-error agenda typing not matching server returned "edges" structure
const agendasInFolder = location?.agendas?.edges
    .map((edge: any) => (edge.node.__typename === "AgendaLink" ? edge.node.agenda : edge.node))
    .filter((agenda: any) => Boolean(agenda));
```
The optional chain stops at `location?.agendas?.edges` — but `.edges.map(...)` is **not**
guarded. If `edges` is `undefined`/`null` (which the *type* apparently allows, hence the
suppression), this throws `Cannot read properties of undefined (reading 'map')` at runtime. The
suppression masks exactly the case that would crash. Similar `edges`/link suppressions at
`useFloatingBrowserProps.ts:234` and `:651`.

**Null-safety assertion coupled to a runtime guard:**
`src/components/ChimeContextWrapper/ChimeContextWrapper.tsx:18`
```tsx
<ToggleablePanelWrapper panelEnabled={chimeLogger !== null}>
  ...
  {/*@ts-expect-error null check is made above with the ToggleablePanelWrapper. Logger will never be null at this point*/}
  <LoggerProvider logger={chimeLogger}>
```
The non-null guarantee lives in a sibling component's `panelEnabled` prop, invisible to TS. It's
*probably* correct today, but it's a type lie that breaks silently if `ToggleablePanelWrapper`'s
render semantics ever change (e.g. it renders children while disabled).

**Other notable hand-written suppressions:** chime SDK not typed (`ChimeContextWrapper.tsx:20`,
`MobileUtilitiesHandler.tsx:37`), chatlio untyped, experimental `setSinkId` on `AudioContext`
(`GreenroomSpeakerTestButton.tsx:63`), `CirclesVideoContainer.tsx:125` and `useUserList.tsx:111`
both literally commented `// TS doesn't like this and we should fix it`.

## Mechanism
`@ts-expect-error` fully disables type checking for the next line. Where it covers a real
type/runtime mismatch (server shape, nullability), the compiler can no longer warn if the code
or the data shape drifts — the class of bug TS exists to catch is opted out of, silently.

## Blast radius
- 6 migration-debt suppressions: pure cleanup, low risk.
- ~3 GraphQL `edges` suppressions: **latent runtime crash** if the server returns null/absent
  `edges` (agenda browser — a user-facing path).
- 1 null-safety suppression: fragile coupling, low current risk.
- Remainder (3rd-party untyped libs): legitimate, but should be narrowed to typed shims.

## Proposed fix (do not implement yet)
- **GraphQL shapes:** generate types from the schema (the repo has GraphQL introspection
  available) and add real guards (`(location?.agendas?.edges ?? []).map(...)`) instead of
  suppressing. This both removes the suppression and fixes the crash risk in one move.
- **Migration debt:** the 6 `ts-migrate FIXME` lines — fix the underlying type and delete the
  comment; they're explicitly flagged as temporary.
- **3rd-party untyped:** replace blanket suppressions with module augmentation / minimal `.d.ts`
  shims so only the genuinely-untyped surface is `any`.
- **Null-safety:** prefer an explicit `if (!chimeLogger) return null;` over the cross-component
  type lie.

## Effort / risk
- GraphQL guards: ~1–2 hrs, low risk, removes a real crash vector. Highest value.
- Migration debt: ~1 hr, trivial.
- The rest: opportunistic, low priority.
