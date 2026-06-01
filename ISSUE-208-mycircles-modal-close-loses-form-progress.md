# ISSUE-208: Modal Cancel/close discards in-progress form input with no confirmation

- **Severity:** S3
- **Status:** investigate (product decision)
- **Area:** my-circles / modals (AddNewCircleModal et al.)
- **Found:** 2026-06-01 (PR #931 review, comment 9 — martin)

## Symptom
Closing/cancelling a modal mid-edit (AddNewCircleModal in particular — a 3-page form) silently discards everything the user typed. There is no "are you sure?" confirmation, so an accidental Cancel/ESC/backdrop loses all progress.

## Evidence
- `AddNewCircleModal` Cancel now calls `toggleDialog("addCircle")` (closes immediately); `BaseModal`'s `onClose` runs `resetForm`, wiping the form.
- A close-confirmation mechanism used to exist in `BaseModal` (`shouldConfirmClose` prop + `confirmDialogRef` "confirm cancel" dialog) but was disabled in the chain (the `handleClose`/`showModal` trigger was removed in `d20e622f`), and removed entirely in the `my-circles-close-to-finish` cleanup. So the confirm `<dialog>` markup is dead/removed and nothing guards data loss.
- Reviewer (martin): "Should this be confirmed for this merge? Since the functionality changed and now users can lose the progress of the form. Is there a ticket in order not to miss this?"

## Mechanism
Product behaviour change: the multi-page create-circle flow makes accidental data loss more costly than for a single-field modal, and the previously-scaffolded confirm-on-close was never wired up.

## Blast radius
UX / data-entry frustration. No correctness or security impact. Worst case: a user fills in a circle + members, mis-clicks Cancel, loses it.

## Proposed fix (decision needed)
Pick one:
1. **Accept current behaviour** (Cancel = discard) — close this as wontfix; lowest effort.
2. **Confirm only when dirty** — re-introduce a confirm-on-close that fires only if the form has unsaved input. NOTE: re-adds machinery that `my-circles-close-to-finish` deleted, so coordinate to avoid a stacked-rebase conflict; ideally implement once, in `BaseModal`, after that cleanup lands.
3. **Auto-preserve** — keep form state across close/reopen instead of resetting on `onClose`.

## Effort / risk
Option 1: trivial. Option 2: medium (shared `BaseModal` change + dirty-tracking, VRT for the new dialog). Option 3: medium (state lifting). Recommend deciding 1 vs 2 with product before building.
