# Graph Report - .  (2026-06-01)

## Corpus Check
- 425 files · ~176,315 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 2433 nodes · 4110 edges · 103 communities (90 shown, 13 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 1 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Localization Strings (de)|Localization Strings (de)]]
- [[_COMMUNITY_Localization Strings (es)|Localization Strings (es)]]
- [[_COMMUNITY_Localization Strings (en)|Localization Strings (en)]]
- [[_COMMUNITY_Session Scheduling Hooks|Session Scheduling Hooks]]
- [[_COMMUNITY_Notes & ErrorNotification Store|Notes & Error/Notification Store]]
- [[_COMMUNITY_Guide Home & Custom URL|Guide Home & Custom URL]]
- [[_COMMUNITY_Retreat Planner|Retreat Planner]]
- [[_COMMUNITY_Localization & Scheduler Stories|Localization & Scheduler Stories]]
- [[_COMMUNITY_Forum Dashboard (responsive)|Forum Dashboard (responsive)]]
- [[_COMMUNITY_Login & Auth Panels|Login & Auth Panels]]
- [[_COMMUNITY_Forum Member Details|Forum Member Details]]
- [[_COMMUNITY_Dashboard Container & Global Store|Dashboard Container & Global Store]]
- [[_COMMUNITY_Dev Dependencies|Dev Dependencies]]
- [[_COMMUNITY_Circle Metrics — BreakoutSession|Circle Metrics — Breakout/Session]]
- [[_COMMUNITY_Runtime Dependencies|Runtime Dependencies]]
- [[_COMMUNITY_Retreat Display & History|Retreat Display & History]]
- [[_COMMUNITY_Forum Breadcrumbs & Panes|Forum Breadcrumbs & Panes]]
- [[_COMMUNITY_App Routes & GraphQL Clients|App Routes & GraphQL Clients]]
- [[_COMMUNITY_Dashboard Containers & JWT|Dashboard Containers & JWT]]
- [[_COMMUNITY_RescheduleCancel Dialogs|Reschedule/Cancel Dialogs]]
- [[_COMMUNITY_Next Session Rescheduler|Next Session Rescheduler]]
- [[_COMMUNITY_TypeScript Config|TypeScript Config]]
- [[_COMMUNITY_Community 22|Community 22]]
- [[_COMMUNITY_Community 23|Community 23]]
- [[_COMMUNITY_Community 24|Community 24]]
- [[_COMMUNITY_Community 25|Community 25]]
- [[_COMMUNITY_Community 26|Community 26]]
- [[_COMMUNITY_Community 27|Community 27]]
- [[_COMMUNITY_Community 28|Community 28]]
- [[_COMMUNITY_Community 29|Community 29]]
- [[_COMMUNITY_Community 30|Community 30]]
- [[_COMMUNITY_Community 31|Community 31]]
- [[_COMMUNITY_Community 32|Community 32]]
- [[_COMMUNITY_Community 33|Community 33]]
- [[_COMMUNITY_Community 34|Community 34]]
- [[_COMMUNITY_Community 35|Community 35]]
- [[_COMMUNITY_Community 36|Community 36]]
- [[_COMMUNITY_Community 37|Community 37]]
- [[_COMMUNITY_Community 38|Community 38]]
- [[_COMMUNITY_Community 39|Community 39]]
- [[_COMMUNITY_Community 40|Community 40]]
- [[_COMMUNITY_Community 41|Community 41]]
- [[_COMMUNITY_Community 42|Community 42]]
- [[_COMMUNITY_Community 43|Community 43]]
- [[_COMMUNITY_Community 44|Community 44]]
- [[_COMMUNITY_Community 45|Community 45]]
- [[_COMMUNITY_Community 46|Community 46]]
- [[_COMMUNITY_Community 47|Community 47]]
- [[_COMMUNITY_Community 48|Community 48]]
- [[_COMMUNITY_Community 49|Community 49]]
- [[_COMMUNITY_Community 50|Community 50]]
- [[_COMMUNITY_Community 51|Community 51]]
- [[_COMMUNITY_Community 52|Community 52]]
- [[_COMMUNITY_Community 53|Community 53]]
- [[_COMMUNITY_Community 54|Community 54]]
- [[_COMMUNITY_Community 55|Community 55]]
- [[_COMMUNITY_Community 56|Community 56]]
- [[_COMMUNITY_Community 57|Community 57]]
- [[_COMMUNITY_Community 58|Community 58]]
- [[_COMMUNITY_Community 59|Community 59]]
- [[_COMMUNITY_Community 60|Community 60]]
- [[_COMMUNITY_Community 61|Community 61]]
- [[_COMMUNITY_Community 62|Community 62]]
- [[_COMMUNITY_Community 63|Community 63]]
- [[_COMMUNITY_Community 64|Community 64]]
- [[_COMMUNITY_Community 65|Community 65]]
- [[_COMMUNITY_Community 66|Community 66]]
- [[_COMMUNITY_Community 67|Community 67]]
- [[_COMMUNITY_Community 68|Community 68]]
- [[_COMMUNITY_Community 69|Community 69]]
- [[_COMMUNITY_Community 70|Community 70]]
- [[_COMMUNITY_Community 71|Community 71]]
- [[_COMMUNITY_Community 72|Community 72]]
- [[_COMMUNITY_Community 73|Community 73]]
- [[_COMMUNITY_Community 74|Community 74]]
- [[_COMMUNITY_Community 75|Community 75]]
- [[_COMMUNITY_Community 76|Community 76]]
- [[_COMMUNITY_Community 77|Community 77]]
- [[_COMMUNITY_Community 78|Community 78]]
- [[_COMMUNITY_Community 79|Community 79]]
- [[_COMMUNITY_Community 80|Community 80]]
- [[_COMMUNITY_Community 81|Community 81]]
- [[_COMMUNITY_Community 82|Community 82]]
- [[_COMMUNITY_Community 83|Community 83]]
- [[_COMMUNITY_Community 84|Community 84]]
- [[_COMMUNITY_Community 85|Community 85]]
- [[_COMMUNITY_Community 90|Community 90]]
- [[_COMMUNITY_Community 93|Community 93]]
- [[_COMMUNITY_Community 95|Community 95]]

