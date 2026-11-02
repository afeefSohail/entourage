import SwiftUI
import Contacts

struct OnboardingAddFriendsView: View {
    @Environment(AppState.self) private var appState

    @State private var friends: [Friend] = []
    @State private var addedIds: Set<Int> = []
    @State private var searchText = ""
    @State private var isLoading = true
    @State private var isFinishing = false

    private let requiredCount = 3

    private var filtered: [Friend] {
        guard !searchText.isEmpty else { return friends }
        return friends.filter {
            ($0.first_name?.localizedCaseInsensitiveContains(searchText) == true) ||
            ($0.user_name?.localizedCaseInsensitiveContains(searchText) == true)
        }
    }

    private var addedCount: Int { addedIds.count }
    private var canFinish: Bool { addedCount >= requiredCount }

    var body: some View {
        VStack(spacing: 0) {
            headerView

            SearchBar(text: $searchText)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

            if isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if filtered.isEmpty {
                Spacer()
                Text(searchText.isEmpty ? "No contacts found on Entourage." : "No results for \"\(searchText)\"")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                Spacer()
            } else {
                List(filtered, id: \.id) { friend in
                    FriendRow(
                        friend: friend,
                        isAdded: addedIds.contains(friend.id)
                    ) {
                        toggleFriend(friend)
                    }
                }
                .listStyle(.plain)
            }

            actionBar
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { Task { await loadFriends() } }
    }

    private var headerView: some View {
        VStack(spacing: 6) {
            Text("Add \(requiredCount) Friends")
                .font(.system(size: 22, weight: .bold))
            Text("\(addedCount)/\(requiredCount) added")
                .font(.system(size: 14))
                .foregroundStyle(canFinish ? Color("themeColor") : .secondary)
        }
        .padding(.vertical, 16)
    }

    private var actionBar: some View {
        VStack(spacing: 8) {
            Button {
                Task { await finish() }
            } label: {
                ZStack {
                    Text(canFinish ? "Get Started" : "Add \(requiredCount - addedCount) more")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .opacity(isFinishing ? 0 : 1)
                    if isFinishing { ProgressView().tint(.white) }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(canFinish ? Color("themeColor") : Color(.systemGray4))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!canFinish || isFinishing)

            Button("Skip") {
                appState.phase = .main
            }
            .font(.system(size: 14))
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }

    private func toggleFriend(_ friend: Friend) {
        let id = friend.id
        guard let phone = friend.phone_number else { return }
        if addedIds.contains(id) {
            addedIds.remove(id)
        } else {
            addedIds.insert(id)
            Task {
                await withCheckedContinuation { cont in
                    WebServicesManager.shared.directFriendShip(phoneNumber: phone) { _, _ in cont.resume() }
                }
            }
        }
    }

    private func loadFriends() async {
        let contacts = PhoneContacts.getAllContacts()
        let numbers = contacts.compactMap { $0.phoneNumber.isEmpty ? nil : $0.phoneNumber }.joined(separator: ",")

        await withCheckedContinuation { cont in
            WebServicesManager.shared.getFriendsListBy(contacts: numbers, directFriendship: false) { list, _ in
                Task { @MainActor in
                    friends = (list as? [Friend]) ?? []
                    isLoading = false
                    cont.resume()
                }
            }
        }
    }

    private func finish() async {
        isFinishing = true
        appState.phase = .main
    }
}

// MARK: - FriendRow

private struct FriendRow: View {
    let friend: Friend
    let isAdded: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: friend.photos.first?.medium ?? "")) { img in
                img.resizable().scaledToFill()
            } placeholder: {
                Color(.systemGray4)
            }
            .frame(width: 46, height: 46)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text("\(friend.first_name ?? "") \(friend.last_name ?? "")")
                    .font(.system(size: 15, weight: .medium))
                if let un = friend.user_name {
                    Text("@\(un)")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button(action: onToggle) {
                Text(isAdded ? "Added" : "Add")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(isAdded ? .white : Color("themeColor"))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(isAdded ? Color("themeColor") : Color("themeColor").opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - SearchBar

private struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
            TextField("Search", text: $text)
                .textInputAutocapitalization(.never)
            if !text.isEmpty {
                Button { text = "" } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
