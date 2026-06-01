# ISSUE-108: Browser version in client-metrics headers is derived from the OS version (wrong field) + console-only error swallowing in the Logger upload path

- **Severity:** S3
- **Status:** 🔴 confirmed
- **Area:** circle-homepages / logging & metrics
- **Found:** 2026-06-01 (manual read of `useClientMetricsData.ts`, `useLogger.tsx`)

## Symptom
Two distinct defects in the telemetry plumbing:
1. The `es.circl-browser_major_version` metrics header is computed from the *operating system* version, not the browser version — so every metrics/log event reports a wrong browser version.
2. The Logger's own upload failures are reported only via `console.warn`/`console.error`, never through `logger.error`, so they never reach Honeybadger.

## Evidence
File: `src/components/Logger/useClientMetricsData.ts`
- `:58` — `const browser = processVersions(result.os.version);` — should be `result.browser.version`. (`:59` correctly does `const os = processVersions(result.os.version);`.)
- `:74` — `"es.circl-browser_major_version": browser.major ?? "unknown"` — consumes the mis-derived value, so the field always carries the OS major version, never the browser's.

File: `src/components/Logger/useLogger.tsx` (the monitoring-gap half)
- `:47` — `console.error("logEndpoint not set on uploadMetricsEvent", ...)` instead of routing through the Logger.
- `:81-86` / `:137-144` — `.then(r => r.status != 200 && console.warn(...))` and `.catch(err => console.warn("Failed uploading log line.", err))` — upload failures are console-only.
- `:97` — same `console.error("logEndpoint not set on uploadLine", ...)`.
- For contrast, `Logger.ts:104-108` shows `error()` is the only path that calls `Honeybadger.notify`, confirming these console-only branches are invisible to monitoring. (These specific ones can't trivially recurse into `logger.error` since that would re-enter `uploadLine`, but they are a documented monitoring blind spot.)

## Mechanism
1. `UAParser().getResult()` exposes `.browser.version` and `.os.version` separately; the code copy-pasted the `os.version` line and forgot to change the source for the browser variable.
2. The upload code path deliberately avoids the Logger (to prevent recursion) but uses bare `console.*`, so failures of the telemetry system itself are undetectable in production.

## Blast radius
1. All metrics/log events from circle-homepages carry an incorrect browser-version dimension — any dashboard or alert segmenting by browser version is silently wrong.
2. If the log endpoint is misconfigured or the backend rejects uploads, the team gets no signal (the failures only print to the user's console).

## Proposed fix
1. `const browser = processVersions(result.browser.version);`.
2. For the upload-failure branches, emit a Honeybadger breadcrumb/notify directly (bypassing the recursive `uploadLine`) or surface a counter so telemetry outages are visible.

## Effort / risk
Tiny for (1); small for (2). Low risk.