## God Nodes (most connected - your core abstractions)
1. `UseLogger()` - 81 edges
2. `ScheduleSession` - 60 edges
3. `useGlobalStore` - 50 edges
4. `RetreatType` - 47 edges
5. `ForumData` - 41 edges
6. `GlobalStore` - 24 edges
7. `ParsedForumMember` - 22 edges
8. `compilerOptions` - 17 edges
9. `scripts` - 16 edges
10. `WithChildren` - 16 edges

## Surprising Connections (you probably didn't know these)
- `Error()` --calls--> `UseLogger()`  [EXTRACTED]
  app/[locale]/error.tsx → src/components/Logger/useLogger.tsx
- `Error()` --calls--> `UseLogger()`  [EXTRACTED]
  app/[locale]/(mfv)/error.tsx → src/components/Logger/useLogger.tsx
- `ForumUserTile()` --calls--> `UseLogger()`  [EXTRACTED]
  src/components/DashboardContainer/CircleMembersPanel/ForumUserTile.tsx → src/components/Logger/useLogger.tsx
- `DateLine()` --calls--> `UseLogger()`  [EXTRACTED]
  src/components/DashboardContainer/CircleMetricsPanel/Views/Summary/components/DateLine/DateLine.tsx → src/components/Logger/useLogger.tsx
- `ForumCircle()` --calls--> `UseLogger()`  [EXTRACTED]
  src/components/ForumDashboard/ForumCircle.tsx → src/components/Logger/useLogger.tsx

