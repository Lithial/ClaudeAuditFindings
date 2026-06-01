# ISSUE-012: on-pull-request.yml `paths-ignore` can hang docs-only PRs on required checks

- **Severity:** S3
- **Status:** investigate (needs branch-protection visibility)
- **Area:** cross-app / CI (.github/workflows/on-pull-request.yml)
- **Found:** 2026-06-01 (PR #931 review, comment 17 — martin)

## Symptom
`.github/workflows/on-pull-request.yml` uses `paths-ignore` (`**/*.md`, `docs/**`, `.gitignore`, etc.) on `pull_request`. If any of its jobs — `build` (Build and Test), `build-room`, `build-chp`, `build-my-circles` — are configured as **required status checks** in branch protection, then a PR touching only ignored paths skips the workflow, so those required checks never report, and the PR sits forever "Expected — waiting for status to be reported" and cannot merge.

## Evidence
- Workflow `on.pull_request.paths-ignore` (lines 10-16) skips the entire workflow for docs-only changes.
- The four job names above are the only checks this workflow produces. If branch protection on `staging`/`main` requires any of them by name, the skip becomes a deadlock for docs-only PRs.
- Cannot confirm from the repo alone — branch-protection required-checks config lives in GitHub settings (not in the tree), and isn't accessible here.

## Mechanism
GitHub treats a required check that never runs as perpetually pending; `paths-ignore` makes the run never happen for matching PRs. Well-known GitHub Actions footgun.

## Proposed fix (after verifying branch protection)
- If these jobs **are** required: either (a) drop `paths-ignore` and instead short-circuit inside each job (e.g. a `changed-files` filter that exits 0 early), or (b) add a tiny always-runs companion job with the same required check name that succeeds on ignored paths (the standard "required check on skipped path" shim).
- If these jobs are **not** required: current config is fine — close as no-action.

## Effort / risk
Low once the branch-protection setting is known. The risk is doing nothing and discovering it only when a docs-only PR wedges. First step is purely informational: check Settings → Branches → required status checks for `staging`/`main`.
