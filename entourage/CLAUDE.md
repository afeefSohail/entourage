# Entourage — Developer Guide

## What is Entourage?

Entourage is a **group-based social matching app**. Users form small groups, those groups swipe on other groups, and when two groups match they can chat. Think Tinder, but you bring your friends.

Core loop:
1. User creates or joins a group
2. Group swipes left/right on other groups
3. Mutual swipe → match
4. Matched groups can chat
5. Users can also add friends directly (contact sync)

---

## Rules

- Always commit and push changes to the **AI-Dev** branch.
- Never add a Claude signature (`Co-Authored-By`) to commits.
- Always use the same DerivedData folder for builds.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| UI | SwiftUI, `@Observable` (iOS 17+) |
| Navigation | `NavigationStack` + `NavigationPath` |
| Networking | Alamofire |
| Realtime / Auth | Firebase (Firestore + Phone Auth) |
| Phone input | FlagPhoneNumber (CocoaPod) |
| Local persistence | SwiftData |
| Async | `async/await` everywhere — no callbacks in new code |

**Minimum deployment: iOS 17**

---

## Architecture: MVVM-C + Clean Architecture

```
Views  →  Screen ViewModels  →  Use Cases  →  Repositories  →  Services
```

### Layer responsibilities

| Layer | Rule |
|-------|------|
| **Views** (SwiftUI) | Render state, forward actions. Zero business logic. |
| **Screen ViewModels** (`@MainActor @Observable`) | Drive one screen. Calls use cases, holds UI state. |
| **Repositories** (protocol-based) | Abstract data sources. One per domain area. |
| **Services** | Alamofire, Firestore, Firebase Auth. No business logic. |

### Coordinator pattern

```swift
enum Route: Hashable {
    case swipeGroups
    case matchDetail(Match)
    case chat(Group)
    case profile
}

@Observable
@MainActor
class AppCoordinator {
    var path = NavigationPath()
    func push(_ route: Route) { path.append(route) }
    func pop() { path.removeLast() }
    func popToRoot() { path.removeLast(path.count) }
}
```

`AppCoordinator` lives in `Core/Domain/AppCoordinator.swift`. Each feature area can have its own sub-coordinator for deep stacks (e.g. `OnboardingCoordinator`).

---

## Folder Structure

```
entourage/
  AppDelegate/
    AppDelegate.swift
    SceneDelegate.swift          ← sets UIHostingController(rootView: RootRouter())

  AppSupport/
    ActiveMemberSDK/             ← tracks online presence via Firebase
    ChatSDK/                     ← wraps MessageFirebaseService, exposes async API
    EntourageManager/            ← singleton: current user, session state
    FireBaseAuth/                ← phone OTP flow
    LastMessageSDK/              ← last-message listeners per conversation
    PhoneContacts/               ← CNContact access
    PushNotificationManager/     ← APNs + FCM token registration

  Core/
    Domain/
      AppCoordinator.swift       ← NavigationPath coordinator
    Data/
      Repositories/
        UserRepository.swift     ← auth, profile, user lookup
        GroupRepository.swift    ← group CRUD, member management
        MatchRepository.swift    ← swipe decisions, match retrieval
        ChatRepository.swift     ← wraps MessageFirebaseService
      Services/
        NetworkCore.swift        ← Alamofire session, base request

  Features/
    Root/
      RootRouter.swift           ← switches splash / onboarding / main
      AppRootView.swift          ← main tab bar after login

    Onboarding/
      AppState.swift             ← @Observable, Phase enum
      OnboardingCoordinator.swift
      OnboardingView.swift
      Views/
        SplashView.swift
        TutorialView.swift
        PhoneInputView.swift
        OTPView.swift
        GenderView.swift
        NameView.swift
        BirthdayView.swift
        PhotosView.swift
        UsernameView.swift
        ContactsPermissionView.swift
        OnboardingAddFriendsView.swift
        UserBannedView.swift

    Swipe/
      Views/
      ViewModels/

    Chat/
      Views/
        ChatView.swift           ← supports personal chat + match cross-group chat
      ViewModels/

    Match/
      MatchesListView.swift
      MatchDetailView.swift
      MatchesViewModel.swift

    Group/
      GroupManagementView.swift
      GroupManagementViewModel.swift
      AddGroupMemberView.swift

    Friends/
      FriendsView.swift
      FriendsViewModel.swift

    Profile/
      ProfileView.swift
      ProfileViewModel.swift
      EditProfileView.swift
      EditProfileViewModel.swift
      UserProfileView.swift
      BlockedUsersView.swift
      BlockedUsersViewModel.swift
      DeleteAccountView.swift
      UserActionAlertView.swift

    Settings/
      SettingsView.swift
      SettingsViewModel.swift
      FiltersView.swift

  FireBaseServices/
    MessageFirebaseService.swift       ← generic Firestore listener, keep as-is
    ActiveMemberFireBaseService.swift
    unReadMessageFirebaseService.swift

  Models/                              ← Codable structs only, zero UI logic
    User.swift
    Group.swift
    Match.swift
    ChatMessage.swift
    Photo.swift
    Friendships.swift
    GroupMember.swift
    LastMessage.swift
    ActiveMember.swift
    Setting.swift
    Contacts.swift
    APIResponse.swift
    PhotoProvider.swift
    Group+DisplayName.swift
    Group+Icon.swift
    User+ProfileCompletion.swift

  Helper/
    Constants/Constant.swift
    Extensions/Extensions.swift
    Extensions/UIColor+Ext.swift
    Helping Methods/HelpingMethods.swift
    Helping Methods/MsgReading.swift

  Theme/
    Color/ColorTheme.swift

  WebservicesManager/
    WebservicesManager.swift           ← legacy monolith; new code goes in Repositories

```