## Import Cycles
- 3-file cycle: `src/components/DashboardContainer/NotesViewer/NotesViewer.tsx -> src/components/DashboardContainer/NotesViewer/useNotesEvents.ts -> src/components/DashboardContainer/NotesViewer/useRetrieveNotesData.ts -> src/components/DashboardContainer/NotesViewer/NotesViewer.tsx`
- 3-file cycle: `src/components/DashboardContainer/NotesViewer/NotesViewer.tsx -> src/components/DashboardContainer/NotesViewer/useNotesEvents.ts -> src/components/DashboardContainer/NotesViewer/useNoteMutations.ts -> src/components/DashboardContainer/NotesViewer/NotesViewer.tsx`
- 3-file cycle: `src/components/DashboardContainer/NotesViewer/NotesViewer.tsx -> src/components/DashboardContainer/NotesViewer/useNotesEvents.ts -> src/components/DashboardContainer/NotesViewer/noteSort.ts -> src/components/DashboardContainer/NotesViewer/NotesViewer.tsx`
- 3-file cycle: `src/mfv/ForumView/MemberDetails/MemberDetails.tsx -> src/mfv/ForumView/MemberDetails/MemberDetailsView.tsx -> src/mfv/ForumView/MemberDetails/components/MemberPortraitDetails.tsx -> src/mfv/ForumView/MemberDetails/MemberDetails.tsx`
- 3-file cycle: `src/mfv/ForumView/MemberDetails/MemberDetails.tsx -> src/mfv/ForumView/MemberDetails/MemberDetailsView.tsx -> src/mfv/ForumView/MemberDetails/components/MemberAttendedStatusBlock.tsx -> src/mfv/ForumView/MemberDetails/MemberDetails.tsx`
- 3-file cycle: `src/mfv/ForumView/MemberDetails/MemberDetails.tsx -> src/mfv/ForumView/MemberDetails/MemberDetailsView.tsx -> src/mfv/ForumView/MemberDetails/components/SecondaryInfoBlock.tsx -> src/mfv/ForumView/MemberDetails/MemberDetails.tsx`
- 3-file cycle: `src/mfv/ForumView/MemberDetails/MemberDetails.tsx -> src/mfv/ForumView/MemberDetails/MemberDetailsView.tsx -> src/mfv/ForumView/MemberDetails/components/IfYouReallyKnewMeBlock.tsx -> src/mfv/ForumView/MemberDetails/MemberDetails.tsx`
- 3-file cycle: `src/mfv/ForumView/MemberDetails/MemberDetails.tsx -> src/mfv/ForumView/MemberDetails/MemberDetailsView.tsx -> src/mfv/ForumView/MemberDetails/components/LocationTimezoneBlock.tsx -> src/mfv/ForumView/MemberDetails/MemberDetails.tsx`
- 3-file cycle: `src/mfv/ForumView/MemberDetails/MemberDetails.tsx -> src/mfv/ForumView/MemberDetails/MemberDetailsView.tsx -> src/mfv/ForumView/MemberDetails/components/MainInfoBlock.tsx -> src/mfv/ForumView/MemberDetails/MemberDetails.tsx`
- 3-file cycle: `src/components/GlobalStore/useGlobalStore.tsx -> src/mfv/PageContent/useForumState.ts -> src/mfv/queries/useGetPersons.ts -> src/components/GlobalStore/useGlobalStore.tsx`
- 4-file cycle: `src/components/GlobalStore/useGlobalStore.tsx -> src/mfv/PageContent/useForumState.ts -> src/mfv/queries/useGetPersons.ts -> src/components/Logger/useLogger.tsx -> src/components/GlobalStore/useGlobalStore.tsx`

## Communities (103 total, 13 thin omitted)

### Community 0 - "Localization Strings (de)"
Cohesion: 0.01
Nodes (347): cancelMeetingDialog.cancelButton, cancelMeetingDialog.cantFindTime, cancelMeetingDialog.dontCancelButton, cancelMeetingDialog.header, cancelMeetingDialog.headerRetreat, cancelMeetingDialog.lastMinuteKACancellations, cancelMeetingDialog.message, cancelMeetingDialog.messageAdHoc (+339 more)

### Community 1 - "Localization Strings (es)"
Cohesion: 0.01
Nodes (347): cancelMeetingDialog.cancelButton, cancelMeetingDialog.cantFindTime, cancelMeetingDialog.dontCancelButton, cancelMeetingDialog.header, cancelMeetingDialog.headerRetreat, cancelMeetingDialog.lastMinuteKACancellations, cancelMeetingDialog.message, cancelMeetingDialog.messageAdHoc (+339 more)

