# ISSUE-006: 3-file import cycle in AgendaStartMenu — metrics hook imports a type from the component instead of the extracted `.utils`

- **Severity:** S3
- **Status:** confirmed
- **Area:** circle-spaces / AgendaFeatures
- **Found:** 2026-06-01 (graph "Import Cycles" lead, confirmed by reading the three files)

## Symptom
`useAgendaStartMenuMetrics.ts` → `AgendaStartMenu.tsx` → `useAgendaStartHandler.ts` → `useAgendaStartMenuMetrics.ts` form a circular import. The `ParsedSession` type was already extracted to `AgendaStartMenu.utils`, but the metrics hook still pulls it through the component file, keeping the cycle alive.

## Evidence
Graph report (`graphify-out/GRAPH_REPORT.md`, "Import Cycles"):
> `useAgendaStartMenuMetrics.ts -> AgendaStartMenu.tsx -> useAgendaStartHandler.ts -> useAgendaStartMenuMetrics.ts`

`.../AgendaControlHooks/useAgendaStartMenuMetrics.ts:2` imports the type from the **component**:
```
2  import { ParsedSession } from "../AgendaStartMenu/AgendaStartMenu";
```

`.../AgendaStartMenu/AgendaStartMenu.tsx` imports the handler and merely re-exports the type:
```
17 import useAgendaStartHandler from "./hooks/useAgendaStartHandler";
19 export type { ParsedSession } from "./AgendaStartMenu.utils";
```

`.../AgendaStartMenu/hooks/useAgendaStartHandler.ts` imports the metrics hook and the type from `.utils` (the correct source):
```
8  import useAgendaStartMenuMetrics from "../../AgendaControlHooks/useAgendaStartMenuMetrics";
10 import type { ParsedSession } from "../AgendaStartMenu.utils";
```

So `useAgendaStartHandler` already imports `ParsedSession` from `.utils`; only `useAgendaStartMenuMetrics` still routes through the component, which is what closes the loop.

## Mechanism
The `ParsedSession` type lives in `AgendaStartMenu.utils` and is re-exported by the component for backwards compatibility. The metrics hook imports it from the component (a value module that imports the handler that imports the metrics hook), creating a value-level cycle even though the import is type-only intent.

## Blast radius
Maintainability / latent footgun. Cycles risk `undefined`-at-module-load ordering bugs (here mitigated because the cycle is type-only on one edge, but it is a value import path), confuse bundlers/tree-shaking, and make the module graph harder to reason about. Localised to the agenda-start feature.

## Proposed fix
Change `useAgendaStartMenuMetrics.ts:2` to import directly from the utils module:
`import type { ParsedSession } from "../AgendaStartMenu/AgendaStartMenu.utils";` and use `import type` so it is fully erased. This removes the metrics→component edge and breaks the cycle.

## Effort / risk
Trivial (one-line import change). Near-zero risk.
