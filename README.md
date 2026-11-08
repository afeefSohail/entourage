# Entourage

**Group-based social matching — swipe as a crew, match as a crew.**

Entourage is an iOS app that flips the solo-dating model on its head. You create a small group with your friends, then your group swipes on other groups. When both groups like each other, it's a match — and a shared group chat opens so everyone can connect together.

---

## How It Works

1. **Build your group** — invite friends from your contacts to form a crew of 2–5 people.
2. **Discover** — swipe through nearby groups filtered by age, gender preference, and distance.
3. **Match** — a mutual like from both groups creates a match and unlocks a shared chat room.
4. **Chat** — your group chats with the matched group in real time via Firebase.

---

## Features

- **Phone auth** — Firebase OTP verification, no passwords
- **Group swipe deck** — location-aware, filtered by age range, gender preference, and distance
- **Mutual matching** — match only when both groups like each other
- **Dual chat** — personal group chat (your crew) and match chat (both crews together)
- **Friends & contacts** — import contacts, send/accept friend requests, build your crew
- **Profile** — photos, bio, username with real-time availability check
- **Push notifications** — friend requests, matches, messages via FCM
- **Discovery filters** — age range, max distance, gender preference
- **Block & report** — block users, report with reason
- **Account deletion** — full self-serve account removal

---

## Tech Stack

### iOS App
| Layer | Technology |
|---|---|
| Language | Swift 5.9+ |
| UI | SwiftUI (`@Observable`, `NavigationStack`) |
| Architecture | MVVM-C (Coordinator pattern) |
| Networking | Alamofire (callback-based repositories) |
| Real-time chat | Firebase Firestore |
| Auth | Firebase Phone Auth |
| Push | Firebase Cloud Messaging |
| Phone picker | FlagPhoneNumber (CocoaPod) |
| Min deployment | iOS 17 |

### Backend (in development)
| Layer | Technology |
|---|---|
| Language | TypeScript |
| Framework | Express |
| Database | PostgreSQL via Prisma ORM 7 |
| Validation | Zod |
| Cache / rate-limit | Redis |
| Auth hashing | bcrypt |
| Containerisation | Docker + Docker Compose |
| File storage | AWS S3 (photo uploads, 3 sizes) |
| Push | Firebase Admin SDK |

---

## Architecture

### iOS

```
Features/
  Onboarding/     ← phone auth, profile setup (SwiftUI)
  Root/           ← AppCoordinator, AppRootView, RootRouter
  Swipe/          ← swipe deck, like/pass
  Match/          ← match list, match detail
  Chat/           ← personal group chat + match chat (Firebase)
  Group/          ← group management, add members
  Friends/        ← friend list, requests, search
  Profile/        ← profile view, edit, settings, filters
Core/
  Domain/
    Models/           ← Codable structs (User, Group, Match, …)
    ModelViewModels/  ← display wrappers (UserViewModel, …)
  Data/
    Repositories/     ← UserRepository, GroupRepository, MatchRepository, ChatRepository
AppSupport/
  EntourageManager/   ← singleton holding current user, group, matches
  ChatSDK/            ← Firebase chat listener
  PushNotificationManager/
```

**Coordinator pattern:**
```swift
enum Route: Hashable {
    case swipeGroups, matchDetail(Match), chat(Group, personalChat: Bool, matchId: Int)
    case profile, settings, editProfile, friends, groupManagement, addGroupMember
    case userProfile(User, Group?), filters, blockedUsers, deleteAccount
}

@Observable class AppCoordinator {
    var path = NavigationPath()
    func push(_ route: Route) { path.append(route) }
    func pop() { path.removeLast() }
}
```

### Backend API contract

Every endpoint returns a standard envelope:
```json
{ "meta": { "code": 200, "message": "Success" }, "data": { ... } }
```

Base URL: `/api/v1` — routes: `/users`, `/photos`, `/groups`, `/matches`, `/friendships`, `/devices`, `/notifications`

---

## Getting Started

### iOS

**Prerequisites:** Xcode 15+, CocoaPods

```bash
git clone https://github.com/afeefSohail/entourage.git
cd entourage
pod install
open entourage.xcworkspace
```

Add your `GoogleService-Info.plist` (Firebase) to the `entourage/` directory before building.

### Backend

**Prerequisites:** Docker, Node.js 20+

```bash
cd backend
cp .env.example .env        # fill in your credentials
docker-compose up -d        # starts Postgres + Redis
npm install
npx prisma migrate dev
npm run dev
```

---

## Project Structure

```
entourage/           ← iOS Xcode project
backend/             ← Express API (TypeScript)
  prisma/            ← schema + migrations
  src/
    routes/          ← one file per resource
    services/        ← business logic (auth, photo, match, notification)
    middleware/       ← auth, validation, rate limiting
    lib/             ← prisma client, response helpers
```

---

## License

Private repository — all rights reserved.
