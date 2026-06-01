# Connection & Room Join Flow

> 50 nodes

## Key Concepts

- **useLogger()** (167 connections) — `apps/circle-spaces/src/hooks/useLogger.tsx`
- **useEnvStore** (29 connections) — `apps/circle-spaces/src/state/useEnvStore.tsx`
- **useFSMStateStore** (21 connections) — `apps/circle-spaces/src/state/useFSMStateStore.tsx`
- **useConnectToPreview()** (12 connections) — `apps/circle-spaces/src/features/Chime/useConnectToPreview.ts`
- **useJoinCirclesServer()** (9 connections) — `apps/circle-spaces/src/features/Chime/useJoinCirclesServer.ts`
- **useInitCirclesChatlioUI()** (9 connections) — `apps/circle-spaces/src/hooks/useInitChatlio.tsx`
- **HelpMenu()** (8 connections) — `apps/circle-spaces/src/features/AgendaFeatures/AgendaComponents/AgendaMenuContainer/AgendaMenuComponents/HelpMenu.tsx`
- **useKeyBinding()** (8 connections) — `apps/circle-spaces/src/hooks/useKeyBinding.tsx`
- **useCreateChimeMeeting()** (7 connections) — `apps/circle-spaces/src/features/Chime/useCreateChimeMeeting.ts`
- **useLowSignalStore** (7 connections) — `apps/circle-spaces/src/state/useLowSignalStore.tsx`
- **UseAudioVideoObservers()** (7 connections) — `apps/circle-spaces/src/hooks/useAudioVideoObservers.tsx`
- **UseGetTime()** (6 connections) — `apps/circle-spaces/src/useGetTime.tsx`
- **SidebarProviderWrapper()** (6 connections) — `apps/circle-spaces/src/features/Sidebar/SidebarProviderWrapper.tsx`
- **useMoveToRoom()** (6 connections) — `apps/circle-spaces/src/features/Chime/useMoveToRoom.ts`
- **useRetryConnection()** (6 connections) — `apps/circle-spaces/src/features/Chime/useRetryConnection.ts`
- **useCirclesChatlio()** (6 connections) — `apps/circle-spaces/src/hooks/useChatlio.tsx`
- **InvitePageContent()** (5 connections) — `apps/circle-spaces/src/pageContent/InvitePageContent.tsx`
- **useBypassGreenroom()** (5 connections) — `apps/circle-spaces/src/features/Chime/useBypassGreenroom.ts`
- **useSetupPantsKeybinds()** (5 connections) — `apps/circle-spaces/src/features/ParticipantAwareNoteTaking/useSetupPantsKeybinds.ts`
- **useDesktopVideolessMode()** (5 connections) — `apps/circle-spaces/src/features/AgendaFeatures/AgendaComponents/AgendaMenuContainer/AgendaMenuHooks/Help/useDesktopVideolessMode.tsx`
- **UseSupportButtons()** (5 connections) — `apps/circle-spaces/src/features/AgendaFeatures/AgendaComponents/AgendaMenuContainer/AgendaMenuHooks/Help/useSupportButtons.tsx`
- **LowSignalIndicator()** (5 connections) — `apps/circle-spaces/src/components/VideoTileButton/LowSignalIndicator.tsx`
- **ToggleMuteButton()** (5 connections) — `apps/circle-spaces/src/components/VideoTileButton/ToggleMuteButton.tsx`
- **UseCirclesSubscription()** (5 connections) — `apps/circle-spaces/src/hooks/useCirclesSubscription.tsx`
- **useToggleHideAgenda()** (5 connections) — `apps/circle-spaces/src/hooks/FeatureHooks/useToggleHideAgenda.tsx`
- *... and 25 more nodes in this community*

## Relationships

- [[Chat & Notes Hooks]] (32 shared connections)
- [[Reactions & Confetti]] (31 shared connections)
- [[Settings & Next-Session Panel]] (24 shared connections)
- [[Tools Menu & Panels]] (23 shared connections)
- [[Layout Hooks & Floating Panels]] (22 shared connections)
- [[Floating Controls & Agenda Actions]] (18 shared connections)
- [[Community 32]] (16 shared connections)
- [[Connection Errors & Support]] (14 shared connections)
- [[Community 69]] (13 shared connections)
- [[Community 31]] (12 shared connections)
- [[Community 41]] (6 shared connections)
- [[Community 45]] (6 shared connections)

## Source Files

- `apps/circle-spaces/src/components/EndSessionReview/EndSessionReviewContainer.tsx`
- `apps/circle-spaces/src/components/Errors/ConnectionError/ConnectionErrorManager.tsx`
- `apps/circle-spaces/src/components/Errors/ContactUsTile/ContactUsTile.tsx`
- `apps/circle-spaces/src/components/ModernMobileLayouts/components/MobileLowSignalModal/MobileLowSignalModal.tsx`
- `apps/circle-spaces/src/components/VideoTileButton/LowSignalIndicator.tsx`
- `apps/circle-spaces/src/components/VideoTileButton/PlusOneContainer/PlusOneContainer.tsx`
- `apps/circle-spaces/src/components/VideoTileButton/ToggleMuteButton.tsx`
- `apps/circle-spaces/src/features/AgendaFeatures/AgendaComponents/AgendaMenuContainer/AgendaMenuComponents/HelpMenu.tsx`
- `apps/circle-spaces/src/features/AgendaFeatures/AgendaComponents/AgendaMenuContainer/AgendaMenuHooks/Help/useAboutButtons.tsx`
- `apps/circle-spaces/src/features/AgendaFeatures/AgendaComponents/AgendaMenuContainer/AgendaMenuHooks/Help/useDesktopVideolessMode.tsx`
- `apps/circle-spaces/src/features/AgendaFeatures/AgendaComponents/AgendaMenuContainer/AgendaMenuHooks/Help/useSupportButtons.tsx`
- `apps/circle-spaces/src/features/AgendaFeatures/AgendaComponents/AgendaMenuContainer/AgendaMenuHooks/Help/useTraceButtons.tsx`
- `apps/circle-spaces/src/features/Chime/useBypassGreenroom.ts`
- `apps/circle-spaces/src/features/Chime/useConnectToPreview.ts`
- `apps/circle-spaces/src/features/Chime/useCreateChimeMeeting.ts`
- `apps/circle-spaces/src/features/Chime/useJoinCirclesServer.ts`
- `apps/circle-spaces/src/features/Chime/useMoveToRoom.ts`
- `apps/circle-spaces/src/features/Chime/useRetryConnection.ts`
- `apps/circle-spaces/src/features/CirclesSurveyFeatures/SurveyComponents/SurveyValuePicker.tsx`
- `apps/circle-spaces/src/features/HomePageFeatures/NotificationDisplay/NotificationDisplay.tsx`

## Audit Trail

- EXTRACTED: 407 (94%)
- INFERRED: 28 (6%)
- AMBIGUOUS: 0 (0%)

---

*Part of the graphify knowledge wiki. See [[index]] to navigate.*