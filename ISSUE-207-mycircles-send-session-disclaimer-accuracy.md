# ISSUE-207: SendSessionDetailsModal disclaimer copy needs accuracy verification

- **Severity:** S3
- **Status:** investigate
- **Area:** my-circles / content + backend behaviour
- **Found:** 2026-06-01 (inline `{/*TODO Check if this is still even true */}` in `SendSessionDetailsModal`, added by the branch author in `d20e622f`; inline comment removed, question parked here)

## Symptom
The "send session details" modal shows a disclaimer making specific claims about calendar behaviour. It's unverified whether those claims still match what the backend actually emails. The author left an inline TODO ("Check if this is still even true") next to it.

## Evidence
- Component: `apps/my-circles/src/components/ModalContainer/Modals/SendSessionDetailsModal/SendSessionDetailsModal.tsx` — the disclaimer renders in a `PopoverTooltip` beside the `info-item-4` ("An 'Add to calendar' link") list item.
- Copy (`apps/my-circles/lang/en.json`):
  - `send-session-modal.info-item-4`: `"An 'Add to calendar' link"`
  - `send-session-modal.disclaimer`: `"Please note, we are not sending a regular calendar invitation to your participants. Although they can add a hold to their calendar by clicking the 'add to calendar' link, it's not possible for the session organizer to delete or update this hold or make it recurring."`
- Backend: the modal submits `circleSendInviteToMeetingEmail` (`apps/my-circles/src/queries/sendSessionQueries.ts`). Inputs include `meetingDatetime`, `meetingTimezone`, `durationMinutes`, `message`, `runtimePersonIds` — consistent with calendar/scheduling data being sent, but the email template's actual contents and the precise hold semantics are not observable from the frontend.

## Mechanism
The disclaimer describes server-side email-template behaviour (does the email contain an "add to calendar" link? are the no-update / no-delete / no-recurring caveats accurate?). The frontend can't confirm this; it needs a check against the backend mailer / a manual send-and-inspect.

## Blast radius
User-facing accuracy only. If the copy is wrong, participants/organizers get misleading expectations about calendar behaviour. No crash or data risk.

## Proposed fix
1. Confirm against the backend (`circleSendInviteToMeetingEmail` mailer template) or by sending a real invite and inspecting the email: (a) is there an "add to calendar" link? (b) are the "can't update/delete/make recurring" caveats correct?
2. If accurate → no code change needed (the inline TODO is already removed).
3. If inaccurate → update `send-session-modal.disclaimer` (and `info-item-4` if needed) in `lang/{en,de,es}.json`.

## Effort / risk
Trivial code-wise (a string edit at most). The real work is a backend/product confirmation — owner is whoever owns the meeting-invite email template.

## Related
- [ISSUE-205](ISSUE-205-mycircles-send-session-stub-shipped.md) — same modal. The console.log stub it described has since been removed and the real mutation is wired; 205 should be reconciled to reflect that the feature now submits.
