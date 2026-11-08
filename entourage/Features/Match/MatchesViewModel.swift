// MatchesViewModel.swift — screen VM for the matches/messages list
import Foundation
import Observation

@Observable
@MainActor
final class MatchesViewModel {

    var matches: [Match] = EntourageManager.shared.myMatchs
    var isLoading = false
    var errorMessage: String?

    private let repo = MatchRepository.shared

    func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let loaded = try await repo.matchList()
            EntourageManager.shared.myMatchs = loaded
            matches = loaded
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func unmatch(_ match: Match) async {
        let groupId = String(match.matcher?.id ?? 0)
        do {
            try await repo.unMatchTheGroup(groupId: groupId)
            matches.removeAll { $0.id == match.id }
            EntourageManager.shared.myMatchs = matches
            restartMatchListener()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func restartMatchListener() {
        lastMessageListner?.unsubscribe()
        lastMessageListner = nil
        guard !EntourageManager.shared.myMatchs.isEmpty else { return }
        let listener = unReadMessageFirebaseService<LastMessage>.matchListener()
        lastMessageListner = listener
        listener?.lastMesssageUpdates { _, _ in }
    }
}
