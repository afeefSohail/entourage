# entourage — Architecture & Refactor Guidelines

Three phases, in order. Do not start a later phase until the previous one is complete.
Never reference timelines or week numbers when implementing.

**Rules:**
- Always changes should be commit and push In AI-Dev Branch.
- Never push claude signature with commit.
---

## Phase 1 — Feature Removal (UIKit, no architecture changes)

Remove these features entirely. Do not port them to the new stack.

| Feature | Why |
|---------|-----|
| Group Status System | ~400 lines, confusing UX, rarely used |
| Reset Other Group Status | Abuse vector, no clear benefit |
| Spotlight | Complex boost logic, marginal engagement |
| Instant Match | Bypasses the core swipe flow unnecessarily |
| Elite / Premium UI gates | Premature monetisation complexity |

Simplify these (keep the core, cut the sub-flows):

| Feature | What to cut |
|---------|-------------|
| Group Invitation | Drop accept/reject/delete sub-flows; keep simple invite |
| Report / Block | Drop image upload in the report flow |
| Contact Sync | Drop the 3-friend limit enforcement |

**Rules during Phase 1:**
- Do not change any architecture
- Do not introduce SwiftUI
- After each removal, verify that matching and chat still work
- Start with Spotlight — it is the easiest quick win

**Expected result:** ~2,500–3,500 lines deleted, 8–12 API endpoints gone.

---

## Phase 2 — Architecture Reorganisation (still UIKit)

Only start after Phase 1 is merged. No SwiftUI yet.

### Target folder structure

```
Core/
  Domain/
    Models/           ← Codable structs only, zero UI logic
    ModelViewModels/  ← presentation wrappers, one per model
    UseCases/
  Data/
    Repositories/
    Services/
Features/
  Swipe/
    Views/
    ViewModels/
  Chat/
    Views/
    ViewModels/
  Match/
  Profile/
  Group/
```

### Split WebServicesManager

`WebServicesManager` (~2,000+ lines monolith) splits into four repositories. Each takes its service dependency via initializer (testable via protocol).

- `UserRepository` — auth, profile, user lookup
- `GroupRepository` — group CRUD, member management
- `MatchRepository` — swipe decisions, match retrieval
- `ChatRepository` — wraps `MessageFirebaseService`, exposes async API

### 3-Layer ViewModel pattern

| Layer | Location | Responsibility |
|-------|----------|---------------|
| Domain Models | `Core/Domain/Models/` | Pure `Codable` structs, no UI |
| Model ViewModels | `Core/Domain/ModelViewModels/` | Formatted strings, derived state, display colors for one model |
| Screen ViewModels | `Features/<Name>/ViewModels/` | Orchestrates multiple Model VMs + user actions for one screen |

Never collapse these into a single ViewModel type.

---

## Phase 3 — SwiftUI Migration

Only start after Phase 2 is merged.

### Architecture: MVVM-C with Clean Architecture

Never propose VIPER — too verbose for this team size.

**Layer stack (Views → Services):**

| # | Layer | Technology |
|---|-------|-----------|
| 1 | Views | SwiftUI, `@Observable` |
| 2 | Screen ViewModels | `@MainActor`, `@Observable` |
| 3 | Coordinators | `NavigationStack`, `NavigationPath` |
| 4 | Use Cases / Interactors | `async/await` |
| 5 | Repositories | `protocol`-based |
| 6 | Services | Alamofire · Firestore · SwiftData |

### Coordinator pattern

```swift
enum Route: Hashable {
    case swipeGroups, matchDetail(Match), chat(Group), profile
}

@Observable class AppCoordinator {
    var path = NavigationPath()
    func push(_ route: Route) { path.append(route) }
    func pop() { path.removeLast() }
}
```

### Migration order

Migrate screen by screen, lowest-risk first:
1. Settings, Profile
2. Chat (`ChatGroupVC` → SwiftUI, keep personal/match dual-mode via `personalChat` flag)
3. Match detail
4. Swipe (highest risk — do last)

### Swift conventions

- `@Observable` (iOS 17+) over `ObservableObject` / `@Published`
- `async/await` everywhere new code is written; replace all callbacks
- `@MainActor` on Screen ViewModels
- `NavigationPath` for coordinator stack
- `SwiftData` for local persistence

### Chat (Firebase)

`MessageFirebaseService<ChatMessage>` stays as-is; wrap it behind `ChatRepository`.
Path: `Message/{id}/ChatMessages`, ordered by `createdAt` ascending.
`ChatGroupVC` supports personal group chat and match cross-group chat via `personalChat: Bool` — preserve this distinction in SwiftUI.

---

## Phase 4 — Onboarding SwiftUI Migration ✓ Complete

### What was done

Replaced all 11 UIKit onboarding ViewControllers and `onBoarding.storyboard` with SwiftUI views. `SceneDelegate` now sets `UIHostingController(rootView: RootRouter())` as the window root.

### New files

