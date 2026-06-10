# ISSUE-406: Storybook / VRT coverage gap — harness exists, ~half the presentational surface is uncovered

- **Severity:** S3 (maintainability / missing regression safety net)
- **Status:** 🔵 investigate (coverage backlog — not a code change)
- **Area:** all workspaces / testing (`@repo/testing` VRT)
- **Found:** 2026-06-10 (per-directory story-coverage triage + 4 parallel Explore agents classifying presentational vs coupled components)

## Symptom
The VRT snapshot harness exists and works, but only **one** workspace (`packages/ccc`) is actually
wired to it, and across the monorepo only ~360 of the genuinely story-worthy presentational
components have a `*.stories.tsx`. Net effect: visual regressions ship unseen for most of the UI
surface — and the runtime-value half of **[ISSUE-302](ISSUE-302-ccc-dist-deep-imports.md)** is stalled
precisely because it's VRT-gated and the coverage isn't there to catch breakage.

## Evidence

### Two distinct gaps
1. **VRT-infra gap** — workspaces with stories but no Playwright wiring (only `ccc` is wired today).
2. **Story gap** — story-worthy components with no `*.stories.tsx`.

Snapshot functionality already lives in **`@repo/testing`** (`generateVisualTests`, `defineVRTConfig`,
`playwrightBase`, `ports.ts`). Wiring a workspace is ~3 small files + 5 scripts (ref: `packages/ccc/`):
`playwright.config.ts` → `defineVRTConfig("@circles/<pkg>")`; `tests/*.test.visual.ts` →
`generateVisualTests(storybook)`; the `storybook`/`build-storybook`/`test:visual`(+`:report`/`:update`)
scripts; a `ports.ts` entry; `@repo/testing` devDep.

### VRT-infra gap — workspaces that have stories but no wiring
| Workspace | existing stories | port |
|-----------|-----------------:|------|
| `packages/cui` | 47 | 6007 |
| `apps/circle-spaces` | 28 | 6002 (sb) |
| `packages/new-asb` | 13 | 6009 |
| `apps/circle-homepages` | 13 | 6001 (sb) |
| `packages/breakouts-panel` | 12 | 6005 |
| `packages/agenda-browser` | 7 | — (needs port) |
| `packages/cui-icons` | 5 | — (needs port) |
| `packages/agenda-editor` | 1 | 6004 |

Two apps have **no `.storybook/` at all**: `apps/my-circles` (88 components), `apps/arc` (17);
`isolated/circle-vault` (3, low priority) and `apps/circles-sponsor-management` (MVP/skip).

### Story gap — triaged counts (story-worthy only)
Raw uncovered `.tsx` is misleading: over half are providers, context wrappers, hook-only files,
barrels, route files, and Chime/Apollo/store-coupled containers that can't render in isolation.

| Workspace | uncovered | **story-worthy** | skipped |
|-----------|----------:|-----------------:|--------:|
| packages/cui | ~72 | **~70** | 2 |
| packages/cui-icons | 139 | 139 (1 gallery story today) | — |
| packages/new-asb | 101 | **74** | 27 |
| packages/agenda-browser | 37 | **33** | 4 |
| packages/agenda-editor | 22 | **4** | 18 (JS-only) |
| packages/breakouts-panel | 26 | **14** | 12 |
| packages/ccc (backfill) | 23 | **23** | 0 |
| apps/circle-spaces | ~190 | **68** | ~120 (Chime/store-coupled) |
| apps/circle-homepages | ~70 | **36** | ~34 (Apollo-coupled) |

**Total story-worthy gap: ~360 components** (vs ~680 raw uncovered `.tsx`).

## Mechanism
VRT was set up on `ccc` as the pilot and never rolled outward; stories accrue ad-hoc per feature work
rather than systematically. The shared harness makes per-workspace wiring cheap, so the gap is
backlog/prioritization, not a technical blocker.

## Blast radius
UI-wide. Any visual regression in an unwired workspace or unstoried component ships without a
snapshot catching it. Highest-value uncovered surface is the design system (`cui` 47 stories sitting
with zero snapshot coverage; ~70 more components unstoried) since it's consumed everywhere.

## Proposed fix (do not implement yet — this is a backlog)
Suggested order:
1. VRT-wire `packages/cui` (instant coverage for its 47 existing stories) + backfill its ~70
   story-worthy components — design-system core, biggest leverage.
2. Roll the `ccc`→`cui` wiring pattern to `breakouts-panel`, `agenda-browser`, `new-asb`.
3. Backfill `ccc` remainder (23 simple atoms/molecules — fast).
4. circle-spaces presentational leaves (survey, video-tile, mobile-layout display pieces).
5. circle-homepages presentational leaves (login panels, retreat modal, rescheduler panels).
6. Tier-1 `.storybook/` scaffold for `my-circles`.

When this work is scheduled it should graduate to a real ticket (Shortcut epic) for live tracking;
the per-component lists below are a **snapshot as of 2026-06-10**, not a live checklist.