---

## Repositories

New networking code goes in `Core/Data/Repositories/`, not `WebservicesManager`.

```swift
protocol UserRepositoryProtocol {
    func currentUser() async throws -> User
    func updateProfile(_ update: ProfileUpdate) async throws -> User
}

final class UserRepository: UserRepositoryProtocol {
    static let shared = UserRepository()
    // Alamofire calls here
}
```

The four repositories:

| Repository | Owns |
|-----------|------|
| `UserRepository` | auth, profile, user lookup, friends |
| `GroupRepository` | group CRUD, members, swipe decisions |
| `MatchRepository` | match retrieval, match actions |
| `ChatRepository` | wraps `MessageFirebaseService`, async chat API |

---

## API Response Contract

Every endpoint returns this envelope:

```json
{ "meta": { "code": 200, "message": "Success" }, "data": { ... } }
{ "meta": { "code": 422, "message": "Validation failed" }, "data": null }
```

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

- `meta.code == 200` is the only success signal — not the HTTP status.
- `data` is omitted/null for endpoints that return nothing (delete, leave, logout).
- Pagination goes inside `meta`: `current_page`, `total_pages`, `per_page`, `total_count`.

---

## Swift Conventions

- `@Observable` over `ObservableObject` / `@Published`
- `@MainActor` on every Screen ViewModel
- `async/await` everywhere — `withCheckedThrowingContinuation` to bridge legacy callbacks
  - Always type the continuation explicitly: `(cont: CheckedContinuation<Void, Error>)`
- `SwiftUI.Group { }` — fully qualified to avoid collision with `class Group: Codable`
- Colors: `Color("themeColor")` — asset catalog name, not a static extension
- No comments unless the **why** is non-obvious

---

## Chat (Firebase)

`MessageFirebaseService<ChatMessage>` is the realtime Firestore listener. Keep it as-is; wrap it behind `ChatRepository` for new code.

- Firestore path: `Message/{conversationId}/ChatMessages`, ordered by `createdAt` ascending.
- `ChatView` supports two modes via `personalChat: Bool`:
  - `true` → personal group chat (members of the same group)
  - `false` → match cross-group chat (two matched groups talking)

---

## Group Model: Direct Add (no pending invitations)

The invite model is **direct add + opt-out**:

- Group creator adds friends directly → they are immediately in `group.users`
- Any member can call `leaveGroup()` to exit
- There is no accept/reject/pending state
- `group.users` is the only member list

---

## Onboarding

Entry point: `SceneDelegate` sets `UIHostingController(rootView: RootRouter())`.

`RootRouter` reads `AppState.phase` (`.splash` / `.onboarding` / `.main`) and switches the root view. `OnboardingCoordinator` drives the onboarding `NavigationStack`.

Phone number input uses `FPNTextField` (FlagPhoneNumber CocoaPod) wrapped in `UIViewRepresentable`. Country picker is a pure SwiftUI sheet over `FPNCountryRepository.countries`.

---

## Naming

| Thing | Convention |
|-------|-----------|
| Screen ViewModel | `<Feature>ViewModel` |
| Repository | `<Domain>Repository` |
| Route enum case | camelCase, e.g. `matchDetail(Match)` |
| View files | `<Feature>View.swift` |
