// AppCoordinator.swift — NavigationStack-based coordinator for Phase 3
import SwiftUI

enum Route: Hashable {
    case swipeGroups
    case matchDetail(Match)
    case chat(Group, personalChat: Bool, matchId: Int)
    case profile
    case settings
    case editProfile
    case blockedUsers
    case filters
    case addGroupMember
    case groupManagement
    case createGroup
    case userProfile(User, Group?)
    case deleteAccount
    case friends

    // Hashable conformance for associated-value cases
    func hash(into hasher: inout Hasher) {
        switch self {
        case .swipeGroups:           hasher.combine(0)
        case .matchDetail(let m):    hasher.combine(1); hasher.combine(m.id)
        case .chat(let g, let p, let mId): hasher.combine(2); hasher.combine(g.id); hasher.combine(p); hasher.combine(mId)
        case .profile:               hasher.combine(3)
        case .settings:              hasher.combine(4)
        case .editProfile:           hasher.combine(5)
        case .blockedUsers:          hasher.combine(6)
        case .filters:               hasher.combine(7)
        case .addGroupMember:        hasher.combine(8)
        case .groupManagement:       hasher.combine(12)
        case .createGroup:           hasher.combine(13)
        case .userProfile(let u, _): hasher.combine(9); hasher.combine(u.id)
        case .deleteAccount:          hasher.combine(10)
        case .friends:               hasher.combine(11)
        }
    }

    static func == (lhs: Route, rhs: Route) -> Bool {
        switch (lhs, rhs) {
        case (.swipeGroups, .swipeGroups):     return true
        case (.profile, .profile):             return true
        case (.settings, .settings):           return true
        case (.editProfile, .editProfile):     return true
        case (.blockedUsers, .blockedUsers):   return true
        case (.filters, .filters):             return true
        case (.addGroupMember, .addGroupMember): return true
        case (.groupManagement, .groupManagement): return true
        case (.createGroup, .createGroup):     return true
        case (.matchDetail(let a), .matchDetail(let b)):  return a.id == b.id
        case (.chat(let g1, let p1, let m1), .chat(let g2, let p2, let m2)):
            return g1.id == g2.id && p1 == p2 && m1 == m2
        case (.userProfile(let u1, _), .userProfile(let u2, _)): return u1.id == u2.id
        case (.deleteAccount, .deleteAccount):   return true
        case (.friends, .friends):           return true
        default: return false
        }
    }
}

enum AppTab: Hashable {
    case discover, matches, friends, profile, settings
}

// Each tab owns its own NavigationStack; push/pop act on the selected tab's stack.
@Observable
@MainActor
final class AppCoordinator {

    var selectedTab: AppTab = .discover

    var discoverPath = NavigationPath()
    var matchesPath  = NavigationPath()
    var friendsPath  = NavigationPath()
    var profilePath  = NavigationPath()
    var settingsPath = NavigationPath()

    var path: NavigationPath {
        get {
            switch selectedTab {
            case .discover: discoverPath
            case .matches:  matchesPath
            case .friends:  friendsPath
            case .profile:  profilePath
            case .settings: settingsPath
            }
        }
        set {
            switch selectedTab {
            case .discover: discoverPath = newValue
            case .matches:  matchesPath  = newValue
            case .friends:  friendsPath  = newValue
            case .profile:  profilePath  = newValue
            case .settings: settingsPath = newValue
            }
        }
    }

    func push(_ route: Route) { path.append(route) }

    func push(_ route: Route, in tab: AppTab) {
        selectedTab = tab
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() { path = NavigationPath() }
}
