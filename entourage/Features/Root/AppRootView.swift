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
        case .userProfile(let user, let group):
            UserProfileView(user: user, group: group)
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

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.fill") }

            NavigationLink(value: Route.settings) { EmptyView() }
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
    }
}

// MARK: - UIKit bridge stubs (keep existing VCs for unported screens)

struct FiltersViewBridge: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        UIStoryboard(name: "ProfileViews", bundle: nil)
            .instantiateViewController(withIdentifier: "FiltersVC")
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct AddGroupMemberBridge: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        UIStoryboard(name: "Home", bundle: nil)
            .instantiateViewController(withIdentifier: "AddFriendsVC")
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
