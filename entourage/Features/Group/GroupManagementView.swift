// GroupManagementView.swift — user's own group: chat, members, add, leave
import SwiftUI

struct GroupManagementView: View {

    @Environment(AppCoordinator.self) private var coordinator
    @State private var vm = GroupManagementViewModel()

    var body: some View {
        SwiftUI.Group {
            if vm.isLoading && vm.group == nil {
                ProgressView()
            } else if let group = vm.group {
                content(group: group)
            } else {
                noGroupView
            }
        }
        .navigationTitle("My Group")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if vm.group != nil {
                    Button {
                        coordinator.push(.addGroupMember)
                    } label: {
                        Image(systemName: "person.badge.plus")
                    }
                }
            }
        }
        .task { await vm.load() }
        .alert("Leave Group?", isPresented: $vm.showLeaveConfirm) {
            Button("Leave", role: .destructive) {
                Task { await vm.leaveGroup { coordinator.pop() } }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You will be removed from the group. This cannot be undone.")
        }
        .alert("Error", isPresented: .constant(vm.errorMessage != nil)) {
            Button("OK") { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }

    // MARK: - Main content

    @ViewBuilder
    private func content(group: Group) -> some View {
        List {
            // Chat entry
            Section {
                Button {
                    coordinator.push(.chat(group, personalChat: true, matchId: 0))
                } label: {
                    Label("Group Chat", systemImage: "bubble.left.and.bubble.right.fill")
                        .foregroundStyle(.primary)
                }
            }

            // Members
            Section("Members (\(group.users?.count ?? 0))") {
                ForEach(group.users ?? [], id: \.id) { member in
                    MemberRow(member: member) {
                        coordinator.push(.userProfile(member, group))
                    }
                }
            }

            // Danger zone
            Section {
                Button(role: .destructive) {
                    vm.showLeaveConfirm = true
                } label: {
                    Label("Leave Group", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }
        }
    }

    private var noGroupView: some View {
        ContentUnavailableView(
            "No Group Yet",
            systemImage: "person.3",
            description: Text("You haven't created or joined a group. Add friends to start one.")
        )
    }
}

// MARK: - Member row

private struct MemberRow: View {
    let member: User
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                memberAvatar
                VStack(alignment: .leading, spacing: 2) {
                    Text(UserViewModel(member).displayName)
                        .font(.body)
                        .foregroundStyle(.primary)
                    if member.age != nil {
                        Text("Age \(UserViewModel(member).ageText)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
                    .font(.caption)
            }
        }
    }

    @ViewBuilder
    private var memberAvatar: some View {
        if let photo = member.photos.first(where: { $0.is_primary == true }) ?? member.photos.first,
           let urlStr = photo.thumb, let url = URL(string: urlStr) {
            AsyncImage(url: url) { phase in
                if case .success(let img) = phase { img.resizable().scaledToFill() }
                else { avatarPlaceholder }
            }
            .frame(width: 44, height: 44)
            .clipShape(Circle())
        } else {
            avatarPlaceholder
        }
    }

    private var avatarPlaceholder: some View {
        Circle()
            .fill(Color(.secondarySystemBackground))
            .frame(width: 44, height: 44)
            .overlay(Image(systemName: "person.fill").foregroundStyle(.secondary))
    }
}
