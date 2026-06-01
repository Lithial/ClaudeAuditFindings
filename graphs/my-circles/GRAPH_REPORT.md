# Graph Report - .  (2026-06-01)

## Corpus Check
- 170 files · ~0 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1313 nodes · 1650 edges · 50 communities (36 shown, 14 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 23 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Localization Strings (de)|Localization Strings (de)]]
- [[_COMMUNITY_Localization Strings (es)|Localization Strings (es)]]
- [[_COMMUNITY_Localization Strings (en)|Localization Strings (en)]]
- [[_COMMUNITY_GraphQL Clients & Notification Store|GraphQL Clients & Notification Store]]
- [[_COMMUNITY_Runtime Dependencies|Runtime Dependencies]]
- [[_COMMUNITY_Metrics Panel & Filters|Metrics Panel & Filters]]
- [[_COMMUNITY_GraphQL Types|GraphQL Types]]
- [[_COMMUNITY_JWTLogger & Client Metrics|JWT/Logger & Client Metrics]]
- [[_COMMUNITY_Agenda Tools Store|Agenda Tools Store]]
- [[_COMMUNITY_App Routes & Server Apollo|App Routes & Server Apollo]]
- [[_COMMUNITY_TypeScript Config|TypeScript Config]]
- [[_COMMUNITY_Root Layout & Error Boundary|Root Layout & Error Boundary]]
- [[_COMMUNITY_Modal Container & Logger|Modal Container & Logger]]
- [[_COMMUNITY_Circle Data Panel & Org Stores|Circle Data Panel & Org Stores]]
- [[_COMMUNITY_Session Metrics Detail|Session Metrics Detail]]
- [[_COMMUNITY_Metrics Data Hooks|Metrics Data Hooks]]
- [[_COMMUNITY_Login Store & JWT Management|Login Store & JWT Management]]
- [[_COMMUNITY_Circle List & Agenda Actions|Circle List & Agenda Actions]]
- [[_COMMUNITY_Community 18|Community 18]]
- [[_COMMUNITY_Community 19|Community 19]]
- [[_COMMUNITY_Community 20|Community 20]]
- [[_COMMUNITY_Community 21|Community 21]]
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
- [[_COMMUNITY_Community 43|Community 43]]
- [[_COMMUNITY_Community 47|Community 47]]

## God Nodes (most connected - your core abstractions)
1. `useLogger()` - 33 edges
2. `useLoginStore` - 24 edges
3. `compilerOptions` - 20 edges
4. `VisiblePanelOptions` - 17 edges
5. `useAgendaProps()` - 11 edges
6. `useCircleSelectStore` - 11 edges
7. `MetricsPanel()` - 8 edges
8. `AddMembersToCircleModal()` - 8 edges
9. `useNotifications()` - 8 edges
10. `rules` - 7 edges

## Surprising Connections (you probably didn't know these)
- `Error()` --calls--> `useLogger()`  [EXTRACTED]
  app/error.tsx → src/components/Logger/useLogger.tsx
- `EditCircleDetailsModal()` --calls--> `useEditCircle()`  [INFERRED]
  src/components/ModalContainer/Modals/EditCircleDetailsModal/EditCircleDetailsModal.tsx → src/queries/useEditCircle.ts
- `prefetchOrgData()` --calls--> `createServerApolloClient()`  [EXTRACTED]
  app/[locale]/page.tsx → src/utils/apolloClient/serverClient.ts
- `CircleMemberBlock()` --calls--> `useRemovePersonFromCircle()`  [INFERRED]
  src/components/CircleDataPanel/CircleMemberBlock.tsx → src/queries/useRemovePersonFromCircle.ts
- `DeleteCircleModal()` --calls--> `useDeleteCircle()`  [INFERRED]
  src/components/ModalContainer/Modals/DeleteCircleModal/DeleteCircleModal.tsx → src/queries/useDeleteCircle.ts

## Import Cycles
- None detected.

## Communities (50 total, 14 thin omitted)

### Community 0 - "Localization Strings (de)"
Cohesion: 0.01
Nodes (242): access-denied.contact-support, access-denied.no-permissions, access-denied.no-permissions-title, add-circle-modal.add-members, add-circle-modal.add-new-circle, add-circle-modal.circle-name, add-circle-modal.complete-edit, add-circle-modal.description (+234 more)

