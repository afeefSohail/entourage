// ChatRepository.swift — wraps MessageFirebaseService, exposes message operations
import Foundation
import Firebase

protocol ChatRepositoryProtocol {
    func createListener(id: String) -> MessageFirebaseService<ChatMessage>
    func deleteMessages(groupId: String, completion: @escaping () -> Void)
    func deleteMembers(groupId: String, completion: @escaping () -> Void)
}

final class ChatRepository: ChatRepositoryProtocol {

    static let shared = ChatRepository()

    private init() {}

    func createListener(id: String) -> MessageFirebaseService<ChatMessage> {
        return MessageFirebaseService.createListener(id: id)
    }

    func deleteMessages(groupId: String, completion: @escaping () -> Void) {
        deleteTheChatMessage(groupId: groupId, completetion: completion)
    }

    func deleteMembers(groupId: String, completion: @escaping () -> Void) {
        deleteTheChatMember(groupId: groupId, completetion: completion)
    }
}
