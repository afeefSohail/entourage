// BlockedUsersView.swift — SwiftUI blocked users screen
import SwiftUI

struct BlockedUsersView: View {

    @State private var vm = BlockedUsersViewModel()

    var body: some View {
        Group {
            if vm.isLoading && vm.blockedUsers.isEmpty {
                ProgressView()
            } else if vm.blockedUsers.isEmpty {
                ContentUnavailableView(
                    "No Blocked Users",
                    systemImage: "hand.raised.slash",
                    description: Text("People you block won't appear in your feed.")
                )
            } else {
                List(vm.blockedUsers, id: \.id) { friend in
                    BlockedUserRow(
                        friend: friend,
                        isSelected: vm.selectedIds.contains(friend.id ?? 0)
                    ) {
                        vm.toggleSelection(friend.id ?? 0)
                    }
                }
            }
        }
        .navigationTitle("Blocked Users")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !vm.selectedIds.isEmpty {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task { await vm.unblockSelected() }
                    } label: {
                        if vm.isUnblocking { ProgressView() }
                        else { Text("Unblock (\(vm.selectedIds.count))") }
                    }
                }
            }
        }
        .alert("Error", isPresented: .constant(vm.errorMessage != nil)) {
            Button("OK") { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
        .task { await vm.load() }
    }
}

private struct BlockedUserRow: View {
    let friend: Friend
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            if let urlStr = friend.photos.first(where: { $0.is_primary == true })?.medium
                            ?? friend.photos.first?.medium,
               let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    if case .success(let img) = phase { img.resizable().scaledToFill() }
                    else { Color(.tertiarySystemBackground) }
                }
                .frame(width: 48, height: 48)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color(.secondarySystemBackground))
                    .frame(width: 48, height: 48)
                    .overlay(Image(systemName: "person.fill").foregroundStyle(.secondary))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("\(friend.first_name ?? "") \(friend.last_name ?? "")".trimmingCharacters(in: .whitespaces))
                    .font(.headline)
                if let age = friend.age, age > 0 {
                    Text("Age \(age)").font(.subheadline).foregroundStyle(.secondary)
                }
            }
            Spacer()
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isSelected ? .blue : .secondary)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}
