# Session Scheduling Hooks

> 56 nodes · cohesion 0.08

## Key Concepts

- **sessionTypes.ts** (34 connections) — `src/mfv/GuideHomeDashboard/MeetingTab/ScheduledSessions/sessionTypes.ts`
- **types.ts** (29 connections) — `src/mfv/GuideHomeDashboard/MeetingTab/hooks/useManageGuideHomeMeetings/types.ts`
- **SessionTypes.ts** (24 connections) — `src/mfv/GuideHomeDashboard/MeetingTab/types/SessionTypes.ts`
- **useRetreatManager.ts** (21 connections) — `src/mfv/GuideHomeDashboard/MeetingTab/hooks/useManageGuideHomeMeetings/useRetreatManager.ts`
- **useSessionManager.ts** (19 connections) — `src/mfv/GuideHomeDashboard/MeetingTab/hooks/useManageGuideHomeMeetings/useSessionManager.ts`
- **ManagerTypes.ts** (17 connections) — `src/mfv/GuideHomeDashboard/MeetingTab/types/ManagerTypes.ts`
- **useCreateCompleteRetreatDialog.ts** (15 connections) — `src/mfv/GuideHomeDashboard/MeetingTab/hooks/useManageGuideHomeMeetings/DialogHooks/useCreateCompleteRetreatDialog.ts`
- **useSessionMutations.ts** (14 connections) — `src/mfv/GuideHomeDashboard/MeetingTab/hooks/useManageGuideHomeMeetings/api/useSessionMutations.ts`
- **useCreateOrEditRetreatDialog.ts** (14 connections) — `src/mfv/GuideHomeDashboard/MeetingTab/hooks/useManageGuideHomeMeetings/DialogHooks/useCreateOrEditRetreatDialog.ts`
- **SessionManager** (14 connections) — `src/mfv/GuideHomeDashboard/MeetingTab/types/ManagerTypes.ts`
- **RescheduleData** (14 connections) — `src/mfv/GuideHomeDashboard/MeetingTab/types/SessionTypes.ts`
- **FormTypes.ts** (13 connections) — `src/mfv/GuideHomeDashboard/MeetingTab/types/FormTypes.ts`
- **useCreateCancelDialog.ts** (12 connections) — `src/mfv/GuideHomeDashboard/MeetingTab/hooks/useManageGuideHomeMeetings/DialogHooks/useCreateCancelDialog.ts`
- **useSessionDialogs.ts** (12 connections) — `src/mfv/GuideHomeDashboard/MeetingTab/hooks/useManageGuideHomeMeetings/useSessionDialogs.ts`
- **RetreatFormData** (12 connections) — `src/mfv/GuideHomeDashboard/MeetingTab/types/FormTypes.ts`
- **useCreateEditAttendanceDialog.ts** (10 connections) — `src/mfv/GuideHomeDashboard/MeetingTab/hooks/useManageGuideHomeMeetings/DialogHooks/useCreateEditAttendanceDialog.ts`
- **RetreatManager** (10 connections) — `src/mfv/GuideHomeDashboard/MeetingTab/types/ManagerTypes.ts`
- **useCreateEditSessionRetreatDialog.ts** (9 connections) — `src/mfv/GuideHomeDashboard/MeetingTab/hooks/useManageGuideHomeMeetings/DialogHooks/useCreateEditSessionRetreatDialog.ts`
- **useCreateRescheduleDialog.ts** (8 connections) — `src/mfv/GuideHomeDashboard/MeetingTab/hooks/useManageGuideHomeMeetings/DialogHooks/useCreateRescheduleDialog.ts`
- **ScheduleCancellationReasonType** (8 connections) — `src/mfv/GuideHomeDashboard/MeetingTab/types/SessionTypes.ts`
- **cancellationReasonMapper.ts** (7 connections) — `src/mfv/GuideHomeDashboard/MeetingTab/utils/cancellationReasonMapper.ts`
- **ServerDateString** (7 connections) — `src/mfv/GuideHomeDashboard/MeetingTab/types/RetreatTypes.ts`
- **useCreateOrEditRetreatDialog()** (6 connections) — `src/mfv/GuideHomeDashboard/MeetingTab/hooks/useManageGuideHomeMeetings/DialogHooks/useCreateOrEditRetreatDialog.ts`
- **toServerDateString()** (6 connections) — `src/mfv/GuideHomeDashboard/MeetingTab/utils/dateFormatters.ts`
- **useCreateRetreatNotificationDialog.ts** (5 connections) — `src/mfv/GuideHomeDashboard/MeetingTab/hooks/useManageGuideHomeMeetings/DialogHooks/useCreateRetreatNotificationDialog.ts`
- *... and 31 more nodes in this community*

