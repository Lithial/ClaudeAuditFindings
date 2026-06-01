# Dashboard Containers & JWT

> 26 nodes · cohesion 0.12

## Key Concepts

- **useGlobalStore** (50 connections) — `src/components/GlobalStore/useGlobalStore.tsx`
- **NavBarContainer()** (7 connections) — `src/components/NavBar/NavBarContainer.tsx`
- **UseCheckLoggedIn()** (6 connections) — `src/components/NavBar/useCheckLoggedIn.tsx`
- **UseJwt()** (5 connections) — `src/components/JWTManagement/useJWT.ts`
- **useDevPanel()** (5 connections) — `src/components/Keybinds/useDevPanel.ts`
- **UseLogin()** (5 connections) — `src/components/Login/LoginPanel/useLogin.tsx`
- **useRetrieveNotesData()** (5 connections) — `src/components/DashboardContainer/NotesViewer/useRetrieveNotesData.ts`
- **ForumDashboardContainer()** (4 connections) — `src/components/DashboardContainer/DashboardContainer/ForumDashboardContainer.tsx`
- **NonForumDashboardContainer()** (4 connections) — `src/components/DashboardContainer/DashboardContainer/NonForumDashboardContainer.tsx`
- **CircleCrumb()** (4 connections) — `src/mfv/ForumBreadCrumbs/ForumBreadCrumb.tsx`
- **EmailLogin()** (4 connections) — `src/components/Login/LoginPanel/EmailLogin.tsx`
- **useGetPersonDetailsFromJwt()** (4 connections) — `src/components/NavBar/getPersonDetailsFromJWT.ts`
- **UseUrlQueryCircleData()** (4 connections) — `src/components/NavBar/useUrlQueryCircleData.ts`
- **UseValidateJwt()** (4 connections) — `src/components/NavBar/useValidateJWT.ts`
- **useGetParticipantLinks()** (4 connections) — `src/components/NextSessionRescheduler/NextSessionHooks/useGetParticipantLinks.ts`
- **useAssignAvatarBackground()** (4 connections) — `src/components/DashboardContainer/NotesViewer/useAssignAvatarBackground.tsx`
- **MultiForumViewPageContents()** (4 connections) — `src/mfv/PageContent/MultiForumViewPageContents.tsx`
- **ForumDataDevPanel()** (4 connections) — `src/components/DevPanel/Panels/ForumDataDevPanel.tsx`
- **useGetMembers()** (4 connections) — `src/mfv/hooks/useGetMembers.ts`
- **CirclesSessionSchedulerContainer()** (3 connections) — `src/components/DashboardContainer/CirclesSessionScheduler/CirclesSessionSchedulerContainer.tsx`
- **useGetHash()** (3 connections) — `src/components/hooks/useGetHash.ts`
- **LoginManager()** (3 connections) — `src/mfv/Login/LoginManager.tsx`
- **LoginPane()** (3 connections) — `src/mfv/Login/LoginPane.tsx`
- **useJwtManager()** (3 connections) — `src/mfv/Managers/useJWTManager.ts`
- **NavbarButtons()** (3 connections) — `src/mfv/NavBar/NavbarButtons.tsx`
- *... and 1 more nodes in this community*

## Relationships

- [[Community 28]] (20 shared connections)
- [[Dashboard Container & Global Store]] (14 shared connections)
- [[Forum Breadcrumbs & Panes]] (4 shared connections)
- [[Community 40]] (4 shared connections)
- [[Notes & Error/Notification Store]] (4 shared connections)
- [[Community 61]] (3 shared connections)
- [[Community 69]] (3 shared connections)
- [[Login & Auth Panels]] (3 shared connections)
- [[Community 62]] (2 shared connections)
- [[Next Session Rescheduler]] (2 shared connections)
- [[Community 36]] (2 shared connections)
- [[Community 54]] (2 shared connections)

## Source Files

- `src/components/DashboardContainer/CirclesSessionScheduler/CirclesSessionSchedulerContainer.tsx`
- `src/components/DashboardContainer/DashboardContainer/ForumDashboardContainer.tsx`
- `src/components/DashboardContainer/DashboardContainer/NonForumDashboardContainer.tsx`
- `src/components/DashboardContainer/NotesViewer/useAssignAvatarBackground.tsx`
- `src/components/DashboardContainer/NotesViewer/useRetrieveNotesData.ts`
- `src/components/DevPanel/Panels/ForumDataDevPanel.tsx`
- `src/components/GlobalStore/useGlobalStore.tsx`
- `src/components/JWTManagement/useJWT.ts`
- `src/components/Keybinds/useDevPanel.ts`
- `src/components/Login/LoginPanel/EmailLogin.tsx`
- `src/components/Login/LoginPanel/useLogin.tsx`
- `src/components/Managers/ParameterManager/ParamManager.tsx`
- `src/components/NavBar/NavBarContainer.tsx`
- `src/components/NavBar/getPersonDetailsFromJWT.ts`
- `src/components/NavBar/useCheckLoggedIn.tsx`
- `src/components/NavBar/useUrlQueryCircleData.ts`
- `src/components/NavBar/useValidateJWT.ts`
- `src/components/NextSessionRescheduler/NextSessionHooks/useGetParticipantLinks.ts`
- `src/components/hooks/useGetHash.ts`
- `src/mfv/ForumBreadCrumbs/ForumBreadCrumb.tsx`

## Audit Trail

- EXTRACTED: 152 (100%)
- INFERRED: 0 (0%)
- AMBIGUOUS: 0 (0%)

---

*Part of the graphify knowledge wiki. See [[index]] to navigate.*