## Effort / risk
Recording it carries no blast radius. Per-workspace wiring is ~30 min each (copy-paste + port).
Story authoring is the bulk of the effort — ~360 components, parallelizable per workspace.

---

## Story-worthy components (snapshot 2026-06-10)

### packages/cui — ~70
**AllSessionsDisplay:** OtherSessionCard, OtherSessionMenu ·
**CirclesPopover:** CirclesPopoverArrow, CirclesPopoverDivider, CirclesPopoverMenu, CirclesPopoverMenuButton, CirclesPopoverOwnerButton, CirclesPopoverSubMenu, PopoverVolumeSlider ·
**CuiAccordionPanel:** CuiAccordionPanel ·
**CuiHeader:** DropdownMenuItem, DropdownMenuItemButton, DropdownSubMenu, FullScreenButton, LeaveSessionButton, MediaTrackDetails ·
**CuiHeaderDropdown:** CuiHeaderDropdown ·
**CuiMenu:** CuiMenuButton, CuiMenuButtonContent, CuiMenuGroup ·
**CuiMenuBar:** CuiMenuBarButton, CuiMenuButtons/CuiFullScreen ·
**CuiMetricsTables:** CuiAttendanceMetricsTable, CuiBaseMetricsTable, CuiKeyMetricsTable ·
**CuiModernDateRangePicker:** CalenderSVG, CuiModernDateRangePicker, CalenderContainer, CalenderHeader, DateInput, DateInputContainer ·
**CuiModernProgressBar:** CuiModernProgressBarSection, AgendaSectionPopoverPane ·
**CuiModernSelectBar:** SelectBar, SelectDropdown, SelectDropdownContainer ·
**CuiMultiTab:** CuiTab · **CuiProgressBar:** CuiProgressBarSection ·
**Layouts:** GridColumn, GridRow · **NextSessionDisplay:** NextSessionDisplay ·
**ParticipantTimeZonePanel:** TimeZonePanelActionsFooter, TimeZonePanelHeader, TimeZonePlatter, TimeZonePlatterAvatar ·
**PresenterDashboard/BroadcastPanel:** BroadcastMessage, BroadcastMessageForm, BroadcastMessageList ·
**PresenterDashboard/Circle:** CircleInner, CircleMember, CircleName, CircleOuter ·
**PresenterDashboard/NotificationPanel:** Notification, NotificationList ·
**PresenterDashboard:** PanelHeader, Timespan ·
**Rescheduler:** NextSessionDetailsDisplay, SessionConfirmationPanel, SessionDurationRescheduler, SessionEditorDisplayModal, SessionRescheduleButton, SessionTimeRescheduler, SessionTimeZoneRescheduler, SessionTimeZoneSelector ·
**RetreatPlanner:** ConfirmAttendeeTile, ConfirmRetreatAttendanceDialog, FirstTimeRetreatConfirmationDialog, Retreat, RetreatConfirmationDialog, RetreatDatePicker, RetreatEditCompleteModal, RetreatEditDialog, RetreatErrorModal, RetreatScheduler, RetreatSchedulerText, WaveSelect
_(SKIP: CirclesIntlProvider, LogWrapper, ToggleablePanelWrapper)_

### packages/cui-icons — 139 icons
One consolidated `icons.stories.tsx` gallery today. Decision: keep one gallery (verify all 139 are
represented — lower effort, sufficient for catching icon regressions) vs per-icon stories for
isolated snapshots.

### packages/new-asb — 74
**Chat:** BotMessage, ChatCurve, ChatInitials, ChatInput, ChatMessage, ChatMessageList, ChatPane, SystemNotification, SystemMessage, MobileChatDisplay, ChatBubble, NewMessageAlert ·
**Trays/Media:** AVTray, AVTrayOptionsMenu, CommonMediaOptionsMenu, DocshareTray, MediaProgressBar, MediaTray, MediaTrayButton, ReviewNotesTray, ReviewSessionTray, ScreenshareTray, MediaButton, VolumeSliderButton ·
**MenuBar/Tools:** Agenda, FacilitatorTools, FullscreenButton, Help, MenuBar, Reactions, Share, TimerBar, Tools, AgendaTab, AgendaTabs, TabImage ·
**Notes:** AdvancedNoteComponent, AdvancedNoteGroupContainer, AdvancedNoteGroupHeader, AdvancedNoteHeader, NoteContainer, NoteGroupContainer, NoteGroupMenuPane, NoteHeaderMenuPane, NoteRightClickMenu, NotesContentResizeableTextArea, NotesHeader, NotesInput, NotesList, NotesPane, NotesResizeableTextArea, NotesResizeableInput, MassNotesMenuPane, SortNoteGroupsModal, SortNoteTile, MobileNotesPanel, MobileScratchpad, Pad, PadBubbleToolbar ·
**Sidebar/Surface:** AgendaSidebar, AgendaSidebarActiveDisplay, AgendaSidebarSurface, AgendaSidebarWrapper, ScrollBorder, ScrollableContainerBorder ·
**Modals/Menus:** DeleteConfirmationModal, FloatingModal, HeaderDropdownMenu, NoteDropdownMenu, SubHeaderDropdownMenu, AddGroupPane, AgendaSubmitButton, DeleteModalPane, ErrorModal, LeaveSessionModal, RenameGroupPane

