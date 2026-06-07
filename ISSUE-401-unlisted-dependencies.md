# ISSUE-401: 29 dependencies imported but undeclared (rely on Yarn hoisting)

- **Severity:** S2 (latent runtime breakage — works only while hoisting happens to provide the package)
- **Status:** 🔴 confirmed (fallow `dead-code`, 2026-06-07)
- **Area:** all apps + packages / dependency hygiene
- **Found:** 2026-06-07 (fallow `unlisted_dependencies`)

## Symptom
29 packages are `import`ed in a workspace whose own `package.json` does **not** declare them. They
resolve today only because Yarn hoists them to the root `node_modules` from another workspace that
*does* declare them. If that other workspace drops the dep, or hoisting changes, these imports break
at runtime with no compile-time warning.

## Evidence
`fallow dead-code --format json --quiet` → `unlisted_dependencies` (29). Split by importer:

**Production code (22)** — the real risk:
`@absinthe/socket`, `@absinthe/socket-apollo-link` (my-circles `CirclesJWTClient.tsx`),
`@codastic/react-positioning-portal` (new-asb), `@graphql-typed-document-node/core` (circle-spaces),
`@react-hook/resize-observer` (circle-homepages `useTargetSize.tsx`), `@wry/context`, `classnames`,
`dotenv`, `express`, `framer-motion`, `immer`, `js-cookie`, `phoenix`, `react`, `react-datepicker`,
`react-dom`, `react-google-recaptcha`, `react-tiny-popover`, `react-uuid`, `ua-parser-js`,
`use-debounce`, `vite-express`.

**Test-only (4)** — belong in `devDependencies` of the consuming package:
`@testing-library/react`, `@testing-library/user-event`, `axios`, `stacktrace-js`.

**Config/tooling (3)** — used by build/lint config, declare as devDeps:
`@eslint/eslintrc`, `@storybook/react-vite`, `glob`.

## Mechanism
Yarn 4 with `nodeLinker: node-modules` hoists shared deps to the root. A workspace can `import` a
package it never declared as long as *some* sibling pulls it in. The dependency graph is implicit
and fragile.

## Blast radius
Each prod entry is a potential runtime `Cannot find module` if hoisting shifts (dep bump, workspace
removed, `nodeLinker` change, or a fresh install on a different platform). `react`/`react-dom`
undeclared in a workspace that renders components is the sharpest example.

## Proposed fix (do not implement yet)
Add each package to the consuming workspace's `package.json` at the correct tier (prod imports →
`dependencies`, test/config → `devDependencies`). `react`/`react-dom` may be intentional peer setups
— confirm per-workspace before adding. Re-run `fallow dead-code --unlisted-deps` to confirm zero.

## Effort / risk
Low-medium, low risk (additive `package.json` edits + one `yarn install`). Mechanical but spread
across ~10 workspaces. Full list + import sites in `docs/fallow-rollout-decisions.md` (S1).
