# ISSUE-005: `useAgendaStartHandler` mount effect calls `handleStartAgenda()` with a stale closure (empty dep array)

- **Severity:** S2
- **Status:** confirmed
- **Area:** circle-spaces / AgendaFeatures (agenda start flow)
- **Found:** 2026-06-01 (manual read)

## Symptom
On mount, if a session is already active, the hook auto-starts the agenda by calling `handleStartAgenda()` from an effect with an empty dependency array. `handleStartAgenda` closes over several pieces of state (`selectedSession`, `markLate`, `lateBy`, `markEarly`) that are initialised after the first render or updated by other effects, so the mount-time call captures the *initial* values, not the resolved ones.

## Evidence
`apps/circle-spaces/src/features/AgendaFeatures/AgendaComponents/AgendaControls/AgendaStartMenu/hooks/useAgendaStartHandler.ts`:

The auto-start effect (empty deps):
```
137 // If a session is already active on mount, start the agenda immediately and skip the menu
138 useEffect(() => {
139     if (isSessionLikelyCurrent(activeSchedule)) {
140         handleStartAgenda();
141     }
142     refetchSessions();
143 }, []);
```

`handleStartAgenda` reads state that is set elsewhere:
```
61  const handleStartAgenda = (ignoreSession = false) => {
65      if (markLate && lateBy) { ... }          // markLate/lateBy state
71      if (selectedSession) {                    // selectedSession state
72          sendAgendaStartMetrics(selectedSession);
```

But `selectedSession` is only populated by a *different* effect that runs when `scheduledSessions` arrives:
```
123 useEffect(() => {
124     if (scheduledSessions) {
...
132         setSelectedSession(best);
135 }, [scheduledSessions]);
```

At mount, `scheduledSessions` from `useGetNextSession()` is still loading (`network-only` query), so `selectedSession` is `null` and `lateBy`/`markLate` are at defaults. The empty-dep effect's closure also never updates if `activeSchedule` changes after mount.

## Mechanism
Classic stale-closure: an effect with `[]` deps captures render-0 values of `handleStartAgenda` (and the state it closes over). React's lint rule `react-hooks/exhaustive-deps` would flag `handleStartAgenda`, `activeSchedule`, and `refetchSessions` as missing. The auto-start path therefore fires the agenda-start mutation with default/empty selection state and cannot reflect the session that loads moments later.

## Blast radius
Only the "session already active on mount → skip menu and auto-start" path. Impact: the auto-start may not attach the correct `scheduleId` (because `selectedSession` is null at that instant) — though `handleStartAgenda` only sends `roomSetActiveSession` when `!isSessionLikelyCurrent`, and this branch is gated on `isSessionLikelyCurrent === true`, which partly masks it. The latent risk is real if the gating logic changes, and the early/late offset state is silently ignored.

## Proposed fix
Either (a) gate the auto-start on `scheduledSessions` having loaded and include the real deps (`handleStartAgenda`, `activeSchedule`), wrapping `handleStartAgenda` in `useCallback`; or (b) hoist the "is a session active right now" decision into a pure function of `activeSchedule` and call the mutation directly with explicit arguments rather than via the stateful `handleStartAgenda`.

## Effort / risk
Small–medium. Risk: changing deps can cause the auto-start to fire more than once if not guarded with a ran-once ref; add an explicit guard.