### Community 2 - "Localization Strings (en)"
Cohesion: 0.01
Nodes (347): cancelMeetingDialog.cancelButton, cancelMeetingDialog.cantFindTime, cancelMeetingDialog.dontCancelButton, cancelMeetingDialog.header, cancelMeetingDialog.headerRetreat, cancelMeetingDialog.lastMinuteKACancellations, cancelMeetingDialog.message, cancelMeetingDialog.messageAdHoc (+339 more)

### Community 3 - "Session Scheduling Hooks"
Cohesion: 0.08
Nodes (34): UseSessionDialogsOptions, RetreatAttendanceUpdateResponse, UseSessionDialogsOptions, useCreateOrEditRetreatDialog(), UseSessionDialogsOptions, UseSessionDialogsOptions, scheduleMutations, RetreatFormData (+26 more)

### Community 4 - "Notes & Error/Notification Store"
Cohesion: 0.08
Nodes (30): ErrorAlertStore, NotificationState, useErrorAlertStore, notesMutations, compareNoteGroupsBySize(), countIncompleteNotes(), getNoteGroupsWithArray(), sortGroupsByNoteDate() (+22 more)

### Community 5 - "Guide Home & Custom URL"
Cohesion: 0.08
Nodes (23): RetreatAttendanceUpdateResponse, customUrlQueries, CustomDocument, FHPCarouselTabsProps, GuideHomeMeetingsManagerReturn, retreatMutations, useSelectedWaveFromCircle(), DatepickerRowProps (+15 more)

### Community 6 - "Retreat Planner"
Cohesion: 0.08
Nodes (23): AttendeesHeaderProps, CreateSessionOrRetreatDialog(), DialogProps, RetreatPlanningProps, SessionTypeSelectionProps, DialogProps, EditOrCreateRetreatDialog(), useAttendanceInitialization() (+15 more)

### Community 7 - "Localization & Scheduler Stories"
Cohesion: 0.06
Nodes (21): ActivationTimeExample, config, CirclesLocalization(), getMessages(), CirclesSessionSchedulerExample, CircleMetricsSummaryExample, NavBarExampleLoggedIn, NavBarExampleLoggedOut (+13 more)

### Community 8 - "Forum Dashboard (responsive)"
Cohesion: 0.07
Nodes (19): ForumCircle(), Orientation, DesktopLandscape, DesktopNoGuide, DesktopPortrait, Mobile, MobileNoGuide, mockGuide (+11 more)

### Community 9 - "Login & Auth Panels"
Cohesion: 0.09
Nodes (8): LoginContainerProps, MultiForumViewPageContentsType, NotificationDialogProps, WithCancelClick, WithSiteKey, WithTogglePanelSwitch, ForgotYourPasswordExample, validateEmail()

### Community 10 - "Forum Member Details"
Cohesion: 0.11
Nodes (13): IfYouReallyKnewMeBlockProps, LocationTimeZoneBlockProps, MainInfoBlockProps, MemberAttendedStatusBlock(), MemberAttendedStatusBlockProps, MemberPortraitDetailsProps, SecondaryInfoBlockProps, MemberDetailsProps (+5 more)

### Community 11 - "Dashboard Container & Global Store"
Cohesion: 0.12
Nodes (8): DashboardSwitcher(), authenticatedUserDefaults(), GlobalStore, sessionDefaults(), jwtQueries, loginMutations, getCircleDetails, EnterCircleSpaceButton()

### Community 12 - "Dev Dependencies"
Cohesion: 0.06
Nodes (33): devDependencies, eslint, eslint-config-next, eslint-config-prettier, eslint-plugin-storybook, @playwright/test, @repo/eslint-config, @repo/testing (+25 more)

### Community 13 - "Circle Metrics — Breakout/Session"
Cohesion: 0.08
Nodes (20): BreakoutGroupProps, Attendee, BreakoutAttendee, BreakoutGroupType, BreakoutInitiatorData, BreakoutSessionData, BreakoutValueScores, FacilitatorSurveyData (+12 more)

### Community 14 - "Runtime Dependencies"
Cohesion: 0.06
Nodes (31): dependencies, @absinthe/socket, @absinthe/socket-apollo-link, agenda-sidebar, @apollo/client, axios, @circles/ccc, @circles/cui (+23 more)

