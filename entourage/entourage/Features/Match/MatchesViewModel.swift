// MatchesViewModel.swift — screen VM for the matches/messages list
import Foundation
import Observation
import FirebaseFirestore

struct LastMessagePreview: Equatable {
    let text: String
    let senderId: String
    let senderName: String
    let createdAt: Double
}

@Observable
@MainActor
final class MatchesViewModel {

    var matches: [Match] = EntourageManager.shared.myMatchs {
        didSet { syncLastMessageListeners() }
    }
    var isLoading = false
    var errorMessage: String?
    /// Newest message per match chat, keyed by chat_id.
    var lastMessages: [Int: LastMessagePreview] = [:]

    private let repo = MatchRepository.shared
    private var lastLoaded: Date?
    @ObservationIgnored private var messageListeners: [Int: ListenerRegistration] = [:]

    init() {
        syncLastMessageListeners()
    }

    func preview(for match: Match) -> String? {
        guard let last = lastMessages[match.chat_id] else { return nil }
        let text = last.text.isEmpty ? "Sent a photo" : last.text
        if last.senderId == "\(EntourageManager.shared.user.id)" { return "You: \(text)" }
        return last.senderName.isEmpty ? text : "\(last.senderName): \(text)"
    }

    // Reads the chat itself rather than a summary doc, so any message from either group shows up.
    private func syncLastMessageListeners() {
        let wanted = Set(matches.map(\.chat_id))
        for (chatId, listener) in messageListeners where !wanted.contains(chatId) {
            listener.remove()
            messageListeners[chatId] = nil
            lastMessages[chatId] = nil
        }
        for chatId in wanted where messageListeners[chatId] == nil {
            messageListeners[chatId] = db.collection("Message/Match_\(chatId)/ChatMessages")
                .order(by: "createdAt", descending: true)
                .limit(to: 1)
                .addSnapshotListener { [weak self] snapshot, _ in
                    guard let doc = snapshot?.documents.first,
                          let msg: ChatMessage = ChatSDK.decodeElement(from: doc.data()) else { return }
                    let preview = LastMessagePreview(text: msg.messageData.text, senderId: msg.sender.id,
                                                     senderName: msg.sender.displayName, createdAt: msg.createdAt)
                    Task { @MainActor in self?.lastMessages[chatId] = preview }
                }
        }
    }

    func refreshIfStale() async {
        if let lastLoaded, Date().timeIntervalSince(lastLoaded) < 30 { return }
        await refresh()
    }

    func refresh() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let loaded = try await repo.matchList()
            EntourageManager.shared.myMatchs = loaded
            matches = loaded
            lastLoaded = Date()
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