### Community 1 - "Localization Strings (es)"
Cohesion: 0.01
Nodes (242): access-denied.contact-support, access-denied.no-permissions, access-denied.no-permissions-title, add-circle-modal.add-members, add-circle-modal.add-new-circle, add-circle-modal.circle-name, add-circle-modal.complete-edit, add-circle-modal.description (+234 more)

### Community 2 - "Localization Strings (en)"
Cohesion: 0.01
Nodes (242): access-denied.contact-support, access-denied.no-permissions, access-denied.no-permissions-title, add-circle-modal.add-members, add-circle-modal.add-new-circle, add-circle-modal.circle-name, add-circle-modal.complete-edit, add-circle-modal.description (+234 more)

### Community 3 - "GraphQL Clients & Notification Store"
Cohesion: 0.05
Nodes (22): createAnonClient(), createLoginClient(), CircleMemberAvatar(), CircleMemberAvatarProps, NotificationState, NotificationStore, useNotificationStore, CirclesAnonClient() (+14 more)

### Community 4 - "Runtime Dependencies"
Cohesion: 0.04
Nodes (48): dependencies, agenda-browser, agenda-editor, @apollo/client, @circles/ccc, @circles/cui, classnames, date-fns (+40 more)

### Community 5 - "Metrics Panel & Filters"
Cohesion: 0.07
Nodes (14): BreadcrumbsProps, MetricsFiltersProps, MetricsOverview(), MetricsOverviewProps, scoreColor(), AttendanceMetricsPanelProps, BaseMetricsPanelProps, CircleLevelDatePickerProps (+6 more)

### Community 6 - "GraphQL Types"
Cohesion: 0.06
Nodes (34): BreakoutGroupAttendee, BreakoutGroupType, BreakoutMetricsInput, BreakoutMetricsResult, BreakoutSession, CircleAddParticipantResponse, CircleMembersResult, CircleMembersVariables (+26 more)

### Community 7 - "JWT/Logger & Client Metrics"
Cohesion: 0.09
Nodes (11): generateJWTSocket(), modifyHeadersForEventInitiator(), CirclesJwtClient(), ClientDataType, UseClientMetricsData(), StorageType, useStorage(), hasSubscription() (+3 more)

### Community 8 - "Agenda Tools Store"
Cohesion: 0.11
Nodes (16): AgendaPanelStoreState, AgendaStore, EditedAgenda, MutationError, useAgendaProps(), agendaMutations, agendaQueries, createUniqueAgendaName() (+8 more)

### Community 9 - "App Routes & Server Apollo"
Cohesion: 0.11
Nodes (19): createServerApolloClient(), CirclesLocalization(), getMessages(), getData(), Home(), prefetchOrgData(), getData(), LoginPage() (+11 more)

### Community 10 - "TypeScript Config"
Cohesion: 0.07
Nodes (26): compilerOptions, allowJs, baseUrl, esModuleInterop, forceConsistentCasingInFileNames, incremental, isolatedModules, jsx (+18 more)

### Community 11 - "Root Layout & Error Boundary"
Cohesion: 0.11
Nodes (8): metadata, ErrorBoundary, ErrorBoundaryProps, ErrorBoundaryState, Logger(), MetricsTypes, UploadLineFn, UploadMetricsFn

### Community 12 - "Modal Container & Logger"
Cohesion: 0.18
Nodes (4): BaseModal(), ModalContainer(), useDialogToggle(), useRegisterModal()

### Community 13 - "Circle Data Panel & Org Stores"
Cohesion: 0.22
Nodes (4): CircleSelectStore, OrgStore, VALID_TABS, OrgQueries

### Community 14 - "Session Metrics Detail"
Cohesion: 0.16
Nodes (9): SessionMetricsDetail(), SessionMetricsDetailProps, getAllAttendees(), getGroupIdentifier(), getGroupInitiator(), InitiatorReference, makeInitiatorInfo(), transformBreakouts() (+1 more)

### Community 15 - "Metrics Data Hooks"
Cohesion: 0.18
Nodes (7): useMetricsFilter(), circleMetricsQuery, useGetCircleMetricsData(), UseGetCircleMetricsDataProps, useGetOrgMetricsData(), useGetSessionMetrics(), MetricsPanel()

### Community 16 - "Login Store & JWT Management"
Cohesion: 0.19
Nodes (5): LoginStore, LoginContainerProps, loginMutations, LoginPane(), NavbarRoomEntryBtn()