### Community 15 - "Retreat Display & History"
Cohesion: 0.15
Nodes (19): ActiveRetreatDisplay(), ActiveRetreatDisplayProps, CompletedRetreatDisplay(), CompletedRetreatDisplayProps, RetreatDetailsDisplayProps, UseCreateViewOldRetreatsDialogOptions, useViewOldRetreats(), UseViewOldRetreatsOptions (+11 more)

### Community 16 - "Forum Breadcrumbs & Panes"
Cohesion: 0.13
Nodes (12): ForumBreadcrumbs(), useBreadcrumbs(), ForumPaneProps, UseHandleForumPaneResizeProps, ProcessForumMemberParams, Logger(), MetricsTypes, UploadLineFn (+4 more)

### Community 17 - "App Routes & GraphQL Clients"
Cohesion: 0.11
Nodes (8): createAnonClient(), createForumClient(), CirclesAnonClient(), CirclesForumClient(), WithApiURL, WithChildren, getData(), Home()

### Community 18 - "Dashboard Containers & JWT"
Cohesion: 0.12
Nodes (26): CirclesSessionSchedulerContainer(), ForumDashboardContainer(), NonForumDashboardContainer(), CircleCrumb(), useGlobalStore, useGetHash(), UseJwt(), useDevPanel() (+18 more)

### Community 19 - "Reschedule/Cancel Dialogs"
Cohesion: 0.14
Nodes (23): MeetingsDialogContainerProps, RescheduleSessionDialogs, BaseDialogProps, CancelMeetingDialogProps, CancelSessionDialogProps, CompleteRetreatDialogProps, CreateRetreatDialogProps, CreateSessionDialogProps (+15 more)

### Community 20 - "Next Session Rescheduler"
Cohesion: 0.17
Nodes (14): NextSessionDetailsPanelProps, NextSessionReschedulerPanel(), ReschedulerPanelProps, MutationError, ScheduleSessionNodeEdgeType, useNextSessionMutations(), timezoneOption, useRetrieveTimezoneOptions() (+6 more)

### Community 21 - "TypeScript Config"
Cohesion: 0.09
Nodes (22): compilerOptions, allowJs, esModuleInterop, incremental, isolatedModules, jsx, lib, module (+14 more)

### Community 22 - "Community 22"
Cohesion: 0.12
Nodes (11): generateJWTSocket(), modifyHeadersForEventInitiator(), CirclesJwtClient(), ClientDataType, UseClientMetricsData(), StorageType, useStorage(), hasSubscription() (+3 more)

### Community 23 - "Community 23"
Cohesion: 0.15
Nodes (15): CustomSessionsSection(), CustomSessionsSectionProps, sortAndFilterSessions(), getCustomSessionMenuItems(), useScrollIndicator(), GuideHomeMeetingsManagerReturn, GuideHomeRetreatPlannerProps, OfficialSessionsSection() (+7 more)

### Community 24 - "Community 24"
Cohesion: 0.10
Nodes (11): CopyAllClipboardToastPortalProps, DUMMY_ACTIVE_MEMBERS, MemberListProps, MemberListHeaderProps, ACTIVE_WAVE_STATUSES, HttpRequest, Person, RelForumProfileNodeEdge (+3 more)

### Community 25 - "Community 25"
Cohesion: 0.12
Nodes (7): ForumMembers(), ForumMembersProps, CirclesRetreatMenuProps, AgendaSearchBarProps, AgendaSearchBarProps, CircleMemberTabs, filterMembers()

### Community 26 - "Community 26"
Cohesion: 0.12
Nodes (10): metadata, DashboardPage(), getData(), EnvManager(), DashboardPage(), getData(), ForumPage(), getData() (+2 more)

### Community 27 - "Community 27"
Cohesion: 0.13
Nodes (5): KeyBind, KeyBindBuilder, KeyBindings, useKeyBinding(), equal()

### Community 28 - "Community 28"
Cohesion: 0.14
Nodes (16): useCustomDocumentsMetrics(), useRetrieveCustomUrl(), DashboardTabs(), ForumDashboardTabs(), ForumCard(), GuideHomeDashboard(), useForumMutations(), Error() (+8 more)

### Community 29 - "Community 29"
Cohesion: 0.13
Nodes (11): BreakoutGroupAttendee, BreakoutSession, InitiatorInfo, ServerSessionBreakout, breakoutsDummyData, MetricsSessionTabViewExample, getAllAttendees(), getGroupIdentifier() (+3 more)

