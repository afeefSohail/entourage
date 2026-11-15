// AppRootView.swift — SwiftUI root: tab bar with one NavigationStack per tab
import SwiftUI
import UIKit

struct AppRootView: View {

    @State private var coordinator = AppCoordinator()

    var body: some View {
        MainTabView()
            .environment(coordinator)
            .task { await loadStartupData() }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                handlePendingDeepLink()
            }
    }

    @MainActor
    private func loadStartupData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                if let g = try? await GroupRepository.shared.myGroup() {
                    await MainActor.run { EntourageManager.shared.myGroup = g }
                }
            }
            group.addTask {
                if let list = try? await MatchRepository.shared.matchList() {
                    await MainActor.run { EntourageManager.shared.myMatchs = list }
                }
            }
        }

        guard lastMessageListner == nil,
              EntourageManager.shared.myGroup != nil else { return }
        let listener = unReadMessageFirebaseService<LastMessage>.matchListener()
        lastMessageListner = listener
        listener?.lastMesssageUpdates { _, _ in }
    }

    @MainActor
    private func handlePendingDeepLink() {
        let defaults = UserDefaults.standard
        guard let type = defaults.string(forKey: "notifiable_type"), !type.isEmpty else { return }
        defaults.removeObject(forKey: "notifiable_type")

        switch type {
        case "Message":
            let chatId = defaults.integer(forKey: "chat_id")
            let groupId = defaults.integer(forKey: "group_id")
            defaults.removeObject(forKey: "chat_id")
            defaults.removeObject(forKey: "group_id")

            if let myGroup = EntourageManager.shared.myGroup, myGroup.id == groupId {
                coordinator.push(.chat(myGroup, personalChat: true, matchId: 0), in: .matches)
            } else if let match = EntourageManager.shared.myMatchs.first(where: { $0.chat_id == chatId }),
                      let matchedGroup = match.matcher {
                coordinator.push(.chat(matchedGroup, personalChat: false, matchId: match.chat_id), in: .matches)
            }

        case "MatchCreated":
            let matchId = defaults.integer(forKey: "match_id")
            defaults.removeObject(forKey: "match_id")
            if let match = EntourageManager.shared.myMatchs.first(where: { $0.id == matchId }) {
                coordinator.push(.matchDetail(match), in: .matches)
            }

        case "FriendshipRequest", "FriendshipAccepted":
            coordinator.selectedTab = .friends

        case "GroupMemberAdded":
            defaults.removeObject(forKey: "group_id")
            Task {
                if let g = try? await GroupRepository.shared.myGroup() {
                    EntourageManager.shared.myGroup = g
                }
                coordinator.push(.groupManagement, in: .profile)
            }

        default:
            break
        }
    }
}

// MARK: - Main tab bar

private struct MainTabView: View {

    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        @Bindable var coordinator = coordinator
        TabView(selection: $coordinator.selectedTab) {
            TabStack(path: $coordinator.discoverPath) { SwipeView() }
                .tabItem { Label("Discover", systemImage: "flame.fill") }
                .tag(AppTab.discover)

            TabStack(path: $coordinator.matchesPath) { MatchesListView() }
                .tabItem { Label("Matches", systemImage: "bubble.left.and.bubble.right.fill") }
                .tag(AppTab.matches)

            TabStack(path: $coordinator.friendsPath) { FriendsView() }
                .tabItem { Label("Friends", systemImage: "person.2.fill") }
                .tag(AppTab.friends)

            TabStack(path: $coordinator.profilePath) { ProfileView() }
                .tabItem { Label("Profile", systemImage: "person.fill") }
                .tag(AppTab.profile)

            TabStack(path: $coordinator.settingsPath) { SettingsView() }
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(AppTab.settings)
        }
    }
}

private struct TabStack<Root: View>: View {
    @Binding var path: NavigationPath
    @ViewBuilder var root: Root

    var body: some View {
        NavigationStack(path: $path) {
            root.navigationDestination(for: Route.self) { RouteDestination(route: $0) }
        }
    }
}

private struct RouteDestination: View {
    let route: Route

    var body: some View {
        switch route {
        case .swipeGroups:
            SwipeView()
        case .matchDetail(let match):
            MatchDetailView(match: match)
        case .chat(let group, let personalChat, let matchId):
            ChatView(group: group, personalChat: personalChat, matchId: matchId)
        case .profile:
            ProfileView()
        case .settings:
            SettingsView()
        case .editProfile:
            EditProfileView()
        case .blockedUsers:
            BlockedUsersView()
        case .filters:
            FiltersView()
        case .addGroupMember:
            AddGroupMemberView()
        case .groupManagement:
            GroupManagementView()
        case .userProfile(let user, let group):
            UserProfileView(user: user, group: group)
        case .deleteAccount:
            DeleteAccountView()
        case .friends:
            FriendsView()
        }
    }
}