### packages/agenda-browser — 33
Agenda, AgendaActionsPanel, AgendaBrowser, AgendaCollection, AgendaCollectionName, AgendaCollections, AgendaContextMenu, AgendaFolder, AgendaFolders, AgendaLinkModal, AgendaMenuCollectionName, AgendaMenuFolder, AgendaOpenWarningModal, AgendaPreview, AgendaSearchBar, AgendaSubfolder, Agendas, BrowserControlButtons, DeleteModal, EditAgendaLinkModal, ErrorModal, Footer, Header, LoadingModal, Main, Modal, MovePanel, Preview, RenameModal, RenderModalContent, SSO-links, SSOModal, loginComponent

### packages/agenda-editor — 4 (JS-only)
Button, EditorToolbar, custom-clicker, page-counter

### packages/breakouts-panel — 14
BreakoutsFooter, BreakoutsHeader, AssignBreakoutsModal, AutoAssignModal, BreakoutGroupDropdown, ContextMenu, DataLoadingModal, DeleteWarningModal, NewGroupModal, PanelLockModal, RenameGroupModal, ToggleablePanelWrapper, ShortUserTile, UserTile

### packages/ccc — 23 (backfill)
AnimatedCarousel, AnimatedCollapsable, AnimatedBackgroundContainer, SvgWavesBackground, Platter, PopupSurface, SecondaryPlatter, Rings, PopoverCheckboxOption, ToggleEntry, RangeInput, DateRange, CalendarDay, CalendarFormButtons, CalendarHeader, MetricsSessionCountHeader, TableColoredCircle, PopoverActionNotification, PopoverMenu, Link, TextSpan, PreSpacedText, TrafficLight

### apps/circle-spaces — 68
**HomePageFeatures:** BackgroundSelector, AnimatedLoadingText, GreenroomDecorativeText, AudioPreviewBar ·
**AgendaFeatures:** AgendaBrowserFloatingContainer, AgendaBrowserInline, AgendaContentHeader, AgendaContentWrapper ·
**ModernMobileLayouts:** MobileAgendaSectionDisplay, MobileAgendaTimerDisplay, FloatingControlButton, MobileLeaveSessionButton, MobileLowSignalIndicator, MobileModalDisplay, MobileModalFooter, MobileNotesDisplay, MobileScratchpadDisplay, MobileSidebarFooter, MobileSidebarHeader, ScrollBorder ·
**MediaIframe:** ClickTourPanel, CloseDocumentHeader ·
**EndSessionReview:** NextSessionPanel, NextSessionPanelHeader, ReschedulerPanel, RetreatConfirmationDialog, RetreatDatePickerPopover, RetreatDetailsPanel, RetreatEditDialog, RetreatInvitationsSentDialog, RetreatPlanning ·
**VideoTileButton:** NamePlate, PlusOneContainer ·
**CirclesSurveyFeatures:** FormTextArea, SurveyFooter, SurveyHeader, SurveyTextInput, SurveyValueButton, SurveyValuePicker, SurveyValuePickerTooltip ·
**VideoTile:** CircleShadowMask, CirclesVideoTooltip, RandomOrderCircle ·
**ParticipantAwareNoteTaking:** PantsGroupSelectPopover, PantsPopover, PantsResizableInput, PantsTextInput ·
**Inviter:** GuestButton, HelpButton, InputLabel, NameInput, WelcomeHeading ·
**Notifications:** ActiveDeviceSwitchedTooltip, NewDeviceAvailableTooltip, DeviceNotifications
_(CirclesLayout & Sidebar: all container/layout-coupled — skip. Errors: already covered.)_

### apps/circle-homepages — 36
**DashboardContainer:** UserTile, CirclesSpinner, LoadingSpinner, CirclesRetreatConfirmationModal, ConfirmMenu, RetreatModalFooter, RetreatModalHeader, RetreatUserCard, CirclesSearchbar, ForumSearchBar ·
**ForumDashboard:** BigScreenMode, ForumCircle, ForumGrid, SmallScreenMode (ForumShapes are pure SVG — optional) ·
**Login:** EmailSent, ForgotPasswordPanel, ForgotYourPassword, EmailLogin, LoginPanel, LoginTooltip, SSOLogin ·
**NextSessionRescheduler:** EnterCircleSpaceButton, NextSessionDetailsPanel, NextSessionHeader, NextSessionReschedulePanel ·
**NavBar:** NavBar · **Notifications:** BasicNotifications, NotificationDisplay · **SupportModal:** ContactUsTile
