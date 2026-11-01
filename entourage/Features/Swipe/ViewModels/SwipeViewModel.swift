// SwipeViewModel.swift — screen VM for the card swipe screen
import Foundation
import Observation

@Observable
@MainActor
final class SwipeViewModel {

    var groups: [Group] = []
    var currentIndex: Int = 0
    var isLoading = false
    var lastMatch: Match?
    var showMatchBanner = false
    var errorMessage: String?

    private var page = 1
    private var isLoadingMore = false
    private let repo = MatchRepository.shared

    var currentGroup: Group? {
        guard currentIndex < groups.count else { return nil }
        return groups[currentIndex]
    }

    var isEmpty: Bool { !isLoading && groups.isEmpty }
    var isExhausted: Bool { !isLoading && !groups.isEmpty && currentIndex >= groups.count }

    // MARK: - Load

    func loadInitial() async {
        guard !isLoading else { return }
        isLoading = true
        page = 1
        do {
            let result = try await repo.findGroupsToMatch(page: page)
            groups = result?.groups ?? []
            currentIndex = 0
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func loadNextPage() async {
        guard !isLoadingMore else { return }
        isLoadingMore = true
        page += 1
        do {
            let result = try await repo.findGroupsToMatch(page: page)
            let newGroups = result?.groups ?? []
            groups.append(contentsOf: newGroups)
        } catch {
            // silently fail pagination — user can refresh
        }
        isLoadingMore = false
    }

    // MARK: - Swipe actions

    func like() async {
        guard let group = currentGroup else { return }
        advance()
        do {
            if let match = try await repo.likeTheGroup(groupId: String(group.id)) {
                lastMatch = match
                showMatchBanner = true
                EntourageManager.shared.myMatchs.append(match)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        await prefetchIfNeeded()
    }

    func pass() async {
        guard let group = currentGroup else { return }
        advance()
        // fire-and-forget unlike
        _ = try? await repo.unLikeTheGroup(groupId: String(group.id))
        await prefetchIfNeeded()
    }

    private func advance() {
        currentIndex += 1
    }

    private func prefetchIfNeeded() async {
        let remaining = groups.count - currentIndex
        if remaining <= 2 {
            await loadNextPage()
        }
    }
}
