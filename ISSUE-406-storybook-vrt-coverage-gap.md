# ISSUE-406: Storybook / VRT coverage gap — harness broadly wired, but ~half the presentational surface has no story

- **Severity:** S3 (maintainability / missing regression safety net)
- **Status:** 🔵 investigate (coverage backlog — not a code change)
- **Area:** all workspaces / testing (`@repo/testing` VRT)
- **Found:** 2026-06-10 (per-directory story-coverage triage + 4 parallel Explore agents classifying presentational vs coupled components)

## Symptom
The VRT snapshot harness is already **rolled out broadly** — 7 workspaces are fully wired
(`defineVRTConfig` + a `*.test.visual.*` + `test:visual` script). The dominant gap is **story
coverage, not infra**: across the monorepo only ~360 of the genuinely story-worthy presentational
components have a `*.stories.tsx`, so snapshots cover a fraction of the surface and most visual
regressions ship unseen. Two smaller infra gaps remain (`circle-spaces`, `cui-icons`). This also
keeps the runtime-value half of **[ISSUE-302](ISSUE-302-ccc-dist-deep-imports.md)** under-protected —
it's VRT-gated and `ccc`'s story coverage is partial.

## Evidence

### VRT infra is mostly DONE (not the gap)
Fully wired — `defineVRTConfig(...)` + a `*.test.visual.*` + `test:visual` script — **7 workspaces:**
`packages/cui`, `packages/ccc`, `packages/new-asb`, `packages/breakouts-panel`,
`packages/agenda-browser`, `packages/agenda-editor`, `apps/circle-homepages`.
(Per memory, only `ccc` additionally has the dual-browser/safari + turbo-prehook treatment; the
other six run the default chromium VRT.)

Remaining **infra** gaps (small):
- `apps/circle-spaces` — has `defineVRTConfig("circle-spaces")` + the `test:visual` script but **no
  `*.test.visual.*` file**, so it runs **zero** snapshots. One-line fix: add
  `tests/*.test.visual.ts` calling `generateVisualTests(storybook)` (28 stories would activate).
- `packages/cui-icons` — no `playwright.config.ts`, no `test:visual` script, no visual test → fully
  unwired despite 5 stories. Needs the standard copy-paste (ref `packages/ccc/`) + a `ports.ts` entry.
- `apps/my-circles` (88 components) and `apps/arc` (17) have **no `.storybook/` at all** — Storybook
  scaffold needed before any VRT. (`isolated/circle-vault` 3 cmp low-priority; `circles-sponsor-management` MVP/skip.)

### Story gap — the real backlog (triaged, story-worthy only)
Raw uncovered `.tsx` is misleading: over half are providers, context wrappers, hook-only files,
barrels, route files, and Chime/Apollo/store-coupled containers that can't render in isolation.
In the 7 already-wired workspaces, **every new story becomes a snapshot immediately — no wiring needed.**

### Story gap — MEASURED transitive coverage (2026-06-10)
The gap is now **measured**, not estimated, by a transitive-import-reachability tool
(`packages/testing/scripts/find-uncovered.mjs`): a component is covered if it has its own story OR
is rendered (directly/transitively) by a component a story renders. This replaces the old
"no own `*.stories.tsx`" estimate, which over-counted badly because composites already snapshot
their children.

| Workspace | old estimate ("story-worthy") | **MEASURED uncovered** | note |
|-----------|------------------------------:|-----------------------:|------|
| packages/agenda-browser | 33 | **0** | 7 stories already render 52/57 transitively |
| packages/breakouts-panel | 14 | **1** | essentially done |
| packages/ccc | 23 | **2** | both skip-worthy (flaky canvas, thin `TextSpan` wrapper); 3 net-new stories landed |
| packages/agenda-editor | 4 | **5** | JS-only |
| packages/new-asb | 74 | **26** | |
| **packages subtotal** | ~148 | **~34** | design-system packages are largely covered via composition |
| apps/circle-homepages | 36 | **167** ⚠️ | |
| apps/circle-spaces | 68 | **267** ⚠️ | |

**Packages are nearly done; the real work is in the apps.** ⚠️ But the app numbers are an *upper
bound of a different kind*: `find-uncovered` answers "is it rendered by a story?", **not** "can it be
storied at all?". Apps are full of Apollo/Chime/store-coupled containers that can't render in
isolation — so an app's measured-uncovered count must still be passed through the
presentational/isolatable filter (and the `gen-stories` flags) before it's a real backlog. For
packages (almost all presentational), measured-uncovered ≈ the real backlog.

### Tooling now exists (in `circles-frontend`, not this repo)
A self-checking pipeline was added to `@repo/testing` to make a big story pass safe:
`find-uncovered.mjs` (transitive dedup) → `gen-stories.mjs` (prop-aware scaffold; flags
`blank-risk` / `non-deterministic` / `fill:<prop>` / `no-component`) → `build-storybook` (tsc) →
`generateLoadTests` (new `pageerror` render-error gate, baseline-free). Run dedup first, always.

## Mechanism
The harness was rolled out to most workspaces, but **stories accrue ad-hoc per feature work** rather
than systematically — so wired workspaces snapshot only the components someone happened to story.
The gap is authoring backlog/prioritization, not a technical blocker.

## Blast radius
UI-wide. In the 7 wired workspaces, any regression in a *truly uncovered* component (not rendered by
any story) ships without a snapshot catching it; in `circle-spaces`/`cui-icons` nothing is snapshotted
at all. Highest-value uncovered surface is the design system — **`packages/ccc`** (the complex/animated
library that *survives cui's deprecation* and is the deep-import target in
[ISSUE-302](ISSUE-302-ccc-dist-deep-imports.md)), since it's consumed everywhere.

## Proposed fix (do not implement yet — this is a backlog)
**Do NOT start with cui — it is being deprecated** (earlier drafts of this issue led with cui; that
was wrong). For each target, first dedup *transitively* (drop components already rendered by an
existing story) before authoring. Suggested order:
1. Backfill `packages/ccc` net-new stories — already VRT-wired, design-system core, survives cui.
   (First trial pass done 2026-06-10: 3 net-new stories landed — `BasicDropdown`, `AnimatedCarousel`,
   `PopoverCheckboxOption` — after transitive dedup dropped 14 redundant + 1 flaky candidate.)
2. Close the two infra gaps: add the one-line visual-test file to `circle-spaces` (activates its 28
   stories) and do the standard wiring copy-paste for `cui-icons`.
3. Other wired packages (`new-asb`, `agenda-browser`, `breakouts-panel`) — transitive-dedup first.
4. circle-spaces presentational leaves (survey, video-tile, mobile-layout display pieces).
5. circle-homepages presentational leaves (login panels, retreat modal, rescheduler panels).
6. Tier-1 `.storybook/` scaffold for `my-circles`.
_(cui is intentionally omitted from this list — deprecating.)_

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