### Community 17 - "Circle List & Agenda Actions"
Cohesion: 0.20
Nodes (13): Error(), BulkAddCirclesModal(), useProcessCSVData(), CircleListItem(), DeleteCircleModal(), useAgendaStore, UseAgendaActions(), useAgendaEditorProps() (+5 more)

### Community 18 - "Community 18"
Cohesion: 0.14
Nodes (13): id, name, orgId, id, name, orgId, id, name (+5 more)

### Community 19 - "Community 19"
Cohesion: 0.15
Nodes (12): extends, ignorePatterns, parser, plugins, root, rules, import/order, @next/next/no-img-element (+4 more)

### Community 20 - "Community 20"
Cohesion: 0.15
Nodes (3): useGetRolesInOrg(), MetricsLoadingSpinnerProps, TabbedDisplay()

### Community 21 - "Community 21"
Cohesion: 0.30
Nodes (12): CircleDataPanel(), EnvManager(), useLoginStore, useOrgStore, useUrlState(), UseJwt(), UseLogin(), OrgPickerModal() (+4 more)

### Community 22 - "Community 22"
Cohesion: 0.26
Nodes (5): CircleMemberInput, CSVRow, NewCircleReviewPane(), NewCircleReviewPaneProps, processNewCircleData()

### Community 23 - "Community 23"
Cohesion: 0.22
Nodes (9): CircleQueryResult, PersonQueryResult, Circle, Member, Organization, OrganizationRole, Participant, PortraitData (+1 more)

### Community 25 - "Community 25"
Cohesion: 0.32
Nodes (4): NavBar(), useCachedPortrait(), personQueries, useGetPersons()

### Community 26 - "Community 26"
Cohesion: 0.46
Nodes (8): CircleDataPanelHeaderMenu(), CircleMemberBlock(), EditCircleDetailsModal(), useCircleSelectStore, usePermissions(), BottomNavBar(), useGetCircle(), SendSessionDetailsModal()

### Community 27 - "Community 27"
Cohesion: 0.32
Nodes (7): AddMembersToCircleModal(), AddNewCircleModal(), useBulkCreateCircles(), useHandleMembersProps(), useAddPersonToCircle(), useCreateManyCircles(), useCreateNewPeople()

### Community 30 - "Community 30"
Cohesion: 0.40
Nodes (5): CircleAddRemoveParticipantInput, RemovePersonFromCircleVariables, RolesOnlyQueryResult, RoleEntityType, RoleType

### Community 34 - "Community 34"
Cohesion: 0.50
Nodes (3): BaseModalProps, DialogProps, RegisterDialogProps

## Knowledge Gaps
- **896 isolated node(s):** `publicPaths`, `config`, `__dirname`, `nextConfig`, `name` (+891 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **14 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `useLoginStore` connect `Community 21` to `Community 33`, `JWT/Logger & Client Metrics`, `Agenda Tools Store`, `Metrics Data Hooks`, `Login Store & JWT Management`, `Circle List & Agenda Actions`, `Community 20`, `Community 25`, `Community 26`, `Community 27`?**
  _High betweenness centrality (0.038) - this node is a cross-community bridge._
- **Why does `useLogger()` connect `Circle List & Agenda Actions` to `GraphQL Clients & Notification Store`, `JWT/Logger & Client Metrics`, `Agenda Tools Store`, `Community 40`, `Root Layout & Error Boundary`, `Modal Container & Logger`, `Login Store & JWT Management`, `Community 21`, `Community 25`, `Community 26`, `Community 27`, `Community 29`?**
  _High betweenness centrality (0.025) - this node is a cross-community bridge._
- **Why does `EnvManager()` connect `Community 21` to `Login Store & JWT Management`?**
  _High betweenness centrality (0.017) - this node is a cross-community bridge._
- **What connects `publicPaths`, `config`, `__dirname` to the rest of the system?**
  _896 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Localization Strings (de)` be split into smaller, more focused modules?**
  _Cohesion score 0.00823045267489712 - nodes in this community are weakly interconnected._
- **Should `Localization Strings (es)` be split into smaller, more focused modules?**
  _Cohesion score 0.00823045267489712 - nodes in this community are weakly interconnected._
- **Should `Localization Strings (en)` be split into smaller, more focused modules?**
  _Cohesion score 0.00823045267489712 - nodes in this community are weakly interconnected._