### Community 30 - "Community 30"
Cohesion: 0.19
Nodes (13): ScheduledSessionsQueryResult, useScheduledSessions(), scheduleQueries, ForumWaveState, convertRetreatToSession(), getWaveSessionsByType(), groupSessionsByWave(), mergeRetreatsWithSessions() (+5 more)

### Community 31 - "Community 31"
Cohesion: 0.24
Nodes (11): AttendanceMetricsTable(), Session, generateKeyMetricsData(), generateKeyMetricsDataPoint(), generateKeyMetricsHeader(), generatePercentageDataPoint(), KeyMetricsTable(), MouseEventHandlerWithSessionData (+3 more)

### Community 32 - "Community 32"
Cohesion: 0.14
Nodes (17): useRetreatMutations(), useSessionMutations(), useCancelSessionManager(), useCreateCancelDialog(), useCreateEditAttendanceDialog(), useCreateEditSessionRetreatDialog(), useCreateRescheduleDialog(), useCreateRetreatNotificationDialog() (+9 more)

### Community 33 - "Community 33"
Cohesion: 0.19
Nodes (12): formatDateRange(), formatDuration(), formatMeetingHeader(), formatNextSessionDate(), formatRetreatDateRange(), formatSessionTimeWithEndTimeInTimezone(), formatTime(), getBrowserTimezone() (+4 more)

### Community 34 - "Community 34"
Cohesion: 0.12
Nodes (16): scripts, build, build-storybook, clean, dev, lint, start, storybook (+8 more)

### Community 35 - "Community 35"
Cohesion: 0.16
Nodes (12): BreakoutMetricsData, BreakoutMetricsVariables, circleMetricsQuery, getBreakoutMetricsDataQuery, getSessionMetricsDataQuery, personListQueries, SessionMetricsVariables, WithCircleID (+4 more)

### Community 36 - "Community 36"
Cohesion: 0.28
Nodes (11): CircleMembers(), retreatMutations, useCirclesRetreatSurvey(), ForumOverview(), ForumOverviewProps, ForumPlanning(), ForumPlanningProps, useRetreatSubscription() (+3 more)

### Community 37 - "Community 37"
Cohesion: 0.14
Nodes (6): ErrorBoundary, errorBoundaryProps, buildForumMember(), defaultProps, renderComponent(), MultiForumViewPageContentsType

### Community 38 - "Community 38"
Cohesion: 0.25
Nodes (6): SessionPlanningProps, TimezoneStore, ReschedulerTimezoneSelectorProps, UseTimezoneSelectorReturn, TimezoneGlobalPicker(), TimezoneOption

### Community 39 - "Community 39"
Cohesion: 0.17
Nodes (9): SessionMetricsData, WithSession, sessionMetricsQuery, WithSessionDetailProps, WithSessionMetricsData, CircleMetricsSessionDetail(), WithBackButtonProps, transformBreakouts() (+1 more)

### Community 40 - "Community 40"
Cohesion: 0.25
Nodes (5): circleQuery, GetMembersProps, useGetMembers(), GetMembersProps, isLocalDevEnvironment()

### Community 41 - "Community 41"
Cohesion: 0.20
Nodes (8): MemberStatus(), MemberStatusProps, ParsedForumMemberForStatus, MemberStatusViewProps, constitutionQueries, useGetConstitutionLink(), OpsRequestFormParams, useGetOpsRequestFormConstitutionLink()

### Community 42 - "Community 42"
Cohesion: 0.19
Nodes (3): CirclesRetreatModalProps, MemberCardType, CirclesRetreatMenuProps

### Community 43 - "Community 43"
Cohesion: 0.18
Nodes (4): ForumCardType, ForumImageUploadOverlayPhase, ForumImageUploadOverlayProps, mvpQueries

### Community 44 - "Community 44"
Cohesion: 0.18
Nodes (7): forumMutations, forumQueries, FORUM_IMAGE_POST_UPLOAD_POLL_DELAYS_MS, ForumImageUploadUiState, RelForumUpsertInput, SignatureImageQueryData, UseForumMutationsOptions