```
entourage/Features/Root/
  RootRouter.swift               ← switches between splash / onboarding / main

entourage/Features/Onboarding/
  AppState.swift                 ← @Observable, Phase enum (splash/onboarding/main)
  OnboardingCoordinator.swift    ← @Observable, NavigationStack + NavigationPath
  OnboardingView.swift           ← NavigationStack root, handles all destinations
  Views/
    SplashView.swift
    TutorialView.swift
    PhoneInputView.swift         ← wraps FPNTextField (FlagPhoneNumber CocoaPod)
    OTPView.swift                ← Firebase phone auth, 6-box custom UI
    GenderView.swift
    NameView.swift               ← reused for first name and last name (isLastName flag)
    BirthdayView.swift
    PhotosView.swift             ← PhotosPicker, LazyVGrid, uploadPhoto API
    UsernameView.swift           ← debounced availability check
    ContactsPermissionView.swift
    OnboardingAddFriendsView.swift
    UserBannedView.swift
```

### Deleted

- `entourage/Storyboards/Base.lproj/onBoarding.storyboard`
- All 17 files under `entourage/ViewController/onBoardingVC/`
- All onboarding `load*VC` methods from `Ext+LoadVC.swift`
- `switchToMain()` and `switchToOnBoarding()` from `Utils.swift` (replaced by `appState.phase`)

### SPM packages removed

| Package | Reason |
|---------|--------|
| KAPinField | Replaced by custom SwiftUI OTP boxes |
| FittedSheets | No longer needed |
| SwiftDate | Replaced by `Calendar.current.component` and `DateFormatter` |
| Kingfisher | Replaced by `URLSession.shared.dataTask` and SwiftUI `AsyncImage` |

### CocoaPods still required

`FlagPhoneNumber` — used in `PhoneInputView.swift` for the country-code picker.

### Key patterns used

- `@Observable` for `AppState` and `OnboardingCoordinator` (iOS 17+)
- `withCheckedThrowingContinuation` to bridge callback-based `WebServicesManager` calls into `async/await`; always annotate the continuation type explicitly: `(cont: CheckedContinuation<Void, Error>)`
- `SwiftUI.Group` (fully qualified) to avoid conflict with the app's own `class Group: Codable`

---

## Phase 5 — Group Invitation Simplification

Only start after Phase 3 is merged.

### Goal

Replace the accept/reject invitation model with a direct add + opt-out model.
Saves ~500–800 lines of code that would otherwise need to be migrated to SwiftUI.

### What to delete

| Code | Location |
|------|----------|
| `acceptGroupInvite()` | `GroupRepository`, `RepositoryAsync`, `WebservicesManager` |
| `rejectGroupInvite()` | `GroupRepository`, `RepositoryAsync`, `WebservicesManager` |
| `groupInviteRequestes` array | `EntourageManager` |
| `pendingGroupInvitation` field | `User`, `Friend` models |
| `invitedUsers` / `pending_approval` field | `Group` model |
| `group.allGroupMember()` pending logic | `Group` model |
| All invite-pending UI screens | `Features/Group/` |

### What to keep

- `addMember(groupId:friendsId:)` — group creator adds friends directly, no approval step
- `leaveGroup()` — the opt-out; any member can leave at any time

### New model

| Old | New |
|-----|-----|
| Creator invites → friend accepts/rejects | Creator adds → friend is immediately in the group |
| `group.invitedUsers` (pending) | Removed — `group.users` is the only member list |
| `groupInviteRequestes` notification | Removed — no pending state to notify about |
| Opt-in (accept required) | Opt-out (`leaveGroup` to exit) |

### API endpoints to drop

- `POST /api/v1/groups/accept_group_invitation`
- `DELETE /api/v1/groups/reject_group_invitation`

### Rules during Phase 5

- Backend is not built yet — frontend defines the contract; backend will be built to match
- `add_member` should put users directly into `group.users` with no pending state (backend must implement this)
- After removal, verify group creation and swipe flow still work end-to-end

---

## API Response Contract (backend not built yet — frontend defines this)

Every endpoint must wrap its response in this envelope:

```json
{ "meta": { "code": 200, "message": "Success" }, "data": { ... } }
{ "meta": { "code": 200, "message": "Success" }, "data": [ ... ] }
{ "meta": { "code": 422, "message": "Validation failed" }, "data": null }
```

### Swift types (already in `entourage/Models/APIResponse.swift`)

```swift
struct APIResponse<T: Decodable>: Decodable {
    var meta: Meta
    var data: T?
}

struct Meta: Decodable {
    var code: Int
    var message: String
}
```

### Rules

- `meta.code` is the canonical success/error signal — `200` is success, anything else is an error
- `data` is `null` (omitted) for endpoints that return nothing (delete, leave, logout)
- Pagination fields go inside `meta`: `current_page`, `total_pages`, `per_page`, `total_count`
- Once the backend adopts this contract, delete all envelope wrapper classes: `BaseUser`, `Settings`, `UpdatePhoto`, `MyGroup`, `OtherGroups`, `MyMatches`, `MyMatche`, `BaseFriendShip`, `FriendsWithInvitedUser`, `RequestFriends`, `FriendShip`
