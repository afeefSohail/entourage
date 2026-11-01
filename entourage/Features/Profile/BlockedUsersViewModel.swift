// BlockedUsersViewModel.swift — screen VM for blocked users list
import Foundation
import Observation

@Observable
@MainActor
final class BlockedUsersViewModel {

    var blockedUsers: [Friend] = []
    var selectedIds: Set<Int> = []
    var isLoading = false
    var isUnblocking = false
    var errorMessage: String?

    private let repo = UserRepository.shared

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            blockedUsers = try await repo.getBlockedFriends()
            EntourageManager.shared.setting?.block_member_count = blockedUsers.count
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleSelection(_ id: Int) {
        if selectedIds.contains(id) { selectedIds.remove(id) } else { selectedIds.insert(id) }
    }

    func unblockSelected() async {
        guard !selectedIds.isEmpty else { return }
        let ids = selectedIds.map { String($0) }.joined(separator: ",")
        isUnblocking = true
        defer { isUnblocking = false }
        do {
            try await repo.unblockedUsers(blockUserIds: ids)
            blockedUsers.removeAll { selectedIds.contains($0.id ?? 0) }
            selectedIds.removeAll()
            EntourageManager.shared.setting?.block_member_count = blockedUsers.count
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
