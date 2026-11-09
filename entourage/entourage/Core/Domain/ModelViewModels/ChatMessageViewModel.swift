// ChatMessageViewModel.swift — presentation wrapper for a single ChatMessage model
import Foundation

struct ChatMessageViewModel {

    let message: ChatMessage

    init(_ message: ChatMessage) {
        self.message = message
    }

    var messageId: String { message.id }

    var text: String { message.messageData.text }

    var type: ChatMessageType { message.messageData.type }

    var isText: Bool  { type == .Text }
    var isPhoto: Bool { type == .Photo }
    var isVideo: Bool { type == .Video }

    var mediaURL: URL? {
        let raw = message.messageData.mediaUrl
        guard !raw.isEmpty else { return nil }
        return URL(string: raw)
    }

    var senderName: String { message.sender.displayName }

    var senderFirstName: String { message.sender.firstName ?? senderName }

    var senderPhotoURL: URL? {
        guard !message.sender.photoUrl.isEmpty else { return nil }
        return URL(string: message.sender.photoUrl)
    }

    var isFromCurrentUser: Bool {
        message.sender.id == "\(EntourageManager.shared.user.id)"
    }

    var timeText: String {
        let date = Date(timeIntervalSince1970: message.createdAt)
        let formatter = DateFormatter()
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            formatter.dateFormat = "h:mm a"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            formatter.dateFormat = "MMM d"
        }
        return formatter.string(from: date)
    }

    var emoticonCode: String { message.emoticon.code }

    var hasEmoticon: Bool { !emoticonCode.isEmpty }
}
