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

## Room (circle-spaces) story pass — SEQUENCED AFTER GraphQL codegen
circle-spaces already has the harness to story store-coupled components:
`apps/circle-spaces/.storybook/decorators/` — `withStorybookFlag` (sets `useStorybook.isStorybook`
so components skip the live Chime/Apollo connect side-effect *in effects, not render*),
`withZustandStore` (seed + restore store state, typed `Partial<T>`), `withApolloMocks`,
`withFrozenTime`, `withShelf`. Reference story: `AgendaStartDisplay.stories.tsx`.

The blocker for a *bigger* room pass is the Apollo half: `withApolloMocks` today takes hand-written,
**untyped** `MockedResponse[]` (operations are hand-rolled `gql` tags — `pdGraphql.ts`, `inviteGql.ts`
— with no codegen), so mocks drift silently against the schema. **Full GraphQL codegen for the room
(in progress) removes this.** Once it lands:

1. **Codegen config** → typed `TypedDocumentNode<Result, Vars>` for room operations + a mock-fixture
   plugin (e.g. `typescript-mock-data` or a `@graphql-tools/mock` builder) emitting per-type factories
   (`aMeetingState({ ...overrides })`).
2. **Upgrade `withApolloMocks`** → mocks built from typed documents are tsc-checked at the story
   (drift breaks `build-storybook`, not silently). Flip `addTypename: true` (generated fixtures include
   `__typename`) — also clears the deferred Apollo-4 migration note in that decorator.
3. **Authoring per component** (unchanged pipeline, +codegen mocks): `find-uncovered.mjs` →
   filter to **store/Apollo-coupled presentational** → `gen-stories.mjs` + `withStorybookFlag` +
   `withZustandStore(seed)` + `withApolloMocks(typedMocks)` + `action()` handlers + args for states →
   `withFrozenTime` + `generateLoadTests` gate.

**Determinism rule:** generated/automocked data must be fixed-value or pinned-seed, or VRT snapshots
flake — prefer explicit generated fixtures over random automock for snapshotted stories.

**Explicitly out of scope for this pass:** live **Chime media** (MediaStream / video tiles / canvas —
GraphQL codegen is irrelevant to WebRTC; no pixel without a stream) and **Absinthe subscriptions**
(codegen types them, but mocking a stream of frames per story is more than a query mock). Both stay
E2E / live-app.

**Sequencing:** do the room pass *after* codegen merges. Until then the available story work is the
covered-via-composition-light packages — `new-asb` (26 measured) and `agenda-editor` (5); ccc /
agenda-browser / breakouts-panel are effectively done.

---

## circle-homepages story pass — harness PORTED (2026-06-10)
Homepages is VRT-wired and the decorator harness was ported from circle-spaces:
`apps/circle-homepages/.storybook/decorators/` now has `withZustandStore` + `withFrozenTime`, with the
`@sb-decorators` alias wired in `main.ts` + `tsconfig.json`. Apollo is already mocked globally via
`MockedProvider`; react-intl is provided per-story by wrapping in `CirclesLocalization`. **No
`withStorybookFlag` needed** — homepages has no Chime/WS connect to suppress; its couplings are just
Zustand (`useGlobalStore`) + Apollo. Proven end-to-end: `EnterCircleSpaceButton.stories.tsx`
(build-storybook OK + `generateLoadTests` gate passed with seeded store state).

**Calibrated backlog** (measured uncovered 167; agent triage `STORY-NOW` was ~2× optimistic — same
over-count as ccc's "23→3", verified down):
- **~66 HOLD** — everything under `src/mfv/` (in-progress multi-forum-view / sponsor area). 40% of the
  gap; don't story a moving target.
- **~35–40 STORY-NOW** — presentational (props or clean `useGlobalStore`-coupled): `ForumShapes` (6 SVG),
  tiles/modals/notifications (`UserTile`, `ForumUserTile`, `RetreatUserCard`, `RetreatModal*`,
  `ContactUsTile`, `BasicNotifications`, `NotificationDisplay`, `Tooltip`, `LoginTooltip`,
  `NextSessionHeader`, login panes, `CirclesSpinner`, `CirclesSearchbar`).
- **~30 NEEDS-APOLLO-MOCKS** — render real content only with query data (`DashboardSwitcher` and the
  dashboard/metrics containers it pulls in, `ForumOverview`, `ForumPlanning`, …). Codegen-gated, same as
  the room — defer until homepages gets typed mocks.
- **~25 SKIP-INFRA** — providers / managers / GraphQL clients / routers / hooks / store defs.

### Highest-leverage homepages follow-up: bump `moduleResolution` → `"bundler"`
homepages `tsconfig.json` uses `moduleResolution: "node"`, which can't resolve `@storybook/react` /
`@repo/testing` types (exposed only via package `exports`). That's why every homepages story uses
`// @ts-nocheck` and the VRT test file needs `// @ts-ignore`, and why the ported decorators use a local
`Decorator` type instead of importing it. Build/runtime are fine (vite uses bundler resolution); this is
tsc/IDE only. Bumping to `"bundler"` (what circle-spaces uses) clears all of it at once and unlocks
*typed* stories (`Meta`/`StoryObj`, type-checked args). App-wide blast radius → its own validated PR,
not a ride-along.

### my-circles
Still **Tier-1** (no `.storybook/` at all → scaffold + VRT wiring + first stories before any harness).
Confirmed a keeper (active, just new — not deprecating like cui). Do it after homepages proves the
flagless pattern; the same `withZustandStore`/`withApolloMocks` harness applies once scaffolded.

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