## Relationships

- [[Reschedule/Cancel Dialogs]] (27 shared connections)
- [[Retreat Display & History]] (25 shared connections)
- [[Guide Home & Custom URL]] (20 shared connections)
- [[Community 32]] (16 shared connections)
- [[Retreat Planner]] (12 shared connections)
- [[Community 30]] (11 shared connections)
- [[Community 23]] (11 shared connections)
- [[Forum Breadcrumbs & Panes]] (10 shared connections)
- [[Community 33]] (6 shared connections)
- [[Community 24]] (5 shared connections)
- [[Community 64]] (3 shared connections)
- [[Community 45]] (3 shared connections)

## Source Files

- `src/mfv/GuideHomeDashboard/MeetingHooks/useOfficialWaveRetreat.ts`
- `src/mfv/GuideHomeDashboard/MeetingTab/ScheduledSessions/sessionTypes.ts`
- `src/mfv/GuideHomeDashboard/MeetingTab/graphQL/scheduleMutations.ts`
- `src/mfv/GuideHomeDashboard/MeetingTab/hooks/useManageGuideHomeMeetings/DialogHooks/useCancelSessionManager.ts`
- `src/mfv/GuideHomeDashboard/MeetingTab/hooks/useManageGuideHomeMeetings/DialogHooks/useCreateCancelDialog.ts`
- `src/mfv/GuideHomeDashboard/MeetingTab/hooks/useManageGuideHomeMeetings/DialogHooks/useCreateCompleteRetreatDialog.ts`
- `src/mfv/GuideHomeDashboard/MeetingTab/hooks/useManageGuideHomeMeetings/DialogHooks/useCreateEditAttendanceDialog.ts`
- `src/mfv/GuideHomeDashboard/MeetingTab/hooks/useManageGuideHomeMeetings/DialogHooks/useCreateEditSessionRetreatDialog.ts`
- `src/mfv/GuideHomeDashboard/MeetingTab/hooks/useManageGuideHomeMeetings/DialogHooks/useCreateOrEditRetreatDialog.ts`
- `src/mfv/GuideHomeDashboard/MeetingTab/hooks/useManageGuideHomeMeetings/DialogHooks/useCreateRescheduleDialog.ts`
- `src/mfv/GuideHomeDashboard/MeetingTab/hooks/useManageGuideHomeMeetings/DialogHooks/useCreateRetreatNotificationDialog.ts`
- `src/mfv/GuideHomeDashboard/MeetingTab/hooks/useManageGuideHomeMeetings/api/useSessionMutations.ts`
- `src/mfv/GuideHomeDashboard/MeetingTab/hooks/useManageGuideHomeMeetings/types.ts`
- `src/mfv/GuideHomeDashboard/MeetingTab/hooks/useManageGuideHomeMeetings/useRetreatManager.ts`
- `src/mfv/GuideHomeDashboard/MeetingTab/hooks/useManageGuideHomeMeetings/useSessionDialogs.ts`
- `src/mfv/GuideHomeDashboard/MeetingTab/hooks/useManageGuideHomeMeetings/useSessionManager.ts`
- `src/mfv/GuideHomeDashboard/MeetingTab/hooks/useManageGuideHomeMeetings/utilities.ts`
- `src/mfv/GuideHomeDashboard/MeetingTab/types/FormTypes.ts`
- `src/mfv/GuideHomeDashboard/MeetingTab/types/ManagerTypes.ts`
- `src/mfv/GuideHomeDashboard/MeetingTab/types/RetreatTypes.ts`

## Audit Trail

- EXTRACTED: 410 (100%)
- INFERRED: 0 (0%)
- AMBIGUOUS: 0 (0%)

---

*Part of the graphify knowledge wiki. See [[index]] to navigate.*