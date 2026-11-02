// MatchViewModel.swift — presentation wrapper for a single Match model
import Foundation

struct MatchViewModel {

    let match: Match

    init(_ match: Match) {
        self.match = match
    }

    var matchId: Int { match.id }

    var chatId: String { "Match_\(match.id)" }

    var otherGroup: Group? { match.matcher }

    var otherGroupName: String { match.matcher?.myGroupName() ?? "" }

    var isUnread: Bool { getUnReadMsg(id: "\(match.id)") > 0 }

    var unreadCount: Int { getUnReadMsg(id: "\(match.id)") }

    var lastMessage: String { getLastMsg(id: "Match_\(match.id)") }

    var hasMessages: Bool { !lastMessage.isEmpty }
}
