// FriendsView.swift
import SwiftUI
import Contacts

struct FriendsView: View {

    @State private var vm = FriendsViewModel()

    var body: some View {
        VStack(spacing: 0) {
            tabBar
            if vm.selectedTab == .all {
                searchBar
            }
            content
        }
        .navigationTitle("Friends")
        .navigationBarTitleDisplayMode(.inline)
        .task { await vm.onAppear() }
        .alert("Error", isPresented: Binding(
            get: { vm.errorMessage != nil },
            set: { if !$0 { vm.errorMessage = nil } }
        )) {
            Button("OK") { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }

    // MARK: - Tab bar

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(FriendsTab.allCases, id: \.self) { tab in
                Button {
                    if vm.selectedTab != tab {
                        vm.selectedTab = tab
                        Task { await vm.onTabChanged() }
                    }
                } label: {
                    Text(tab.rawValue)
                        .font(.custom("Avenir-Medium", size: 15))
                        .foregroundStyle(vm.selectedTab == tab ? Color.themeColor : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .overlay(alignment: .bottom) {
                            if vm.selectedTab == tab {
                                Rectangle()
                                    .fill(Color.themeColor)
                                    .frame(height: 2)
                            }
                        }
                }
            }
        }
        .overlay(alignment: .bottom) {
            Divider()
        }
    }

    // MARK: - Search bar

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Search by Username", text: Binding(
                get: { vm.searchText },
                set: { v in
                    vm.searchText = v
                    Task { await vm.onSearchTextChanged() }
                }
            ))
            .font(.custom("Avenir-Medium", size: 15))
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            if !vm.searchText.isEmpty {
                Button { vm.searchText = ""; vm.searchResults = [] } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if vm.isLoading {
            Spacer()
            ProgressView()
            Spacer()
        } else {
            switch vm.selectedTab {
            case .all:      allTab
            case .requests: requestsTab
            case .contacts: contactsTab
            }
        }
    }

    // MARK: - All tab

    private var allTab: some View {
        let items = vm.searchText.isEmpty ? vm.friends : vm.searchResults
        return Group {
            if items.isEmpty {
                emptyState(
                    text: vm.searchText.isEmpty
                        ? "You need friends to start swiping together."
                        : "No results for \"\(vm.searchText)\"."
                )
            } else {
                List(items, id: \.id) { user in
                    FriendRow(
                        user: user,
                        badge: nil,
                        action: actionForAllTab(user: user)
                    )
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
            }
        }
    }

    private func actionForAllTab(user: User) -> FriendRowAction {
        let status = user.friendStatus ?? "no_relation"
        if status == "accepted" {
            return .friends
        } else if status == "pending" || status == "Request" {
            return .pending("Pending")
        } else if vm.sentRequestIds.contains(user.id) {
            return .pending("Requested")
        } else {
            return .add { Task { await vm.sendRequest(to: user) } }
        }
    }

    // MARK: - Requests tab

    private var requestsTab: some View {
        Group {
            if vm.requests.isEmpty {
                emptyState(text: "No pending friend requests.")
            } else {
                List(vm.requests, id: \.id) { user in
                    FriendRow(
                        user: user,
                        badge: nil,
                        action: vm.acceptedRequestIds.contains(user.id)
                            ? .friends
                            : .accept { Task { await vm.acceptRequest(from: user) } }
                    )
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
            }
        }
    }

    // MARK: - Contacts tab

    @ViewBuilder
    private var contactsTab: some View {
        if !vm.hasContactsPermission {
            contactsPermissionView
        } else if vm.contactAppUsers.isEmpty && vm.contactNonAppUsers.isEmpty {
            emptyState(text: "No contacts found on Entourage.")
        } else {
            List {
                if !vm.contactAppUsers.isEmpty {
                    Section {
                        ForEach(vm.contactAppUsers, id: \.id) { user in
                            FriendRow(
                                user: user,
                                badge: "IN YOUR CONTACTS",
                                action: actionForAllTab(user: user)
                            )
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            .listRowSeparator(.hidden)
                        }
                    }
                }
                if !vm.contactNonAppUsers.isEmpty {
                    Section {
                        ForEach(vm.contactNonAppUsers, id: \.phone) { item in
                            NonAppContactRow(
                                name: item.name,
                                phone: item.phone,
                                isInvited: vm.invitedNumbers.contains(item.phone)
                            ) {
                                Task { await vm.sendInvite(phone: item.phone) }
                            }
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            .listRowSeparator(.hidden)
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
    }

    private var contactsPermissionView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "person.crop.circle.badge.exclamationmark")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("You cannot import friends on Entourage without your contacts")
                .font(.custom("Avenir-Medium", size: 15))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Text("Turn on Contact Permissions")
                .font(.custom("Avenir-Medium", size: 13))
                .foregroundStyle(.secondary)
            Button("Go to Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .font(.custom("Avenir-Medium", size: 15))
            .foregroundStyle(Color.themeColor)
            Spacer()
        }
        .padding(.horizontal, 32)
    }

    private func emptyState(text: String) -> some View {
        VStack {
            Spacer()
            Text(text)
                .font(.custom("Avenir-Medium", size: 15))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
    }
}

// MARK: - FriendRowAction

enum FriendRowAction {
    case add(action: () -> Void)
    case invite(action: () -> Void)
    case accept(action: () -> Void)
    case pending(String)
    case friends
}

// MARK: - FriendRow

struct FriendRow: View {

    let user: User
    let badge: String?
    let action: FriendRowAction

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            AsyncImage(url: URL(string: user.mediumPhotoURL)) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().scaledToFill()
                default:
                    Color(.systemGray5)
                        .overlay {
                            Text(initials)
                                .font(.custom("Avenir-Medium", size: 16))
                                .foregroundStyle(.secondary)
                        }
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())

            // Name + username
            VStack(alignment: .leading, spacing: 2) {
                Text(user.first_name ?? "")
                    .font(.custom("Avenir-Medium", size: 17))
                    .foregroundStyle(.primary)
                if let uname = user.user_name, !uname.isEmpty {
                    Text("@\(uname)")
                        .font(.custom("Avenir-Medium", size: 12))
                        .foregroundStyle(.secondary)
                }
                if let badge = badge {
                    Text(badge)
                        .font(.custom("Avenir-Medium", size: 9))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color(.systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                }
            }

            Spacer()

            actionButton
        }
        .padding(.vertical, 4)
    }

    private var initials: String {
        let first = user.first_name?.first.map(String.init) ?? ""
        let last  = user.last_name?.first.map(String.init) ?? ""
        return (first + last).uppercased()
    }

    @ViewBuilder
    private var actionButton: some View {
        switch action {
        case .add(let handler):
            Button(action: handler) {
                Text("Add")
                    .font(.custom("Avenir-Medium", size: 13))
                    .foregroundStyle(.white)
                    .frame(width: 60, height: 26)
                    .background(Color.themeColor)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            }
            .buttonStyle(.plain)

        case .invite(let handler):
            Button(action: handler) {
                Text("Invite")
                    .font(.custom("Avenir-Medium", size: 13))
                    .foregroundStyle(Color.themeColor)
                    .frame(width: 60, height: 26)
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.themeColor, lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)

        case .accept(let handler):
            Button(action: handler) {
                Text("Accept")
                    .font(.custom("Avenir-Medium", size: 13))
                    .foregroundStyle(.white)
                    .frame(width: 60, height: 26)
                    .background(Color.themeColor)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            }
            .buttonStyle(.plain)

        case .pending(let label):
            Text(label)
                .font(.custom("Avenir-Medium", size: 12))
                .foregroundStyle(.secondary)
                .frame(width: 70, height: 26)

        case .friends:
            HStack(spacing: 3) {
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .medium))
                Text("Friends")
                    .font(.custom("Avenir-Medium", size: 12))
            }
            .foregroundStyle(.secondary)
            .frame(width: 70, height: 26)
        }
    }
}

// MARK: - NonAppContactRow

struct NonAppContactRow: View {

    let name: String
    let phone: String
    let isInvited: Bool
    let onInvite: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Initials avatar
            Circle()
                .fill(Color(.systemGray5))
                .frame(width: 50, height: 50)
                .overlay {
                    Text(initials)
                        .font(.custom("Avenir-Medium", size: 16))
                        .foregroundStyle(.secondary)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.custom("Avenir-Medium", size: 17))
                    .foregroundStyle(.primary)
                Text(phone)
                    .font(.custom("Avenir-Medium", size: 12))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if isInvited {
                Text("Invited")
                    .font(.custom("Avenir-Medium", size: 12))
                    .foregroundStyle(.secondary)
                    .frame(width: 70, height: 26)
            } else {
                Button(action: onInvite) {
                    Text("Invite")
                        .font(.custom("Avenir-Medium", size: 13))
                        .foregroundStyle(Color.themeColor)
                        .frame(width: 60, height: 26)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.themeColor, lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }

    private var initials: String {
        name.split(separator: " ").prefix(2)
            .compactMap { $0.first }
            .map(String.init)
            .joined()
            .uppercased()
    }
}
