import SwiftUI

struct AddGroupMemberView: View {

    @Environment(AppCoordinator.self) private var coordinator
    @State private var vm = AddGroupMemberViewModel()
    @State private var searchText = ""

    private var filtered: [User] {
        guard !searchText.isEmpty else { return vm.eligibleFriends }
        return vm.eligibleFriends.filter {
            ($0.first_name?.localizedCaseInsensitiveContains(searchText) == true) ||
            ($0.user_name?.localizedCaseInsensitiveContains(searchText) == true)
        }
    }

    var body: some View {
        SwiftUI.Group {
            if vm.isLoading && vm.eligibleFriends.isEmpty {
                ProgressView()
            } else if vm.eligibleFriends.isEmpty {
                ContentUnavailableView(
                    "No Friends to Add",
                    systemImage: "person.badge.plus",
                    description: Text("All your friends are already in the group, or you have no friends yet.")
                )
            } else {
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                        TextField("Search", text: $searchText)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                        if !searchText.isEmpty {
                            Button { searchText = "" } label: {
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

                    List(filtered, id: \.id) { friend in
                        friendRow(friend)
                    }
                    .listStyle(.plain)
                }
            }
        }
        .navigationTitle("Add Member")
        .navigationBarTitleDisplayMode(.inline)
        .task { await vm.load() }
        .alert("Error", isPresented: .constant(vm.errorMessage != nil)) {
            Button("OK") { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }

    @ViewBuilder
    private func friendRow(_ friend: User) -> some View {
        let added = vm.addedIds.contains(friend.id)
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: friend.photos.first(where: { $0.is_primary == true })?.thumb
                                ?? friend.photos.first?.thumb ?? "")) { phase in
                if case .success(let img) = phase { img.resizable().scaledToFill() }
                else { Color(.systemGray4) }
            }
            .frame(width: 46, height: 46)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(UserViewModel(friend).displayName)
                    .font(.system(size: 15, weight: .medium))
                if let un = friend.user_name {
                    Text("@\(un)")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button {
                guard !added else { return }
                Task { await vm.addMember(friend) }
            } label: {
                if vm.addingId == friend.id {
                    ProgressView().scaleEffect(0.8)
                        .frame(width: 70, height: 32)
                } else {
                    Text(added ? "Added" : "Add")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(added ? .white : Color("themeColor"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(added ? Color("themeColor") : Color("themeColor").opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
            .disabled(added || vm.addingId != nil)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - ViewModel

@Observable
@MainActor
final class AddGroupMemberViewModel {

    var friends: [User] = []
    var addedIds: Set<Int> = []
    var addingId: Int? = nil
    var isLoading = false
    var errorMessage: String?

    private var existingMemberIds: Set<Int> {
        Set((EntourageManager.shared.myGroup?.users ?? []).map { $0.id })
    }

    var eligibleFriends: [User] {
        friends.filter { !existingMemberIds.contains($0.id) && !addedIds.contains($0.id) }
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        friends = (try? await UserRepository.shared.getFriendsList()) ?? []
    }

    func addMember(_ user: User) async {
        guard let group = EntourageManager.shared.myGroup else { return }
        addingId = user.id
        defer { addingId = nil }
        do {
            if let updated = try await GroupRepository.shared.addMember(groupId: group.id, friendsId: user.id) {
                EntourageManager.shared.myGroup = updated
            }
            addedIds.insert(user.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
