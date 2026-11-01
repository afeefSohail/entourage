# entourage — Architecture & Refactor Guidelines

Decisions made in the Xcode AI chat session (claude-sonnet-4-5, Nov 2026).
Follow these when working on this project.

---

## Architecture: MVVM-C with Clean Architecture

Target architecture for the SwiftUI migration. Never propose VIPER — too verbose for this team size.

### Layer order (top → bottom)

| # | Layer | Technology |
|---|-------|-----------|
| 1 | Views | SwiftUI, `@Observable` |
| 2 | Screen ViewModels | `@MainActor`, `@Observable` |
| 3 | Coordinators | `NavigationStack`, `NavigationPath` |
| 4 | Use Cases / Interactors | `async/await` |
| 5 | Repositories | `protocol`-based |
| 6 | Services | Alamofire (API) · Firestore (Firebase) · SwiftData (local) |

### 3-Layer ViewModel pattern

Do not collapse these into a single ViewModel type:

1. **Domain Models** — pure `Codable` structs, zero UI logic (`Group`, `Match`, `User`, `MKMessage`)
2. **Model ViewModels** — live in `Core/Domain/ModelViewModels/`, one per domain model, wrap a single model with formatted strings, derived state, display colors (e.g. `GroupViewModel`, `MatchViewModel`)
3. **Screen ViewModels** — live in `Features/<Name>/ViewModels/`, orchestrate multiple Model VMs + user actions for one screen

### Folder structure

```
Core/
  Domain/
    Models/           ← Codable structs
    ModelViewModels/  ← presentation wrappers
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

---

## Features: What to remove / simplify

Remove these **before** touching architecture. Do not port them to the new stack.

### Remove entirely

| Feature | Why |
|---------|-----|
| Group Status System | ~400 lines, confusing UX, rarely used |
| Reset Other Group Status | Abuse vector, no clear benefit |
| Spotlight | Complex boost logic, marginal engagement |
| Instant Match | Bypasses the core swipe flow unnecessarily |
| Elite / Premium UI gates | Premature monetisation complexity |

### Simplify (keep core, cut sub-flows)

| Feature | What to cut |
|---------|-------------|
| Group Invitation | Drop accept/reject/delete sub-flows; keep simple invite |
| Report / Block | Drop image upload in the report flow |
| Contact Sync | Drop the 3-friend limit enforcement |

**Expected savings:** ~2,500–3,500 lines of code, 8–12 API endpoints eliminated.

---

## Execution sequence — do not reorder

**Option A (migrate then remove):** 12–14 weeks, 30–40% wasted effort. Do not use.  
**Option B (remove then migrate):** 10–12 weeks, 0% waste. Use this.

### Phase 1 — Feature Removal, UIKit (Weeks 1–3)

- Create a dedicated feature-removal branch
- Start with Spotlight (easiest quick win), test that matching still works
- Remove Instant Match, Elite gates, Group Status System, Reset Other Group Status
- Simplify Invitation, Report/Block, Contact Sync
- Do not change any architecture during this phase

### Phase 2 — Architecture Reorganisation, UIKit (Weeks 4–5)

- Split `WebServicesManager` into domain repositories (`UserRepository`, `GroupRepository`, `MatchRepository`, `ChatRepository`)
- Set up the folder structure above
- Introduce protocol-based repositories — still UIKit, zero SwiftUI risk

### Phase 3 — SwiftUI Migration (Weeks 6–12)

- Migrate screen by screen, lowest-risk first (settings, profile, then chat, then swipe)
- Use `@Observable` ViewModels, `NavigationStack` coordinator, `async/await` throughout
- Replace callback patterns in `MessageFirebaseService` with `async/await`

---

## Networking

`WebServicesManager` (~2,000+ lines) is to be split into:

- `UserRepository` — auth, profile, user lookup
- `GroupRepository` — group CRUD, member management
- `MatchRepository` — swipe decisions, match retrieval
- `ChatRepository` — wraps `MessageFirebaseService`, adds async API

Each repository takes its `APIService`/`FirebaseService` dependency via initializer (testable).

---

## Chat (Firebase)

`MessageFirebaseService<ChatMessage>` is the generic Firestore listener. Keep it; just wrap it behind `ChatRepository`. Path: `Message/{id}/ChatMessages`, ordered by `createdAt` ascending.

`ChatGroupVC` supports both personal group chat (`personalChat = false`) and match cross-group chat (`personalChat = true`). Preserve this distinction when migrating to SwiftUI.

---

## Swift conventions

- `@Observable` (iOS 17+) over `ObservableObject`/`@Published`
- `async/await` over callbacks everywhere new code is written
- `@MainActor` on Screen ViewModels
- `NavigationPath` for coordinator navigation stack
- `SwiftData` for local persistence (replaces any manual Codable caching)
