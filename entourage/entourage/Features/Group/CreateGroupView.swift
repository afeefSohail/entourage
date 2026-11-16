// CreateGroupView.swift — pick friends and create the user's group
import SwiftUI

struct CreateGroupView: View {

    @Environment(AppCoordinator.self) private var coordinator
    @State private var vm = CreateGroupViewModel()
    @State private var searchText = ""

    private var filtered: [User] {
        guard !searchText.isEmpty else { return vm.friends }
        return vm.friends.filter {
            ($0.firstName?.localizedCaseInsensitiveContains(searchText) == true) ||
            ($0.userName?.localizedCaseInsensitiveContains(searchText) == true)
        }
    }

    var body: some View {
        SwiftUI.Group {
            if vm.isLoading && vm.friends.isEmpty {
                ProgressView()
            } else if vm.friends.isEmpty {
                ContentUnavailableView {
                    Label("No Friends Yet", systemImage: "person.2")
                } description: {
                    Text("A group needs at least one friend. Add friends first, then come back to create your group.")
                } actions: {
                    Button("Find Friends") { coordinator.push(.friends, in: .friends) }
                        .buttonStyle(.borderedProminent)
                }
            } else {
                VStack(spacing: 0) {
                    header
                    searchBar
                    List(filtered, id: \.id) { friend in
                        friendRow(friend)
                    }
                    .listStyle(.plain)
                    createButton
                }
            }
        }
        .navigationTitle("Create Group")
        .navigationBarTitleDisplayMode(.inline)
        .task { await vm.load() }
        .alert("Error", isPresented: Binding(
            get: { vm.errorMessage != nil },
            set: { if !$0 { vm.errorMessage = nil } }
        )) {
            Button("OK") { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }

    private var header: some View {
        Text("Pick the friends you want to swipe with. You can add more later.")
            .font(.system(size: 14))
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
            .padding(.top, 12)
    }

    private var searchBar: some View {
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
    }

    private var createButton: some View {
        Button {
            Task {
                if await vm.create() { coordinator.pop() }
            }
        } label: {
            ZStack {
                Text(vm.selectedIds.isEmpty ? "Select at least 1 friend" : "Create Group (\(vm.selectedIds.count + 1))")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .opacity(vm.isCreating ? 0 : 1)
                if vm.isCreating { ProgressView().tint(.white) }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(vm.selectedIds.isEmpty ? Color(.systemGray4) : Color("themeColor"))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(vm.selectedIds.isEmpty || vm.isCreating)
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }

    @ViewBuilder
    private func friendRow(_ friend: User) -> some View {
        let selected = vm.selectedIds.contains(friend.id)
        Button {
            vm.toggle(friend)
        } label: {
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
                        .foregroundStyle(.primary)
                    if let un = friend.userName {
                        Text("@\(un)")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(selected ? Color("themeColor") : Color(.systemGray3))
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(vm.isCreating)
    }
}

// MARK: - ViewModel

@Observable
@MainActor
final class CreateGroupViewModel {

    var friends: [User] = []
    var selectedIds: Set<Int> = []
    var isLoading = false
    var isCreating = false
    var errorMessage: String?

    func load() async {
        isLoading = true
        defer { isLoading = false }
        friends = (try? await UserRepository.shared.getFriendsList()) ?? []
    }

    func toggle(_ user: User) {
        if selectedIds.contains(user.id) { selectedIds.remove(user.id) } else { selectedIds.insert(user.id) }
    }

    func create() async -> Bool {
        guard !selectedIds.isEmpty else { return false }
        isCreating = true
        defer { isCreating = false }
        do {
            let ids = selectedIds.map(String.init).joined(separator: ",")
            guard let group = try await GroupRepository.shared.createGroup(friendsIds: ids) else {
                errorMessage = "Could not create the group. Please try again."
                return false
            }
            EntourageManager.shared.myGroup = group
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