### Community 45 - "Community 45"
Cohesion: 0.27
Nodes (10): ForumRetreatStore, AttendedRetreatInfo, ProfileAttendedRetreats, RelPerson, RelProfile, RelRetreatObject, RelRetreatProfileNodeConnection, RelRetreatProfileNodeEdge (+2 more)

### Community 46 - "Community 46"
Cohesion: 0.19
Nodes (6): getSessions(), session, users, KeyMetricsExample, CircleMetricsSummaryExample, ScrollableContainerBorderProps

### Community 47 - "Community 47"
Cohesion: 0.24
Nodes (6): WithBreakoutSessionsProps, BreakoutSessions, LayoutHint, WithLayoutHint, makeStyle(), SurfaceWrappedChild()

### Community 48 - "Community 48"
Cohesion: 0.24
Nodes (6): OvalsBottomLeft(), OvalsTopRight(), OvalTopLeft(), PoweredByCircles(), useScaleImage(), YPOLogo()

### Community 49 - "Community 49"
Cohesion: 0.18
Nodes (6): ForumIdentityPanelProps, ForumImageWithMenuProps, DEFAULT_ICON_BUTTON_STYLE, ForumPopoverIconMenu, ForumPopoverIconMenuProps, SetChosenNameModalProps

### Community 50 - "Community 50"
Cohesion: 0.32
Nodes (9): CircleMetricsPanel(), ViewType, DateLineTypes, DateLine(), DEFAULT_END_DATE, DEFAULT_START_DATE, getDateFromStorage(), removeDatesFromStorage() (+1 more)

### Community 51 - "Community 51"
Cohesion: 0.33
Nodes (6): MemberItemProps, MemberItemProps, MemberPortrait(), NavBarPortraitProps, PortraitData, getPortrait()

### Community 52 - "Community 52"
Cohesion: 0.25
Nodes (4): DashboardPage(), getData(), Window, NavStore

### Community 53 - "Community 53"
Cohesion: 0.20
Nodes (9): CancelMeetingDialog(), useSessionFormState(), UseSessionFormStateProps, RescheduleMeetingDialog(), useFormatDisplayedTimezone(), useRescheduleMeetingTimezoneSelector(), TIMEZONES_QUERY, useTimezones() (+1 more)

### Community 54 - "Community 54"
Cohesion: 0.22
Nodes (8): ForumPane(), useHandleForumPaneResize(), useSelectedMemberDetails(), useQueryFeatureFlags(), MemberList(), useForumMembers(), featureFlagsQueries, useNavigateComponentParams()

### Community 55 - "Community 55"
Cohesion: 0.24
Nodes (5): MemberItem(), MemberItemProps, useCachedPortrait(), RetreatMemberItem(), TooltipProps

### Community 56 - "Community 56"
Cohesion: 0.31
Nodes (6): ForumList(), ForumListProps, ForumLoadingPane(), LoginContainer(), MotionConfig, useMotionProps()

### Community 57 - "Community 57"
Cohesion: 0.31
Nodes (7): RescheduleConfirmationDialog(), RescheduleConfirmationDialogProps, ValidDateInput, RescheduleSuccessDialog(), RescheduleSuccessDialogProps, haveOptionalDatesChanged(), getTimezoneAbbreviation()

### Community 58 - "Community 58"
Cohesion: 0.28
Nodes (4): DevPanel(), DevStoreState, useDevStore, MultiForumDashboard()

### Community 60 - "Community 60"
Cohesion: 0.22
Nodes (3): DurationPickerButtonProps, TimepickerButtonProps, RescheduleInputRowProps

### Community 61 - "Community 61"
Cohesion: 0.29
Nodes (7): AccessDenied(), ChatlioManager(), useCirclesChatlio(), useInitCirclesChatlioUI(), useNavStore, ContactUsTile(), SupportModal()

### Community 62 - "Community 62"
Cohesion: 0.32
Nodes (3): nextSessionQueries, Person, QuickJoin

### Community 63 - "Community 63"
Cohesion: 0.25
Nodes (4): RescheduleHeaderProps, RescheduleMeetingDialogProps, UseFormatDisplayedTimezoneProps, UseFormatDisplayedTimezoneReturn

