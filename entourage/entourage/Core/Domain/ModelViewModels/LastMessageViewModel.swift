// LastMessageViewModel.swift — presentation wrapper for a single LastMessage model
import Foundation

struct LastMessageViewModel {

    let lastMessage: LastMessage

    init(_ lastMessage: LastMessage) {
        self.lastMessage = lastMessage
    }

    var previewText: String { lastMessage.lastMessage }

    var unreadCount: Int { lastMessage.chatTotalCounter }

    var hasUnread: Bool { unreadCount > 0 }

    var unreadCountText: String {
        unreadCount > 99 ? "99+" : "\(unreadCount)"
    }

    var isFromCurrentUser: Bool {
        lastMessage.lastSenderId == EntourageManager.shared.user.id
    }

    var timeAgoText: String {
        let date = Date(timeIntervalSince1970: lastMessage.createdAt)
        let now  = Date()
        let seconds = now.timeIntervalSince(date)

        if seconds < 60 { return "now" }
        let minutes = Int(seconds / 60)
        if minutes < 60 { return "\(minutes)m" }
        let hours = minutes / 60
        if hours < 24 { return "\(hours)h" }
        let days = hours / 24
        if days < 7 { return "\(days)d" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}
