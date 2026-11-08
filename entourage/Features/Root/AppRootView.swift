// AppRootView.swift — SwiftUI root: tabs + NavigationStack coordinator
import SwiftUI

struct AppRootView: View {

    @State private var coordinator = AppCoordinator()

    var body: some View {
        NavigationStack(path: Bindable(coordinator).path) {
            MainTabView()
                .navigationDestination(for: Route.self) { route in
                    destinationView(for: route)
                }
        }
        .environment(coordinator)
        .task { await loadStartupData() }
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

    @ViewBuilder
    private func destinationView(for route: Route) -> some View {
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
            FiltersViewBridge()
        case .addGroupMember:
            AddGroupMemberBridge()
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

// MARK: - Main tab bar

private struct MainTabView: View {

    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        TabView {
            SwipeView()
                .tabItem { Label("Discover", systemImage: "flame.fill") }

            MatchesListView()
                .tabItem { Label("Matches", systemImage: "bubble.left.and.bubble.right.fill") }

            FriendsView()
                .tabItem { Label("Friends", systemImage: "person.2.fill") }

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.fill") }

            NavigationLink(value: Route.settings) { EmptyView() }
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
    }
}

// MARK: - Placeholder views for screens not yet migrated to SwiftUI

struct FiltersViewBridge: View {
    var body: some View {
        Text("Filters")
            .navigationTitle("Filters")
    }
}

struct AddGroupMemberBridge: View {
    var body: some View {
        Text("Add Group Member")
            .navigationTitle("Add Group Member")
    }
}