### Community 64 - "Community 64"
Cohesion: 0.29
Nodes (6): JourneyStage, NotificationProps, useCompleteRetreatWorkflowNotifications(), workflowNotification, WorkflowNotificationParams, useCreateCompleteRetreatDialog()

### Community 65 - "Community 65"
Cohesion: 0.29
Nodes (3): CirclesRetreatGuideSurveyModalProps, forumMutations, useMarkRetreatComplete()

### Community 66 - "Community 66"
Cohesion: 0.43
Nodes (4): createLoginClient(), CirclesAuthClient(), getData(), LoginPage()

### Community 67 - "Community 67"
Cohesion: 0.33
Nodes (3): TalkTimeData, TalkTimeExample, TalkTimeProps

### Community 68 - "Community 68"
Cohesion: 0.40
Nodes (4): ForumDashboard(), MYFQueries, useMYFUsers(), isMobileOrSmallScreen()

### Community 69 - "Community 69"
Cohesion: 0.33
Nodes (5): QueryManager(), MainPageContents(), useForumState(), useGetPersons(), NavBar()

### Community 71 - "Community 71"
Cohesion: 0.40
Nodes (3): forumSubscriptions, RetreatData, RetreatStore

### Community 72 - "Community 72"
Cohesion: 0.33
Nodes (3): ForumIdentityPanel(), useDateTimeDisplay(), useTimezoneStore

### Community 73 - "Community 73"
Cohesion: 0.50
Nodes (3): CirclesRouter(), loginQueries, UseInitialize()

### Community 75 - "Community 75"
Cohesion: 0.67
Nodes (3): convertToSelectedTimeZone(), GuideHubCalendar(), GuideHubCalendarProps

### Community 77 - "Community 77"
Cohesion: 0.50
Nodes (3): { join }, { setupHoneybadger }, withNextIntl

### Community 78 - "Community 78"
Cohesion: 0.50
Nodes (3): name, private, version

### Community 79 - "Community 79"
Cohesion: 0.50
Nodes (3): assignedMembers, localUser, noteGroups

## Knowledge Gaps
- **1334 isolated node(s):** `config`, `{ join }`, `withNextIntl`, `{ setupHoneybadger }`, `name` (+1329 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **13 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `UseLogger()` connect `Community 28` to `Session Scheduling Hooks`, `Notes & Error/Notification Store`, `Retreat Planner`, `Forum Dashboard (responsive)`, `Dashboard Container & Global Store`, `Forum Breadcrumbs & Panes`, `Dashboard Containers & JWT`, `Next Session Rescheduler`, `Community 22`, `Community 30`, `Community 32`, `Community 36`, `Community 39`, `Community 40`, `Community 41`, `Community 50`, `Community 51`, `Community 54`, `Community 55`, `Community 61`, `Community 64`, `Community 65`, `Community 68`, `Community 69`, `Community 70`, `Community 73`?**
  _High betweenness centrality (0.030) - this node is a cross-community bridge._
- **Why does `ForumData` connect `Retreat Planner` to `Guide Home & Custom URL`, `Community 43`, `Dashboard Container & Global Store`, `Retreat Display & History`, `Forum Breadcrumbs & Panes`, `Reschedule/Cancel Dialogs`, `Community 23`, `Community 56`, `Community 24`, `Community 30`?**
  _High betweenness centrality (0.016) - this node is a cross-community bridge._
- **Why does `ParsedForumMemberForDetails` connect `Forum Member Details` to `Forum Breadcrumbs & Panes`, `Community 51`, `Community 37`?**
  _High betweenness centrality (0.014) - this node is a cross-community bridge._
- **What connects `config`, `{ join }`, `withNextIntl` to the rest of the system?**
  _1334 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Localization Strings (de)` be split into smaller, more focused modules?**
  _Cohesion score 0.0057306590257879654 - nodes in this community are weakly interconnected._
- **Should `Localization Strings (es)` be split into smaller, more focused modules?**
  _Cohesion score 0.005747126436781609 - nodes in this community are weakly interconnected._
- **Should `Localization Strings (en)` be split into smaller, more focused modules?**
  _Cohesion score 0.005747126436781609 - nodes in this community are weakly interconnected._