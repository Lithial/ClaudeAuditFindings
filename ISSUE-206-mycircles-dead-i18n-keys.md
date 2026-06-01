# ISSUE-206: Dead / unaudited i18n keys in my-circles

- **Severity:** S3
- **Status:** confirmed (one key) / investigate (the rest)
- **Area:** my-circles / localization
- **Found:** 2026-06-01 (surfaced during the confirm-close dead-code cleanup; see [ISSUE-205] context)

## Symptom
At least one shared translation key ships in all three locale files but is referenced nowhere in source. A broader audit is likely warranted but a reliable count hasn't been produced yet.

## Evidence
- Confirmed dead: `shared.close` — present in `apps/my-circles/lang/{en,de,es}.json`, zero references in `src/` or `app/`:
  ```
  grep -rn "shared.close" apps/my-circles/src apps/my-circles/app   # → no matches
  ```
- During the confirm-close cleanup, four `shared.confirm-cancel-*` keys were also found dead and removed (they were the labels for a never-opened confirm dialog). `shared.close` looks like the same class of leftover.
- Secondary observation: `de.json` / `es.json` carry **English** values for several `shared.*` keys (e.g. the removed `shared.confirm-cancel-title` was `"Are you sure?"` in all three files). my-circles uses English fallback by design, so untranslated keys aren't a bug per se — but it signals this area is partly scaffolding and worth a translation-coverage pass.

## Mechanism
Keys accreted as UI was built and weren't removed when the corresponding UI was deleted/changed (same root cause as ISSUE-205's shipped stub and the confirm-close removal). No lint rule flags orphaned i18n keys.

## Blast radius
Cosmetic / maintainability only — dead keys bloat the dictionaries and mislead translators into spending effort on strings nothing renders. No runtime effect.

## Proposed fix
1. Run a **reliable** unused-key audit (the ad-hoc shell scan attempted during discovery gave a false negative on `shared.close`, so don't trust a naive `grep` loop). Prefer a real i18n-unused-keys tool, or cross-reference every `formatMessage({ id })` / `<FormattedMessage id>` against the key set, accounting for dynamically-constructed ids.
2. Remove confirmed-dead keys from `en/de/es` in lockstep.
3. Optionally: add a CI check (or eslint-plugin-formatjs / i18n-unused) so this can't regress.
4. Separately, scope a translation-coverage pass for `de`/`es` if real localization is intended (out of scope for a dead-key sweep).

## Effort / risk
Small. Removing unused keys is zero-risk once the audit is trustworthy; the only hazard is a **dynamically-built key id** that a static scan misses — hence step 1's emphasis on handling dynamic ids before deleting anything.
