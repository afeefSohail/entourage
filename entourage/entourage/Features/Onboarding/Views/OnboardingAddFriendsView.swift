import SwiftUI
import Contacts

struct OnboardingAddFriendsView: View {
    @Environment(AppState.self) private var appState

    @State private var friends: [User] = []
    @State private var contacts: [PhoneContact] = []
    @State private var addedIds: Set<Int> = []
    @State private var searchText = ""
    @State private var isLoading = true
    @State private var isFinishing = false
    @State private var inviteURL: URL?
    @State private var showShareSheet = false

    private let requiredCount = 3

    private var filtered: [User] {
        guard !searchText.isEmpty else { return friends }
        return friends.filter {
            ($0.firstName?.localizedCaseInsensitiveContains(searchText) == true) ||
            ($0.userName?.localizedCaseInsensitiveContains(searchText) == true)
        }
    }

    private var nonEntourageContacts: [PhoneContact] {
        let entourageNumbers = Set(friends.compactMap { $0.phoneNumber })
        var seen = Set<String>()
        return contacts.filter { c in
            guard !c.phoneNumber.isEmpty,
                  !entourageNumbers.contains(c.phoneNumber),
                  let name = c.name, !name.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
            return seen.insert(name).inserted
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
            } else {
                List {
                    if filtered.isEmpty && searchText.isEmpty {
                        Section {
                            Text("No contacts found on Entourage.")
                                .font(.system(size: 15))
                                .foregroundStyle(.secondary)
                                .listRowSeparator(.hidden)
                        }
                    } else if filtered.isEmpty {
                        Section {
                            Text("No results for \"\(searchText)\"")
                                .font(.system(size: 15))
                                .foregroundStyle(.secondary)
                                .listRowSeparator(.hidden)
                        }
                    } else {
                        Section {
                            ForEach(filtered, id: \.id) { friend in
                                OnboardingFriendRow(
                                    friend: friend,
                                    isAdded: addedIds.contains(friend.id)
                                ) {
                                    toggleFriend(friend)
                                }
                                .listRowSeparator(.hidden)
                            }
                        }
                    }

                    if !nonEntourageContacts.isEmpty && searchText.isEmpty {
                        Section(header: Text("Invite to Entourage")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .textCase(nil)) {
                            ForEach(nonEntourageContacts, id: \.phoneNumber) { contact in
                                ContactInviteRow(name: contact.name ?? contact.phoneNumber) {
                                    Task { await invite(phoneNumber: contact.phoneNumber) }
                                }
                                .listRowSeparator(.hidden)
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }

            actionBar
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { Task { await loadFriends() } }
        .sheet(isPresented: $showShareSheet) {
            if let url = inviteURL {
                ShareSheet(items: [url])
                    .presentationDetents([.medium, .large])
            }
        }
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

    private func toggleFriend(_ friend: User) {
        let id = friend.id
        guard let phone = friend.phoneNumber else { return }
        if addedIds.contains(id) {
            addedIds.remove(id)
        } else {
            addedIds.insert(id)
            Task { try? await UserRepository.shared.directFriendShip(phoneNumber: phone) }
        }
    }

    private func invite(phoneNumber: String) async {
        guard let urlStr = try? await UserRepository.shared.sendInviteMessage(phoneNumber: phoneNumber),
              let url = URL(string: urlStr) else { return }
        inviteURL = url
        showShareSheet = true
    }

    private func loadFriends() async {
        contacts = PhoneContacts.getAllContacts()
        let numbers = contacts.compactMap { $0.phoneNumber.isEmpty ? nil : $0.phoneNumber }.joined(separator: ",")

        friends = (try? await UserRepository.shared.getFriendsListBy(contacts: numbers, directFriendship: false)) ?? []
        isLoading = false
    }

    private func finish() async {
        isFinishing = true
        appState.phase = .main
    }
}

// MARK: - FriendRow

private struct OnboardingFriendRow: View {
    let friend: User
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
                Text("\(friend.firstName ?? "") \(friend.lastName ?? "")")
                    .font(.system(size: 15, weight: .medium))
                if let un = friend.userName {
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

// MARK: - ContactInviteRow

private struct ContactInviteRow: View {
    let name: String
    let onInvite: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(.systemGray5))
                .frame(width: 46, height: 46)
                .overlay(
                    Text(String(name.prefix(1)).uppercased())
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.secondary)
                )

            Text(name)
                .font(.system(size: 15, weight: .medium))

            Spacer()

            Button(action: onInvite) {
                Text("Invite")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color("themeColor"))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color("themeColor").opacity(0.1))
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

// MARK: - Share sheet

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
